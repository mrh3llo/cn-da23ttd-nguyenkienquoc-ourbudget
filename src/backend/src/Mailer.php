<?php
declare(strict_types=1);

use PHPMailer\PHPMailer\PHPMailer;

require dirname(__DIR__) . '/vendor/autoload.php';

function deliverMail(array $row, array $settings): void
{
    $mail = new PHPMailer(true);
    $mail->CharSet = 'UTF-8';
    $mail->setFrom($settings['mail_from'], 'OurBudget');
    $mail->addAddress($row['recipient']);
    $mail->Subject = Outbox::SUBJECTS[$row['event_type']];
    $mail->MessageID = '<' . hash('sha256', $row['event_id']) . '@' . substr(strrchr($settings['mail_from'], '@'), 1) . '>';
    $payload = json_decode($row['payload'], true, flags: JSON_THROW_ON_ERROR);
    $mail->Body = $mail->Subject . ".\n";
    // Only explicit fields enter messages. Never dump the entire stored payload.
    foreach (['amount', 'occurred_at'] as $key) {
        if (isset($payload[$key]) && is_string($payload[$key])) {
            $mail->Body .= $key . ': ' . $payload[$key] . "\n";
        }
    }
    if ($row['event_type'] === 'email.verify') {
        $url = $payload['verification_url'] ?? '';
        if (!is_string($url) || !filter_var($url, FILTER_VALIDATE_URL) || parse_url($url, PHP_URL_SCHEME) !== 'https') {
            throw new InvalidArgumentException('Verification requires an HTTPS URL');
        }
        $mail->Body .= $url . "\n";
    }
    if ($settings['mail_transport'] === 'file') {
        $mail->preSend();
        $directory = dirname(__DIR__) . '/storage/mail';
        if (!is_dir($directory) && !mkdir($directory, 0700, true) && !is_dir($directory)) {
            throw new RuntimeException('Cannot create local mailbox');
        }
        $path = $directory . '/' . hash('sha256', $row['event_id']) . '.eml';
        if (file_put_contents($path, $mail->getSentMIMEMessage(), LOCK_EX) === false) {
            throw new RuntimeException('Cannot write local mailbox');
        }
        return;
    }
    if ($settings['mail_transport'] !== 'smtp' || !in_array($settings['smtp_encryption'], ['tls', 'ssl'], true)) {
        throw new InvalidArgumentException('SMTP requires TLS or SSL');
    }
    $mail->isSMTP();
    $mail->Host = $settings['smtp_host'];
    $mail->Port = (int) $settings['smtp_port'];
    $mail->SMTPAuth = true;
    $mail->Username = $settings['smtp_username'];
    $mail->Password = $settings['smtp_password'];
    $mail->SMTPSecure = $settings['smtp_encryption'];
    $mail->Timeout = 10;
    $mail->Timelimit = 15;
    $mail->send();
}
