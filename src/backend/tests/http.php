<?php
declare(strict_types=1);

require dirname(__DIR__) . '/src/bootstrap.php';
$base = getenv('OURBUDGET_TEST_API_URL') ?: 'http://127.0.0.1:18080';
$passed = 0;
function verify(bool $value, string $name): void
{
    global $passed;
    if (!$value) {
        throw new RuntimeException('FAIL: ' . $name);
    }
    echo "PASS: $name\n";
    $passed++;
}
foreach ([['GET','/api/v1/health',200], ['GET','/api/v1/unknown',404], ['POST','/api/v1/health',405], ['GET','/../config/local.php',404], ['GET','/config/example.php',404]] as [$method,$path,$status]) {
    $body = file_get_contents($base . $path, false, stream_context_create(['http'=>['method'=>$method,'ignore_errors'=>true,'timeout'=>10]]));
    $json = json_decode($body, true, flags: JSON_THROW_ON_ERROR);
    verify(str_contains($http_response_header[0], " $status "), "$method $path status $status");
    verify((bool) preg_match('/^[a-f0-9]{32}$/D', $json['meta']['request_id']), 'Server request ID');
    verify(in_array('Cache-Control: no-store', $http_response_header, true), 'No-store response');
    if ($status === 200) {
        verify($json['data']['database'] === 'ok', 'HTTP reaches PostgreSQL');
    } else {
        verify(isset($json['error']['code']), 'Error envelope');
    }
}
foreach (['unauthenticated','not_found','conflict','validation_failed','internal_error'] as $code) {
    $body = Http::error($code, 'Thông báo', 'fixture');
    verify(json_decode(json_encode($body))->error->fields instanceof stdClass, "$code empty fields is an object");
}
$success = Http::success(['amount'=>'9223372036854775807','occurred_at'=>'2026-11-20T23:30:00+07:00'], 'fixture');
verify(json_decode(json_encode($success), true)['data']['amount'] === '9223372036854775807', 'Money string is lossless');
echo "HTTP RESULT: $passed/$passed passed\n";
foreach (json_decode(file_get_contents(dirname(__DIR__, 2) . '/contracts/http-fixtures.json'), true, flags: JSON_THROW_ON_ERROR) as $fixture) {
    $body = $fixture['body'];
    $id = $body['meta']['request_id'];
    $actual = $fixture['status'] === 201 ? Http::success($body['data'], $id)
        : Http::error($body['error']['code'], $body['error']['message'], $id, $body['error']['fields']);
    verify(json_decode(json_encode($actual), true) === $body, 'Shared fixture ' . $fixture['status']);
}
echo "HTTP + FIXTURE RESULT: $passed/$passed passed\n";
$unavailable = getenv('OURBUDGET_TEST_UNAVAILABLE_URL');
if ($unavailable) {
    $body = file_get_contents($unavailable . '/api/v1/health', false, stream_context_create(['http'=>['ignore_errors'=>true,'timeout'=>10]]));
    $json = json_decode($body, true, flags: JSON_THROW_ON_ERROR);
    verify(str_contains($http_response_header[0], ' 503 '), 'Unavailable database returns 503');
    verify($json['error']['code'] === 'service_unavailable' && !str_contains($body, 'SQLSTATE') && !str_contains($body, 'pgsql:'), 'Dependency errors do not leak database details');
    echo "HTTP ALL RESULT: $passed/$passed passed\n";
}
