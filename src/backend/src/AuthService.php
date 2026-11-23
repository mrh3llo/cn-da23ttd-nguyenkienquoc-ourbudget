<?php
declare(strict_types=1);

final class AuthService
{
    private array $mail=[];
    public function __construct(private PDO $pdo, private GoogleIdentity $google, private ?SupabaseIdentity $supabase = null) {}

    public static function text(array $input,string $field,int $max,bool $required=true): string
    {
        $value=$input[$field] ?? '';
        if (!is_string($value) || !preg_match('//u',$value) || preg_match_all('/./us',$value)>$max || ($required && trim($value)==='')) throw new ApiError(422,'validation_failed','Kiểm tra thông tin đã nhập.',[$field=>['Giá trị không hợp lệ.']]);
        return trim($value);
    }
    private static function email(array $input): string
    {
        $email=strtolower(self::text($input,'email',150));
        if (!filter_var($email,FILTER_VALIDATE_EMAIL)) throw new ApiError(422,'validation_failed','Email không hợp lệ.',['email'=>['Nhập địa chỉ email hợp lệ.']]);
        return $email;
    }
    private static function password(array $input,string $field='password'): string
    {
        $value=$input[$field] ?? null;
        if (!is_string($value) || strlen($value)<8 || strlen($value)>72 || str_contains($value,"\0")) throw new ApiError(422,'validation_failed','Mật khẩu cần từ 8 đến 72 byte.',[$field=>['Mật khẩu cần từ 8 đến 72 byte.']]);
        return $value;
    }
    public function rateLimit(string $key,int $limit,int $seconds=900): void
    {
        $directory=config()['runtime_directory'].'/limits';
        if (!is_dir($directory) && !mkdir($directory,0700,true) && !is_dir($directory)) throw new ApiError(503,'service_unavailable','Không kiểm tra được giới hạn truy cập.');
        $handle=fopen($directory.'/'.hash('sha256',$key).'.json','c+');
        if (!$handle || !flock($handle,LOCK_EX)) throw new ApiError(503,'service_unavailable','Không kiểm tra được giới hạn truy cập.');
        try {
            $raw=stream_get_contents($handle);$row=$raw==='' ? null : json_decode($raw,true,flags:JSON_THROW_ON_ERROR);
            if (!$row || $row['expires_at']<=time()) $row=['attempts'=>0,'expires_at'=>time()+$seconds];
            if ($row['attempts']>=$limit) throw new ApiError(429,'rate_limited','Thử quá nhiều lần. Vui lòng đợi 15 phút.');
            $row['attempts']++;$json=json_encode($row,JSON_THROW_ON_ERROR);rewind($handle);
            if (fwrite($handle,$json)!==strlen($json) || !ftruncate($handle,strlen($json)) || !fflush($handle)) throw new RuntimeException('Rate storage failure');
        } finally {flock($handle,LOCK_UN);fclose($handle);}
    }
    private function atomic(callable $operation): array
    {
        $this->mail=[];$this->pdo->beginTransaction();
        try {$result=$operation();$this->pdo->commit();}
        catch (Throwable $e) {
            if ($this->pdo->inTransaction()) $this->pdo->rollBack();$this->mail=[];
        if ($e instanceof PDOException && ($e->getCode() === '23505' || ($e->errorInfo[0] ?? null) === '23505')) throw new ApiError(409,'account_conflict','Email hoặc tài khoản Google đã được sử dụng.');
            throw $e;
        }
        // Filesystem queue stays outside PostgreSQL: a crash between commit and enqueue can lose mail.
        foreach ($this->mail as $args) {
            try {MailQueue::enqueue($this->pdo,...$args);}
            catch (Throwable) {$result['mail_warning']=true;error_log('mail_enqueue_failed');}
        }
        $this->mail=[];return $result;
    }
    private function user(int $id): array
    {
        $q=$this->pdo->prepare("SELECT *,encode(users_sessions_hash,'hex') AS users_sessions_hash_hex,encode(users_verification_hash,'hex') AS users_verification_hash_hex,encode(users_reset_hash,'hex') AS users_reset_hash_hex FROM users WHERE users_id=? AND users_is_active=1 FOR UPDATE");$q->execute([$id]);
        return $q->fetch() ?: throw new ApiError(401,'unauthenticated','Phiên không hợp lệ.');
    }
    public function profile(array $user): array
    {
        return ['id'=>(string)$user['users_id'],'name'=>$user['users_name'],'email'=>$user['users_email'],'phone'=>$user['users_phonenumber'],'avatar_url'=>$user['users_avatar_url'],'email_verified'=>$user['users_verified_at']!==null,'has_password'=>$user['users_password']!==null,'google_linked'=>$user['user_google_sub']!==null];
    }
    private function issueSession(array $user,?string $event): array
    {
        $token=bin2hex(random_bytes(32));$expires=(new DateTimeImmutable('+30 days'))->format('Y-m-d H:i:s');
        $this->pdo->prepare("UPDATE users SET users_sessions_hash=decode(?,'hex'),users_sessions_expires_at=? WHERE users_id=?")->execute([hash('sha256',$token),$expires,$user['users_id']]);
        if ($event!==null) $this->mail[]=[(int)$user['users_id'],$event==='auth.registered' ? 'registered:'.$user['users_id'] : 'login:'.hash('sha256',$token),$event,[]];
        return ['token'=>$token,'expires_at'=>str_replace(' ','T',$expires).'+07:00','user'=>$this->profile($user)];
    }
    public function authenticate(string $token): array
    {
        if (preg_match('/^[a-f0-9]{64}$/D', $token)) {
            $q=$this->pdo->prepare("SELECT *,encode(users_sessions_hash,'hex') AS users_sessions_hash_hex FROM users WHERE users_sessions_hash=decode(?,'hex') AND users_sessions_expires_at>CURRENT_TIMESTAMP AND users_is_active=1");$q->execute([hash('sha256',$token)]);
            return $q->fetch() ?: throw new ApiError(401,'unauthenticated','Phiên hết hạn, đã đăng xuất hoặc được thay thế bởi lần đăng nhập mới.');
        }

        if ($this->supabase === null) throw new ApiError(401,'unauthenticated','Phiên Supabase không được hỗ trợ.');
        $identity = $this->supabase->verify($token);
        if (empty($identity['email_confirmed_at'])) throw new ApiError(403,'email_unverified','Hãy xác minh email trước khi sử dụng ứng dụng.');
        $q=$this->pdo->prepare('SELECT users_id FROM users WHERE users_supabase_uid=? AND users_is_active=1');$q->execute([$identity['id']]);
        $id=$q->fetchColumn();
        if ($id===false) throw new ApiError(401,'profile_not_synced','Hồ sơ người dùng chưa được đồng bộ.');
        return $this->user((int)$id);
    }
    private function verification(array $user): void
    {
        $code=bin2hex(random_bytes(32));$hash=hash('sha256',$code);
        $this->pdo->prepare("UPDATE users SET users_verification_hash=decode(?,'hex'),users_verification_experes_at=CURRENT_TIMESTAMP + INTERVAL '30 minutes' WHERE users_id=?")->execute([$hash,$user['users_id']]);
        $this->mail[]=[(int)$user['users_id'],'verify:'.bin2hex($hash),'email.verify',['verification_code'=>$code]];
    }
    public function register(array $input): array
    {
        $name=self::text($input,'name',50);$email=self::email($input);$hash=password_hash(self::password($input),PASSWORD_DEFAULT);
        return $this->atomic(function()use($name,$email,$hash){
            $q=$this->pdo->prepare('INSERT INTO users (users_name,users_email,users_password) VALUES (?,?,?) RETURNING users_id');$q->execute([$name,$email,$hash]);
            $user=$this->user((int)$q->fetchColumn());$this->verification($user);return $this->issueSession($user,null);
        });
    }
    public function login(array $input): array
    {
        $email=self::email($input);$password=self::password($input);
        return $this->atomic(function()use($email,$password){
            $q=$this->pdo->prepare('SELECT * FROM users WHERE users_email=? FOR UPDATE');$q->execute([$email]);$user=$q->fetch();
            $correct=password_verify($password,$user['users_password'] ?? '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.');
            if (!$user || !$user['users_is_active'] || $user['users_password']===null || !$correct) throw new ApiError(401,'invalid_credentials','Email hoặc mật khẩu không đúng.');
            return $this->issueSession($user,'auth.login');
        });
    }
    public function google(array $input,?array $existingUser=null): array
    {
        $claims=$this->google->verify(self::text($input,'id_token',16384));
        return $this->atomic(function()use($claims,$existingUser,$input){
            if ($existingUser!==null) {
                $user=$this->user((int)$existingUser['users_id']);
                if ($user['users_password']===null || !password_verify(self::password($input),$user['users_password'])) throw new ApiError(401,'reauthentication_required','Nhập mật khẩu hiện tại để liên kết Google.');
                if ($user['user_google_sub']!==null) throw new ApiError(409,'account_conflict','Tài khoản đã liên kết Google.');
                $this->pdo->prepare('UPDATE users SET user_google_sub=? WHERE users_id=?')->execute([$claims['sub'],$user['users_id']]);
                return ['user'=>$this->profile($this->user((int)$user['users_id']))];
            }
            $q=$this->pdo->prepare('SELECT users_id FROM users WHERE user_google_sub=?');$q->execute([$claims['sub']]);$id=$q->fetchColumn();
            if ($id!==false) return $this->issueSession($this->user((int)$id),'auth.login');
            $email=self::email(['email'=>$claims['email']]);
            $q=$this->pdo->prepare('SELECT 1 FROM users WHERE users_email=?');$q->execute([$email]);
            if ($q->fetchColumn()) throw new ApiError(409,'google_link_required','Đăng nhập tài khoản hiện có rồi liên kết Google trong Hồ sơ.');
            $verified=($claims['email_verified'] ?? false)===true && (str_ends_with($email,'@gmail.com') || !empty($claims['hd']));
            $name=is_string($claims['name'] ?? null) ? trim($claims['name']) : '';
            if ($name==='' || preg_match_all('/./us',$name)>50) $name='Google user';
            $q=$this->pdo->prepare('INSERT INTO users (users_name,users_email,user_google_sub,users_verified_at,users_welcomed_at) VALUES (?,?,?,CASE WHEN ?::integer=1 THEN CURRENT_TIMESTAMP ELSE NULL END,CASE WHEN ?::integer=1 THEN CURRENT_TIMESTAMP ELSE NULL END) RETURNING users_id');$q->execute([$name,$email,$claims['sub'],(int)$verified,(int)$verified]);
            $user=$this->user((int)$q->fetchColumn());if (!$verified) $this->verification($user);
            return $this->issueSession($user,$verified ? 'auth.registered' : null);
        });
    }
    public function logout(array $user): array
    {
        $this->pdo->prepare("UPDATE users SET users_sessions_hash=NULL,users_sessions_expires_at=NULL WHERE users_id=? AND users_sessions_hash=decode(?,'hex')")->execute([$user['users_id'],$user['users_sessions_hash_hex']]);
        return ['revoked'=>true];
    }
    public function resend(array $user): array
    {
        return $this->atomic(function()use($user){$current=$this->user((int)$user['users_id']);if ($current['users_verified_at']===null) $this->verification($current);return ['accepted'=>true];});
    }
    public function verifyEmail(array $user,array $input): array
    {
        $code=self::text($input,'code',128);
        return $this->atomic(function()use($user,$code){
            $current=$this->user((int)$user['users_id']);
            if (!is_string($current['users_verification_hash_hex']) || !hash_equals($current['users_verification_hash_hex'],hash('sha256',$code)) || strtotime($current['users_verification_experes_at'] ?? '1970-01-01')<=time()) throw new ApiError(422,'invalid_verification_code','Mã xác minh sai, hết hạn hoặc đã dùng.');
            $this->pdo->prepare('UPDATE users SET users_verified_at=CURRENT_TIMESTAMP,users_verification_hash=NULL,users_verification_experes_at=NULL,users_welcomed_at=COALESCE(users_welcomed_at,CURRENT_TIMESTAMP) WHERE users_id=?')->execute([$current['users_id']]);
            if ($current['users_welcomed_at']===null) $this->mail[]=[(int)$current['users_id'],'registered:'.$current['users_id'],'auth.registered',[]];
            return ['user'=>$this->profile($this->user((int)$current['users_id']))];
        });
    }
    public function updateProfile(array $user,array $input): array
    {
        $name=self::text($input,'name',50);$email=self::email($input);$phone=self::text($input,'phone',10,false);$avatar=self::text($input,'avatar_url',2048,false);
        if ($avatar!=='' && (!filter_var($avatar,FILTER_VALIDATE_URL) || parse_url($avatar,PHP_URL_SCHEME)!=='https' || parse_url($avatar,PHP_URL_USER)!==null)) throw new ApiError(422,'validation_failed','Ảnh đại diện cần URL HTTPS hợp lệ.');
        $claims=null;if ($email!==$user['users_email'] && $user['users_password']===null) $claims=$this->google->verify(self::text($input,'id_token',16384));
        return $this->atomic(function()use($user,$input,$name,$email,$phone,$avatar,$claims){
            $current=$this->user((int)$user['users_id']);$changed=$email!==$current['users_email'];
            if ($changed) {
                $valid=$current['users_password']!==null ? password_verify(self::password($input,'current_password'),$current['users_password']) : ($claims!==null && $claims['sub']===$current['user_google_sub']);
                if (!$valid) throw new ApiError(401,'reauthentication_required','Xác thực lại tài khoản hiện tại để đổi email.');
            }
            $this->pdo->prepare('UPDATE users SET users_name=?,users_email=?,users_phonenumber=?,users_avatar_url=?,users_verified_at=CASE WHEN ?::integer=1 THEN NULL ELSE users_verified_at END,users_reset_hash=CASE WHEN ?::integer=1 THEN NULL ELSE users_reset_hash END,users_reset_expires_at=CASE WHEN ?::integer=1 THEN NULL ELSE users_reset_expires_at END WHERE users_id=?')->execute([$name,$email,$phone ?: null,$avatar ?: null,(int)$changed,(int)$changed,(int)$changed,$current['users_id']]);
            $current=$this->user((int)$current['users_id']);if ($changed) $this->verification($current);return ['user'=>$this->profile($current)];
        });
    }
    public function forgotPassword(array $input): array
    {
        $email=self::email($input);
        return $this->atomic(function()use($email){
            $q=$this->pdo->prepare('SELECT * FROM users WHERE users_email=? AND users_is_active=1 FOR UPDATE');$q->execute([$email]);$user=$q->fetch();
            if ($user && $user['users_password']!==null) {
                $code=bin2hex(random_bytes(32));$hash=hash('sha256',$code);
                $this->pdo->prepare("UPDATE users SET users_reset_hash=decode(?,'hex'),users_reset_expires_at=CURRENT_TIMESTAMP + INTERVAL '15 minutes' WHERE users_id=?")->execute([$hash,$user['users_id']]);
                $this->mail[]=[(int)$user['users_id'],'reset:'.bin2hex($hash),'auth.password_reset',['verification_code'=>$code]];
            }
            return ['accepted'=>true];
        });
    }
    public function resetPassword(array $input): array
    {
        $email=self::email($input);$code=self::text($input,'code',128);$hash=password_hash(self::password($input),PASSWORD_DEFAULT);
        return $this->atomic(function()use($email,$code,$hash){
            $q=$this->pdo->prepare("SELECT *,encode(users_reset_hash,'hex') AS users_reset_hash_hex FROM users WHERE users_email=? AND users_is_active=1 FOR UPDATE");$q->execute([$email]);$user=$q->fetch();
            if (!$user || $user['users_password']===null || !is_string($user['users_reset_hash_hex']) || !hash_equals($user['users_reset_hash_hex'],hash('sha256',$code)) || strtotime($user['users_reset_expires_at'] ?? '1970-01-01')<=time()) throw new ApiError(422,'invalid_reset_code','Mã khôi phục sai, hết hạn hoặc đã dùng.');
            $this->pdo->prepare('UPDATE users SET users_password=?,users_reset_hash=NULL,users_reset_expires_at=NULL,users_sessions_hash=NULL,users_sessions_expires_at=NULL WHERE users_id=?')->execute([$hash,$user['users_id']]);return ['reset'=>true];
        });
    }
}
