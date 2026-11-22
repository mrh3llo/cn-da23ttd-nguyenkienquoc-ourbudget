<?php
declare(strict_types=1);
require dirname(__DIR__).'/src/bootstrap.php';
$settings=config();
if (!str_ends_with($settings['db_name'],'_test')) throw new RuntimeException('Test database required');
$pdo=database($settings);
$base=getenv('OURBUDGET_TEST_API_URL') ?: 'http://127.0.0.1:18080';
$passed=0;
function api(string $method,string $path,array $body=[],?string $token=null,int $status=200): array {
    global $base,$passed;
    $headers="Content-Type: application/json\r\n".($token ? "Authorization: Bearer $token\r\n" : '');
    $json=file_get_contents($base.'/api/v1/'.$path,false,stream_context_create(['http'=>[
        'method'=>$method,'header'=>$headers,'content'=>$method==='GET' ? '' : json_encode((object)$body), 'ignore_errors'=>true,'timeout'=>15,
    ]]));
    $result=json_decode($json,true,flags:JSON_THROW_ON_ERROR);
    if (!str_contains($http_response_header[0]," $status ")) throw new RuntimeException("FAIL $method $path expected $status got ".$http_response_header[0]);
    $passed++;echo "PASS: $method $path $status\n";
    return $result['data'] ?? $result;
}
function testCode(PDO $pdo,string $event,int $id): string {
    foreach (glob(MailQueue::directory().'/*.json') as $file) {
        $row=json_decode(file_get_contents($file),true);
        if ($row['users_id']===$id && $row['event_type']===$event && MailQueue::recipientValid($pdo,$row)) return $row['payload']['verification_code'];
    }
    throw new RuntimeException('Missing test code');
}
$suffix=bin2hex(random_bytes(4));$email="http-$suffix@ourbudget.test";
api('GET','me',status:401);
api('POST','auth/register',['name'=>'Test','email'=>'bad','password'=>'123'],status:422);
$a=api('POST','auth/register',['name'=>'HTTP A','email'=>$email,'password'=>'Password!123'],status:201);
api('POST','auth/register',['name'=>'HTTP duplicate','email'=>$email,'password'=>'Password!123'],status:409);
$me=api('GET','me',token:$a['token']);
if ($me['user']['id']!==$a['user']['id']) throw new RuntimeException('User isolation failed');
api('POST','auth/login',['email'=>$email,'password'=>'WrongPassword'],status:401);
$login=api('POST','auth/login',['email'=>$email,'password'=>'Password!123']);
$oldToken=$a['token'];$a['token']=$login['token'];
api('GET','me',token:$oldToken,status:401);
api('PATCH','me',['name'=>'Changed','email'=>$email,'phone'=>'123'],token:$a['token']);
api('POST','auth/verify-email',['code'=>'bad'],token:$a['token'],status:422);
$code=testCode($pdo,'email.verify',(int)$a['user']['id']);
api('POST','auth/verify-email',['code'=>$code],token:$a['token']);
api('POST','auth/verify-email',['code'=>$code],token:$a['token'],status:422);
api('POST','auth/logout',token:$login['token']);
api('GET','me',token:$login['token'],status:401);
api('POST','auth/forgot-password',['email'=>$email]);
$code=testCode($pdo,'auth.password_reset',(int)$a['user']['id']);
api('POST','auth/reset-password',['email'=>$email,'code'=>$code,'password'=>'NewPassword!123']);
api('GET','me',token:$a['token'],status:401);
api('POST','auth/reset-password',['email'=>$email,'code'=>$code,'password'=>'NewPassword!123'],status:422);
api('POST','auth/login',['email'=>$email,'password'=>'NewPassword!123']);
api('POST','auth/google',['id_token'=>'invalid-token'],status:401);
echo "AUTH HTTP RESULT: $passed/$passed passed\n";
