<?php
declare(strict_types=1);

require __DIR__ . '/verify.php';
require dirname(__DIR__, 2) . '/backend/src/bootstrap.php';
require dirname(__DIR__, 2) . '/backend/src/Mailer.php';

$before = $pdo->query('SELECT wallets_id, wallets_current_balance FROM wallets ORDER BY wallets_id')->fetchAll(PDO::FETCH_ASSOC);
$pdo->exec(file_get_contents(dirname(__DIR__) . '/004_step03_foundation.sql'));
$pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
check((int) scalar('SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE()') === 14, '14 tables after upgrade');
check($pdo->query('SELECT wallets_id, wallets_current_balance FROM wallets ORDER BY wallets_id')->fetchAll() === $before, 'Upgrade preserves existing balances and IDs');
check($pdo->query('SELECT wallets_priority FROM wallets ORDER BY wallets_id')->fetchAll(PDO::FETCH_COLUMN) === [0, 1, 0], 'Legacy seed becomes priorities 0,1,0');
check((int) scalar('SELECT wallets_id FROM wallets WHERE users_id = 1 AND wallets_is_active = 1 ORDER BY wallets_priority, wallets_id LIMIT 1') === 1, 'Default wallet preserved with ASC order');
check((int) scalar('SELECT COUNT(*) FROM users WHERE email_verified_at IS NOT NULL') === 0, 'Upgrade never marks legacy emails verified');
rejects('UPDATE wallets SET wallets_priority = -1 WHERE wallets_id = 1', 3819, 'Reject negative priority');
rejects('UPDATE wallets SET wallets_priority = 0 WHERE wallets_id = 2', 1062, 'Reject two active defaults');
$pdo->beginTransaction();
$pdo->exec('UPDATE users SET users_password = NULL WHERE users_id = 1');
check(scalar('SELECT users_password FROM users WHERE users_id = 1') === null, 'Google-only password can be null');
$pdo->exec("INSERT INTO user_identities (users_id, provider, provider_subject) VALUES (1, 'google', 'test-subject')");
$pdo->commit();
rejects("INSERT INTO user_identities (users_id, provider, provider_subject) VALUES (2, 'google', 'test-subject')", 1062, 'Google subject cannot belong to two users');
rejects("INSERT INTO user_identities (users_id, provider, provider_subject) VALUES (1, 'google', 'other-subject')", 1062, 'One Google identity per user');
rejects("INSERT INTO email_verifications (users_id,email,token_hash,expires_at) VALUES (1,'demo.a@ourbudget.test',UNHEX(SHA2('x',256)), '2000-01-01')", 3819, 'Reject expired-at-creation verification');

$outsideRejected = false;
try {
    Outbox::enqueue($pdo, 1, 'outside', 'auth.login');
} catch (LogicException) {
    $outsideRejected = true;
}
check($outsideRejected, 'Outbox requires transaction');
$pdo->beginTransaction();
check(!Outbox::enqueue($pdo, 1, 'unverified', 'transaction.created'), 'Unverified email gets no financial notification');
$pdo->rollBack();
$pdo->exec('UPDATE users SET email_verified_at = NOW() WHERE users_id = 1');
$pdo->beginTransaction();
$pdo->exec('UPDATE wallets SET wallets_current_balance = wallets_current_balance - 1 WHERE wallets_id = 1');
Outbox::enqueue($pdo, 1, 'rollback', 'transaction.created', ['amount' => '-1']);
$pdo->rollBack();
check((int) scalar('SELECT COUNT(*) FROM email_outbox') === 0 && (string) scalar('SELECT wallets_current_balance FROM wallets WHERE wallets_id=1') === '55000', 'Rollback removes outbox and balance write together');

