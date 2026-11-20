<?php
declare(strict_types=1);

final class Http
{
    public static function success(mixed $data, string $requestId, array $meta = []): array
    {
        return ['data' => $data, 'meta' => ['request_id' => $requestId] + $meta];
    }

    public static function error(string $code, string $message, string $requestId, array $fields = []): array
    {
        return ['error' => ['code' => $code, 'message' => $message, 'fields' => (object) $fields],
            'meta' => ['request_id' => $requestId]];
    }

    public static function send(int $status, array $body): never
    {
        $json = json_encode($body, JSON_THROW_ON_ERROR | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        http_response_code($status);
        header('Content-Type: application/json; charset=utf-8');
        header('Cache-Control: no-store');
        header('X-Content-Type-Options: nosniff');
        header('X-Request-ID: ' . $body['meta']['request_id']);
        echo $json;
        exit;
    }
}
