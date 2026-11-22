<?php
declare(strict_types=1);

ini_set('display_errors', '0');
require dirname(__DIR__) . '/src/bootstrap.php';
$requestId = bin2hex(random_bytes(16));
$routes = [
    '/api/v1/health' => ['GET'], '/api/v1/me' => ['GET','PATCH'],
    '/api/v1/auth/register' => ['POST'], '/api/v1/auth/login' => ['POST'],
    '/api/v1/auth/google' => ['POST'], '/api/v1/auth/google/link' => ['POST'],
    '/api/v1/auth/logout' => ['POST'], '/api/v1/auth/forgot-password' => ['POST'],
    '/api/v1/auth/reset-password' => ['POST'], '/api/v1/auth/verify-email' => ['POST'],
    '/api/v1/auth/resend-verification' => ['POST'],
];
try {
    $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
    $method = $_SERVER['REQUEST_METHOD'];
    if (!isset($routes[$path])) throw new ApiError(404,'not_found','Không tìm thấy tài nguyên.');
    if (!in_array($method,$routes[$path],true)) {
        header('Allow: ' . implode(', ', $routes[$path]));
        throw new ApiError(405,'method_not_allowed','Phương thức không được hỗ trợ.');
    }
    $settings = config();
    try {
        $pdo = database($settings);
    $version = $pdo->query("SELECT COUNT(*) FROM information_schema.columns WHERE table_schema='public' AND table_name='users' AND column_name='users_sessions_hash'")->fetchColumn();
    $legacyType=(int)$pdo->query("SELECT COUNT(*) FROM information_schema.columns WHERE table_schema='public' AND table_name='transactions' AND column_name='transactions_type'")->fetchColumn();
    $tables=$pdo->query("SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE'")->fetchAll(PDO::FETCH_COLUMN);
        $expected=['users','wallet_categories','wallets','income_categories','outcome_categories','transactions','budgets'];
if (array_diff($expected,$tables) || (int)$version !== 1 || $legacyType !== 0) throw new RuntimeException('Migration required');
    } catch (Throwable $e) {
        error_log('request_id='.$requestId.' dependency_unavailable '.get_class($e));
        throw new ApiError(503,'service_unavailable','Dịch vụ tạm thời chưa sẵn sàng.');
    }
    if ($path === '/api/v1/health') Http::send(200,Http::success(['status'=>'ok','database'=>'ok','schema'=>'report-standardized-sign-amount'],$requestId));
    $auth = new AuthService($pdo,new GoogleIdentity($settings['google_server_client_id']));
    $auth->rateLimit('ip:'.($_SERVER['REMOTE_ADDR'] ?? 'unknown'),120);
    $input = [];
    if ($method !== 'GET') {
        if (strtolower(trim(explode(';',$_SERVER['CONTENT_TYPE'] ?? '')[0])) !== 'application/json') throw new ApiError(415,'unsupported_media_type','Yêu cầu Content-Type application/json.');
        $raw = file_get_contents('php://input',false,null,0,32769);
        if (strlen($raw) > 32768) throw new ApiError(413,'payload_too_large','Nội dung quá dài.');
        try {
            $object = json_decode($raw,false,32,JSON_THROW_ON_ERROR);
            if (!$object instanceof stdClass) throw new JsonException('Object required');
            $input = (array)$object;
        } catch (JsonException) { throw new ApiError(400,'bad_request','JSON không hợp lệ.'); }
    }
    $public = ['/api/v1/auth/register','/api/v1/auth/login','/api/v1/auth/google','/api/v1/auth/forgot-password','/api/v1/auth/reset-password'];
    $user = null;
    if (!in_array($path,$public,true)) {
        $header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
        if (!preg_match('/^Bearer ([a-f0-9]{64})$/D',$header,$match)) throw new ApiError(401,'unauthenticated','Vui lòng đăng nhập.');
        $user = $auth->authenticate($match[1]);
    }
    if ($method !== 'GET') {
        $identity = $user ? (string)$user['users_id'] : strtolower(is_string($input['email'] ?? null) ? trim($input['email']) : ($_SERVER['REMOTE_ADDR'] ?? 'unknown'));
        $auth->rateLimit($path.':'.$identity, in_array($path,['/api/v1/auth/register','/api/v1/auth/forgot-password','/api/v1/auth/resend-verification'],true) ? 5 : 10);
    }
    $result = match ($path) {
        '/api/v1/auth/register' => $auth->register($input),
        '/api/v1/auth/login' => $auth->login($input),
        '/api/v1/auth/google' => $auth->google($input),
        '/api/v1/auth/google/link' => $auth->google($input,$user),
        '/api/v1/auth/logout' => $auth->logout($user),
        '/api/v1/auth/forgot-password' => $auth->forgotPassword($input),
        '/api/v1/auth/reset-password' => $auth->resetPassword($input),
        '/api/v1/auth/verify-email' => $auth->verifyEmail($user,$input),
        '/api/v1/auth/resend-verification' => $auth->resend($user),
        '/api/v1/me' => $method === 'GET' ? ['user'=>$auth->profile($user)] : $auth->updateProfile($user,$input),
    };
    Http::send($path === '/api/v1/auth/register' ? 201 : 200,Http::success($result,$requestId));
} catch (ApiError $e) {
    if ($e->status === 429) header('Retry-After: 900');
    Http::send($e->status,Http::error($e->errorCode,$e->getMessage(),$requestId,$e->fields));
} catch (Throwable $e) {
    error_log('request_id='.$requestId.' unexpected_error '.get_class($e));
    Http::send(500,Http::error('internal_error','Không thể xử lý yêu cầu.',$requestId));
}