function queueEvent(string $id): void
{
    global $pdo;
    $pdo->beginTransaction();
    Outbox::enqueue($pdo, 1, $id, 'transaction.created', ['amount' => '-25000', 'occurred_at' => '2026-11-20T10:00:00+07:00']);
    $pdo->commit();
}
queueEvent('committed');
$pdo->beginTransaction();
$duplicate = false;
try {
    Outbox::enqueue($pdo, 1, 'committed', 'transaction.created');
} catch (PDOException $e) {
    $duplicate = (int) $e->errorInfo[1] === 1062;
} finally {
    $pdo->rollBack();
}
check($duplicate, 'Unique event prevents duplicate outbox');
$connection = database(config());
$pdo->beginTransaction();
$pdo->query("SELECT outbox_id FROM email_outbox WHERE event_id='committed' FOR UPDATE")->fetch();
check(Outbox::claim($connection) === null, 'Second worker skips locked row');
$pdo->rollBack();
$firstClaim = Outbox::claim($pdo);
check($firstClaim !== null && !$pdo->inTransaction() && Outbox::claim($connection) === null, 'Claim commits before delivery and excludes competing worker');
$pdo->exec("UPDATE email_outbox SET locked_until=DATE_SUB(NOW(),INTERVAL 1 SECOND) WHERE event_id='committed'");
$secondClaim = Outbox::claim($connection);
check($secondClaim['attempts'] === 2 && $secondClaim['claim_token'] !== $firstClaim['claim_token'], 'Expired lease can be reclaimed');
Outbox::finish($pdo, $firstClaim, 'sent');
check(scalar("SELECT status FROM email_outbox WHERE event_id='committed'") === 'processing', 'Stale worker cannot overwrite new claim');
Outbox::finish($connection, $secondClaim, 'sent');

queueEvent('retry');
Outbox::workOne($pdo, static function (): void { throw new RuntimeException('secret-smtp-password'); });
check(scalar("SELECT status FROM email_outbox WHERE event_id='retry'") === 'pending'
    && scalar("SELECT last_error FROM email_outbox WHERE event_id='retry'") === 'delivery_failed'
    && (int) scalar("SELECT next_attempt_at > NOW() FROM email_outbox WHERE event_id='retry'") === 1, 'Delivery failure schedules retry without leaking credentials');
check((string) scalar('SELECT wallets_current_balance FROM wallets WHERE wallets_id=1') === '55000', 'SMTP failure does not touch finance');
$pdo->exec("UPDATE email_outbox SET attempts=5,next_attempt_at=NOW() WHERE event_id='retry'");
$called = false;
Outbox::workOne($pdo, static function () use (&$called): void { $called = true; });
check(!$called && scalar("SELECT status FROM email_outbox WHERE event_id='retry'") === 'failed', 'Exhausted retries never deliver');
queueEvent('changed-email');
$pdo->exec("UPDATE users SET users_email='changed@ourbudget.test',email_verified_at=NULL WHERE users_id=1");
Outbox::workOne($pdo, static function () use (&$called): void { $called = true; });
check(!$called && scalar("SELECT status FROM email_outbox WHERE event_id='changed-email'") === 'cancelled', 'Changed recipient cancels queued financial email');
$pdo->exec("UPDATE users SET users_email='demo.a@ourbudget.test',email_verified_at=NOW() WHERE users_id=1");
queueEvent('local-mail');
$settings = config();
$settings['mail_transport'] = 'file';
Outbox::workOne($pdo, fn(array $row) => deliverMail($row, $settings));
$message = file_get_contents(dirname(__DIR__, 2) . '/backend/storage/mail/' . hash('sha256', 'local-mail') . '.eml');
check(scalar("SELECT status FROM email_outbox WHERE event_id='local-mail'") === 'sent' && str_contains($message, '-25000') && str_contains($message, hash('sha256', 'local-mail')), 'Local MIME transport renders amount and stable Message-ID');
check(Outbox::claim($pdo) === null, 'Completed rows are not claimed again');
echo "FOUNDATION RESULT: $passed/$passed passed\n";
