<?php
declare(strict_types=1);

final class SupabaseIdentity
{
    public function __construct(private string $url, private string $publishableKey) {}

    public function verify(string $accessToken): array
    {
        if (!preg_match('/^[A-Za-z0-9._~-]{20,8192}$/D', $accessToken)) {
            throw new ApiError(401, 'unauthenticated', 'Phiên Supabase không hợp lệ.');
        }
        $scheme = parse_url($this->url, PHP_URL_SCHEME);
        if (
            !filter_var($this->url, FILTER_VALIDATE_URL)
            || $scheme !== 'https'
            || $this->publishableKey === ''
        ) {
            throw new ApiError(503, 'service_unavailable', 'Chưa cấu hình dịch vụ xác thực.');
        }

        $handle = curl_init(rtrim($this->url, '/') . '/auth/v1/user');
        if ($handle === false) throw new ApiError(503, 'auth_unavailable', 'Chưa kết nối được dịch vụ xác thực.');
        curl_setopt_array($handle, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_CONNECTTIMEOUT => 5,
            CURLOPT_TIMEOUT => 10,
            CURLOPT_HTTPHEADER => [
                'apikey: ' . $this->publishableKey,
                'Authorization: Bearer ' . $accessToken,
                'Accept: application/json',
            ],
        ]);
        $body = curl_exec($handle);
        $status = (int) curl_getinfo($handle, CURLINFO_RESPONSE_CODE);
        $failed = $body === false;
        curl_close($handle);

        if ($failed) {
            throw new ApiError(503, 'auth_unavailable', 'Chưa kết nối được dịch vụ xác thực.');
        }
        if ($status === 401 || $status === 403) {
            throw new ApiError(401, 'unauthenticated', 'Phiên Supabase đã hết hạn.');
        }
        if ($status !== 200) {
            throw new ApiError(503, 'auth_unavailable', 'Dịch vụ xác thực tạm thời chưa sẵn sàng.');
        }

        try {
            $identity = json_decode((string) $body, true, 32, JSON_THROW_ON_ERROR);
        } catch (JsonException) {
            throw new ApiError(503, 'auth_unavailable', 'Phản hồi xác thực không hợp lệ.');
        }
        if (!is_array($identity) || !isset($identity['id'], $identity['email'])) {
            throw new ApiError(401, 'unauthenticated', 'Phiên Supabase không hợp lệ.');
        }
        return $identity;
    }
}
