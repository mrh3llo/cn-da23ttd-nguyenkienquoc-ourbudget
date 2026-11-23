<?php
declare(strict_types=1);

date_default_timezone_set('Asia/Ho_Chi_Minh');
require_once dirname(__DIR__) . '/vendor/autoload.php';
require_once __DIR__ . '/ApiError.php';
require_once __DIR__ . '/GoogleIdentity.php';
require_once __DIR__ . '/SupabaseIdentity.php';
require_once __DIR__ . '/AuthService.php';
require_once __DIR__ . '/Http.php';
require_once __DIR__ . '/MailQueue.php';
require_once __DIR__ . '/Environment.php';

function config(): array
{
    $settings = require dirname(__DIR__) . '/config/example.php';
    $local = dirname(__DIR__) . '/config/local.php';
    if (is_file($local)) {
        $settings = array_replace($settings, require $local);
    }
    foreach (array_keys($settings) as $key) {
        if (in_array($key, ['db_host','db_port','db_name','db_user','db_password','db_sslmode'], true)) continue;
        $value = getenv('OURBUDGET_' . strtoupper($key));
        if ($value !== false) {
            $settings[$key] = $value;
        }
    }
    return databaseEnvironment($settings, readEnvironment(dirname(__DIR__) . '/.env'));
}

function database(array $settings): PDO
{
    if ($settings['db_password'] === '<INSERT_DATABASE_PASSWORD>') {
        throw new InvalidArgumentException('Configure DB_PASSWORD in the backend .env file');
    }
    if (!preg_match('/^[a-zA-Z0-9_]+$/D', $settings['db_name'])
        || !preg_match('/^[a-zA-Z0-9.:-]+$/D', $settings['db_host'])
        || !ctype_digit((string) $settings['db_port'])
        || !in_array($settings['db_sslmode'], ['require', 'verify-ca', 'verify-full'], true)) {
        throw new InvalidArgumentException('Invalid database configuration');
    }
    $pdo = new PDO(
        "pgsql:host={$settings['db_host']};port={$settings['db_port']};dbname={$settings['db_name']};sslmode={$settings['db_sslmode']};connect_timeout=5",
        $settings['db_user'], $settings['db_password'],
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_EMULATE_PREPARES => false,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]
    );
    $pdo->exec("SET TIME ZONE 'Asia/Ho_Chi_Minh'");
    return $pdo;
}
