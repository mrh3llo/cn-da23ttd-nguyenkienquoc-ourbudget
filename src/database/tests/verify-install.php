<?php
declare(strict_types=1);

require dirname(__DIR__, 2) . '/backend/src/bootstrap.php';
require dirname(__DIR__, 2) . '/backend/src/Mailer.php';
$settings = config();
if (!preg_match('/^[a-zA-Z0-9_]+_test$/D', $settings['db_name'])) {
    throw new RuntimeException('Use an empty database ending in _test');
}
$pdo = database($settings);
if ((int) $pdo->query('SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE()')->fetchColumn() !== 0) {
    throw new RuntimeException('Database must be empty');
}
$passed = 0;
function verifyInstall(bool $value, string $name): void
{
    global $passed;
    if (!$value) {
        throw new RuntimeException('FAIL: ' . $name);
    }
    echo "PASS: $name\n";
    $passed++;
}
foreach (['001_schema.sql', '002_seed_system.sql', '004_step03_foundation.sql'] as $file) {
    $pdo->exec(file_get_contents(dirname(__DIR__) . '/' . $file));
}
verifyInstall((int) $pdo->query('SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE()')->fetchColumn() === 14, 'Fresh install without demo has 14 tables');
verifyInstall((int) $pdo->query('SELECT COUNT(*) FROM users')->fetchColumn() === 0, 'Fresh install has no public demo accounts');
verifyInstall((int) $pdo->query('SELECT COUNT(*) FROM outcome_categories')->fetchColumn() === 4, 'Fresh install retains shared categories');
$pdo->exec("INSERT INTO users (users_name,users_email) VALUES ('Verification test','verification@ourbudget.test')");
$pdo->exec("INSERT INTO email_verifications (users_id,email,token_hash,expires_at) VALUES (1,'verification@ourbudget.test',UNHEX(SHA2('test-token',256)),DATE_ADD(NOW(),INTERVAL 30 MINUTE))");
$pdo->beginTransaction();
$rejected = false;
try {
    Outbox::enqueue($pdo, 1, 'wrong-verification', 'email.verify', ['verification_id' => 999]);
} catch (InvalidArgumentException) {
    $rejected = true;
} finally {
    $pdo->rollBack();
}
verifyInstall($rejected, 'Verification event requires a pending token for this recipient');
$payload = ['verification_id' => 1, 'verification_url' => 'https://ourbudget.test/verify?token=test-token'];
$pdo->beginTransaction();
verifyInstall(Outbox::enqueue($pdo, 1, 'verify-local', 'email.verify', $payload), 'Verification mail may target an unverified email');
$pdo->commit();
$settings['mail_transport'] = 'file';
Outbox::workOne($pdo, fn(array $row) => deliverMail($row, $settings));
verifyInstall($pdo->query("SELECT status FROM email_outbox WHERE event_id='verify-local'")->fetchColumn() === 'sent', 'Verification renders into local mailbox');
$pdo->beginTransaction();
Outbox::enqueue($pdo, 1, 'verify-used', 'email.verify', $payload);
$pdo->commit();
$pdo->exec('UPDATE email_verifications SET used_at=NOW()');
$sent = false;
Outbox::workOne($pdo, static function () use (&$sent): void { $sent = true; });
verifyInstall(!$sent && $pdo->query("SELECT status FROM email_outbox WHERE event_id='verify-used'")->fetchColumn() === 'cancelled', 'Already-used verification is cancelled before delivery');
echo "INSTALL RESULT: $passed/$passed passed\n";
