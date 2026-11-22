<?php
declare(strict_types=1);

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

final class GoogleIdentity
{
    public function __construct(private string $clientId, private ?array $testCertificates = null) {}

    public function verify(string $token): array
    {
        if ($this->clientId === '') {
            throw new ApiError(503, 'google_unavailable', 'Chưa cấu hình Google Sign-In.');
        }
        try {
            $parts = explode('.', $token);
            $header = count($parts) === 3 ? json_decode(JWT::urlsafeB64Decode($parts[0]), true, flags: JSON_THROW_ON_ERROR) : null;
            if (!is_array($header) || ($header['alg'] ?? '') !== 'RS256' || !is_string($header['kid'] ?? null)) {
                throw new UnexpectedValueException('Invalid header');
            }
            $certificates = $this->testCertificates ?? $this->certificates();
            if (!isset($certificates[$header['kid']])) {
                throw new UnexpectedValueException('Unknown key');
            }
            $claims = (array) JWT::decode($token, new Key($certificates[$header['kid']], 'RS256'));
            if (!in_array($claims['iss'] ?? '', ['accounts.google.com', 'https://accounts.google.com'], true)
                || ($claims['aud'] ?? null) !== $this->clientId
                || !is_int($claims['exp'] ?? null) || $claims['exp'] <= time()
                || !is_int($claims['iat'] ?? null) || $claims['iat'] > time() + 60
                || !is_string($claims['sub'] ?? null) || !preg_match('/^[\x21-\x7e]{1,255}$/D', $claims['sub'])
                || !is_string($claims['email'] ?? null) || !filter_var($claims['email'], FILTER_VALIDATE_EMAIL)) {
                throw new UnexpectedValueException('Invalid claims');
            }
            return $claims;
        } catch (ApiError $e) {
            throw $e;
        } catch (Throwable) {
            throw new ApiError(401, 'invalid_google_token', 'Không xác minh được tài khoản Google.');
        }
    }

    private function certificates(): array
    {
        $path = dirname(__DIR__) . '/storage/google-certificates.json';
        $cached = is_file($path) ? json_decode((string) file_get_contents($path), true) : null;
        if (is_array($cached) && ($cached['expires_at'] ?? 0) > time() && is_array($cached['keys'] ?? null)) {
            return $cached['keys'];
        }
        // The URL is fixed; no token-controlled key URLs are fetched.
        $body = @file_get_contents('https://www.googleapis.com/oauth2/v1/certs', false,
            stream_context_create(['http' => ['timeout' => 8], 'ssl' => ['verify_peer' => true, 'verify_peer_name' => true]]), 0, 1048576);
        $keys = $body === false ? null : json_decode($body, true);
        if (!is_array($keys) || !$keys || count(array_filter($keys, 'is_string')) !== count($keys)) {
            throw new ApiError(503, 'google_unavailable', 'Không kết nối được dịch vụ xác minh Google.');
        }
        // Five-minute cache; an unknown key fails closed until the next refresh.
        file_put_contents($path, json_encode(['expires_at' => time() + 300, 'keys' => $keys], JSON_THROW_ON_ERROR), LOCK_EX);
        return $keys;
    }
}
