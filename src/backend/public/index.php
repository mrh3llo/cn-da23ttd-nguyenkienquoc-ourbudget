<?php
declare(strict_types=1);

require dirname(__DIR__) . '/src/bootstrap.php';
ini_set('display_errors', '0');
$requestId = bin2hex(random_bytes(16));
try {
    $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
    if ($path !== '/api/v1/health') {
        Http::send(404, Http::error('not_found', 'Không tìm thấy tài nguyên.', $requestId));
    }
    if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        header('Allow: GET');
        Http::send(405, Http::error('method_not_allowed', 'Phương thức không được hỗ trợ.', $requestId));
    }
    try {
        $pdo = database(config());
        $version = $pdo->query("SELECT version FROM schema_migrations WHERE version = '004_step03_foundation'")->fetchColumn();
        if ($version === false) {
            throw new RuntimeException('Schema is not ready');
        }
    } catch (Throwable $e) {
        error_log('request_id=' . $requestId . ' dependency_unavailable ' . get_class($e));
        Http::send(503, Http::error('service_unavailable', 'Dịch vụ tạm thời chưa sẵn sàng.', $requestId));
    }
    Http::send(200, Http::success(['status' => 'ok', 'database' => 'ok', 'schema' => $version], $requestId));
} catch (Throwable $e) {
    error_log('request_id=' . $requestId . ' unexpected_error ' . get_class($e));
    Http::send(500, Http::error('internal_error', 'Không thể xử lý yêu cầu.', $requestId));
}
