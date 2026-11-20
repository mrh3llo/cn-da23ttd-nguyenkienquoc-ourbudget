<?php
declare(strict_types=1);

date_default_timezone_set('Asia/Ho_Chi_Minh');
require_once __DIR__ . '/Http.php';
require_once __DIR__ . '/Outbox.php';

function config(): array
{
    $settings = require dirname(__DIR__) . '/config/example.php';
    $local = dirname(__DIR__) . '/config/local.php';
    if (is_file($local)) {
        $settings = array_replace($settings, require $local);
    }
    foreach (array_keys($settings) as $key) {
        $value = getenv('OURBUDGET_' . strtoupper($key));
        if ($value !== false) {
            $settings[$key] = $value;
        }
    }
    return $settings;
}

function database(array $settings): PDO
{
    if (!preg_match('/^[a-zA-Z0-9_]+$/D', $settings['db_name'])
        || !preg_match('/^[a-zA-Z0-9.:-]+$/D', $settings['db_host'])
        || !ctype_digit((string) $settings['db_port'])) {
        throw new InvalidArgumentException('Invalid database configuration');
    }
    $pdo = new PDO(
        "mysql:host={$settings['db_host']};port={$settings['db_port']};dbname={$settings['db_name']};charset=utf8mb4",
        $settings['db_user'], $settings['db_password'],
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_EMULATE_PREPARES => false,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC, PDO::ATTR_TIMEOUT => 5]
    );
    $pdo->exec("SET SESSION time_zone = '+07:00'");
    $pdo->exec("SET SESSION sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'");
    return $pdo;
}
