<?php
declare(strict_types=1);

// Deliberately literal: no variable interpolation, escapes or shell evaluation.
function readEnvironment(string $path): array
{
    if (!is_file($path)) return [];
    $lines = file($path, FILE_IGNORE_NEW_LINES);
    if ($lines === false) throw new RuntimeException('Cannot read environment configuration');
    $values = [];
    foreach ($lines as $index => $line) {
        $line = trim($index === 0 ? preg_replace('/^\xEF\xBB\xBF/', '', $line) : $line);
        if ($line === '' || str_starts_with($line, '#')) continue;
        if (!preg_match('/^([A-Z][A-Z0-9_]*)\s*=\s*(.*)$/D', $line, $match)) {
            throw new RuntimeException('Invalid environment configuration line '.($index + 1));
        }
        $value = trim($match[2]);
        if ($value !== '' && ($value[0] === '"' || $value[0] === "'")) {
            if (strlen($value) < 2 || substr($value, -1) !== $value[0]) {
                throw new RuntimeException('Invalid environment quote on line '.($index + 1));
            }
            $value = substr($value, 1, -1);
        }
        if (array_key_exists($match[1], $values)) throw new RuntimeException('Duplicate environment key');
        $values[$match[1]] = $value;
    }
    return $values;
}

function databaseEnvironment(array $settings, array $file): array
{
    foreach (['DB_HOST'=>'db_host', 'DB_PORT'=>'db_port', 'DB_DATABASE'=>'db_name',
        'DB_USERNAME'=>'db_user', 'DB_PASSWORD'=>'db_password', 'DB_SSLMODE'=>'db_sslmode'] as $key=>$setting) {
        $value = getenv($key);
        if ($value !== false) $settings[$setting] = $value;
        elseif (array_key_exists($key, $file)) $settings[$setting] = $file[$key];
    }
    foreach (['SUPABASE_URL'=>'supabase_url', 'SUPABASE_PUBLISHABLE_KEY'=>'supabase_publishable_key'] as $key=>$setting) {
        $value = getenv($key);
        if ($value !== false) $settings[$setting] = $value;
        elseif (array_key_exists($key, $file)) $settings[$setting] = $file[$key];
    }
    return $settings;
}
