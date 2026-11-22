<?php
declare(strict_types=1);

final class MailQueue
{
    public const SUBJECTS = [
        'email.verify'=>'Xác minh địa chỉ email OurBudget',
        'auth.password_reset'=>'Khôi phục mật khẩu OurBudget',
        'auth.registered'=>'Đăng ký OurBudget thành công',
        'auth.login'=>'Đăng nhập OurBudget thành công',
        'transaction.created'=>'Đã ghi nhận thu/chi',
        'transaction.updated'=>'Đã cập nhật thu/chi',
        'transaction.deleted'=>'Đã xóa thu/chi',
    ];

    public static function directory(): string
    {
        $path=config()['runtime_directory'].'/queue';
        if (!is_dir($path) && !mkdir($path,0700,true) && !is_dir($path)) throw new RuntimeException('Queue unavailable');
        return $path;
    }

    public static function recipientValid(PDO $pdo,array $row): bool
    {
        $q=$pdo->prepare("SELECT *,encode(users_verification_hash,'hex') AS users_verification_hash_hex,encode(users_reset_hash,'hex') AS users_reset_hash_hex FROM users WHERE users_id=? AND users_is_active=1");$q->execute([$row['users_id']]);$user=$q->fetch();
        if (!$user || $user['users_email']!==$row['recipient']) return false;
        if (in_array($row['event_type'],['email.verify','auth.password_reset'],true)) {
            $prefix=$row['event_type']==='email.verify' ? 'users_verification' : 'users_reset';
            $code=$row['payload']['verification_code'] ?? '';
            return is_string($code) && is_string($user[$prefix.'_hash_hex'])
                && hash_equals($user[$prefix.'_hash_hex'],hash('sha256',$code))
                && strtotime($user[$prefix.($prefix==='users_verification' ? '_experes_at' : '_expires_at')] ?? '1970-01-01')>time();
        }
        return $user['users_verified_at']!==null;
    }

    public static function enqueue(PDO $pdo,int $userId,string $eventId,string $event,array $payload=[]): void
    {
        if ($pdo->inTransaction()) throw new LogicException('Queue only after database commit');
        if (!isset(self::SUBJECTS[$event])) throw new InvalidArgumentException('Invalid mail event');
        $q=$pdo->prepare('SELECT users_email FROM users WHERE users_id=?');$q->execute([$userId]);$email=$q->fetchColumn();
        $row=['users_id'=>$userId,'recipient'=>$email,'event_id'=>$eventId,'event_type'=>$event,'payload'=>$payload,'attempts'=>0,'next_attempt_at'=>time(),'status'=>'pending'];
        if (!self::recipientValid($pdo,$row)) return;
        $file=self::directory().'/'.hash('sha256',$eventId).'.json';
        $handle=fopen($file,'c+');
        if (!$handle || !flock($handle,LOCK_EX)) throw new RuntimeException('Queue lock unavailable');
        try {
            if (fstat($handle)['size']>0) return;
            self::write($handle,$row);
        } finally {flock($handle,LOCK_UN);fclose($handle);}
    }

    public static function workOne(PDO $pdo,callable $deliver): bool
    {
        foreach (glob(self::directory().'/*.json') as $file) {
            $handle=fopen($file,'r+');
            if (!$handle) continue;
            if (!flock($handle,LOCK_EX|LOCK_NB)) {fclose($handle);continue;}
            try {
                $row=json_decode(stream_get_contents($handle),true,flags:JSON_THROW_ON_ERROR);
                if (!in_array($row['status'],['pending','processing'],true) || $row['next_attempt_at']>time()) continue;
                if (!self::recipientValid($pdo,$row)) {$row['status']='cancelled';}
                elseif ($row['attempts']>=5) {$row['status']='failed';}
                else {
                    $row['attempts']++;$row['status']='processing';
                    self::write($handle,$row);
                    try {
                        $message=$row;$message['payload']=json_encode($row['payload'],JSON_THROW_ON_ERROR);
                        $deliver($message);$row['status']='sent';
                    } catch (Throwable) {
                        $row['status']=$row['attempts']>=5 ? 'failed' : 'pending';
                        $row['next_attempt_at']=time()+min(3600,30*(2**($row['attempts']-1)));
                        $row['last_error']='delivery_failed';
                    }
                }
                if (in_array($row['status'],['sent','cancelled','failed'],true)) $row['payload']=[];
                self::write($handle,$row);return true;
            } finally {flock($handle,LOCK_UN);fclose($handle);}
        }
        return false;
    }

    private static function write($handle,array $row): void
    {
        $json=json_encode($row,JSON_THROW_ON_ERROR|JSON_UNESCAPED_UNICODE);
        rewind($handle);
        if (fwrite($handle,$json)!==strlen($json) || !ftruncate($handle,strlen($json)) || !fflush($handle)) throw new RuntimeException('Queue write failed');
    }
}
