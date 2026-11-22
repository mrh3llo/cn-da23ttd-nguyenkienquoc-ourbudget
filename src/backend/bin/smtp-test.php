<?php
declare(strict_types=1);
require dirname(__DIR__) . '/src/bootstrap.php';
require dirname(__DIR__) . '/src/Mailer.php';
if (PHP_SAPI !== 'cli' || !filter_var($argv[1] ?? '', FILTER_VALIDATE_EMAIL)) {
    fwrite(STDERR, "Usage: php bin/smtp-test.php recipient@example.com\n");
    exit(1);
}
try {
    $settings = config();
    if ($settings['smtp_password'] === '') throw new RuntimeException('SMTP credential missing');
    $settings['mail_transport'] = 'smtp';
    deliverMail(['recipient'=>$argv[1], 'event_id'=>'smtp-test:'.bin2hex(random_bytes(8)), 'event_type'=>'auth.login', 'payload'=>'{}'], $settings, 'OurBudget - Kiểm tra kết nối SMTP');
    echo "SMTP accepted test email. Check recipient inbox/spam.\n";
} catch (Throwable $e) {
    $message = strtolower($e->getMessage());
    $reason = str_contains($message, 'authenticate') ? 'authentication_rejected'
        : (str_contains($message, 'connect') ? 'connection_or_tls_failed'
        : (str_contains($message, 'credential') ? 'credential_missing' : 'delivery_failed'));
    fwrite(STDERR, "SMTP test failed: $reason. Credentials are not printed.\n");
    exit(1);
}
