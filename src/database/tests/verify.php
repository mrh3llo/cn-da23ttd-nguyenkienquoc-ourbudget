<?php
declare(strict_types=1);

// Use an empty, disposable database ending in _test. No DROP or external dependencies.
$database = getenv('OURBUDGET_DB_NAME') ?: 'ourbudget_test';
if (!preg_match('/^[a-zA-Z0-9_]+_test$/D', $database)) {
    throw new RuntimeException('The database name must end in _test.');
}
$pdo = new PDO(
    'mysql:host=' . (getenv('OURBUDGET_DB_HOST') ?: '127.0.0.1')
        . ';port=' . (getenv('OURBUDGET_DB_PORT') ?: '3306') . ';dbname=' . $database . ';charset=utf8mb4',
    getenv('OURBUDGET_DB_USER') ?: 'root', getenv('OURBUDGET_DB_PASSWORD') ?: '',
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_EMULATE_PREPARES => false]
);
$passed = 0;
function check(bool $condition, string $name): void
{
    global $passed;
    if (!$condition) {
        throw new RuntimeException('FAIL: ' . $name);
    }
    echo 'PASS: ', $name, PHP_EOL;
    $passed++;
}
function scalar(string $sql): mixed
{
    global $pdo;
    return $pdo->query($sql)->fetchColumn();
}
function rejects(string $sql, int $error, string $name): void
{
    global $pdo;
    $rejected = false;
    $pdo->beginTransaction();
    try {
        $pdo->exec($sql);
    } catch (PDOException $e) {
        if ((int) $e->errorInfo[1] !== $error) {
            throw $e;
        }
        $rejected = true;
    } finally {
        $pdo->rollBack();
    }
    check($rejected, $name);
}

if ((int) scalar('SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE()') !== 0) {
    throw new RuntimeException('Use a new empty test database; existing data is not modified.');
}
foreach (['001_schema.sql', '002_seed_system.sql', '003_seed_demo.sql'] as $file) {
    $pdo->exec(file_get_contents(dirname(__DIR__) . '/' . $file));
    check(true, 'Import ' . $file);
}
echo 'MySQL ', scalar('SELECT VERSION()'), '; PHP ', PHP_VERSION, PHP_EOL;
check((int) scalar("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND engine = 'InnoDB'") === 10, '10 InnoDB tables');
check(scalar('SELECT @@session.time_zone') === '+07:00', 'Vietnam session time zone');
check(scalar('SELECT users_name FROM users WHERE users_id = 1') === 'Tài khoản thử A', 'Vietnamese UTF-8 round trip');
check(password_verify('OurBudgetTest!2026', (string) scalar('SELECT users_password FROM users WHERE users_id = 1')), 'PHP verifies demo password hash');
check((int) scalar('SELECT COUNT(*) FROM users') === 2, 'Two independent demo accounts');
check((int) scalar('SELECT COUNT(*) FROM outcome_categories WHERE users_id IS NULL') === 4, 'Shared system categories');
check((int) scalar('SELECT wallets_id FROM wallets WHERE users_id = 1 AND wallets_is_active = 1 ORDER BY wallets_priority DESC, wallets_id LIMIT 1') === 1, 'Default wallet selection');
check((string) scalar('SELECT wallets_current_balance FROM wallets WHERE wallets_id = 1') === '55000'
    && (string) scalar('SELECT wallets_current_balance FROM wallets WHERE wallets_id = 2') === '30000', 'Expense and transfer fixture balances');
check((string) scalar("SELECT -SUM(transactions_amount) FROM transactions WHERE users_id = 1 AND transactions_type = 'EXPENSE' AND transactions_occurred_at >= '2026-11-01' AND transactions_occurred_at < '2026-12-01'") === '25000', 'Budget excludes transfer and account B');

$insert = 'INSERT INTO transactions (users_id, wallets_id, destination_wallet_id, transactions_type, income_id, outcome_id, transactions_amount, transactions_occurred_at) VALUES ';
rejects($insert . "(1, 3, NULL, 'INCOME', 1, NULL, 1, '2026-11-20')", 1452, 'Reject wallet owned by B');
rejects($insert . "(1, 1, 3, 'TRANSFER', NULL, NULL, 1, '2026-11-20')", 1452, 'Reject transfer to B');
rejects($insert . "(1, 1, 1, 'TRANSFER', NULL, NULL, 1, '2026-11-20')", 3819, 'Reject transfer to same wallet');
rejects($insert . "(1, 1, NULL, 'TRANSFER', NULL, NULL, 1, '2026-11-20')", 3819, 'Reject transfer without destination');
rejects($insert . "(1, 1, NULL, 'EXPENSE', NULL, 1, 1, '2026-11-20')", 3819, 'Reject positive expense');
rejects($insert . "(1, 1, NULL, 'INCOME', 1, NULL, 0, '2026-11-20')", 3819, 'Reject zero income');
rejects($insert . "(1, 1, NULL, 'INCOME', NULL, NULL, 1, '2026-11-20')", 3819, 'Reject missing category even when nullable');
rejects($insert . "(1, 1, NULL, 'INCOME', 1, 1, 1, '2026-11-20')", 3819, 'Reject both category types');
rejects($insert . "(1, 1, NULL, 'EXPENSE', NULL, 99999, -1, '2026-11-20')", 1452, 'Reject missing category reference');
rejects('DELETE FROM wallets WHERE wallets_id = 1', 1451, 'Protect wallet history');
rejects('DELETE FROM outcome_categories WHERE outcome_id = 1', 1451, 'Protect category history');
rejects("UPDATE users SET users_email = 'DEMO.A@ourbudget.test' WHERE users_id = 2", 1062, 'Reject duplicate email case-insensitively');
rejects('UPDATE budgets SET budgets_amount_limit = 0 WHERE budgets_id = 1', 3819, 'Reject nonpositive budget');
rejects("UPDATE budgets SET budgets_end = '2026-10-31' WHERE budgets_id = 1", 3819, 'Reject reversed period');
rejects('UPDATE wallets SET wallets_is_active = 2 WHERE wallets_id = 1', 3819, 'Reject invalid active state');

$pdo->beginTransaction();
try {
    $pdo->exec('UPDATE wallets SET wallets_current_balance = 9223372036854775807 WHERE wallets_id = 1');
    check((string) scalar('SELECT wallets_current_balance FROM wallets WHERE wallets_id = 1') === '9223372036854775807', 'Exact BIGINT maximum');
    $pdo->exec('UPDATE wallets SET wallets_is_active = 0 WHERE wallets_id = 1');
    check((int) scalar('SELECT COUNT(*) FROM transactions WHERE wallets_id = 1') === 2, 'Deactivation preserves history');
} finally {
    $pdo->rollBack();
}

$idempotency = "INSERT INTO idempotency_keys (users_id, operation, idempotency_key, request_hash, response_status, response_body) VALUES (1, 'transactions.create', 'fixture-key', UNHEX(SHA2('fixture-request', 256)), 201, '{\"amount\":\"1\"}')";
$pdo->beginTransaction();
try {
    $pdo->exec($idempotency);
    $duplicate = false;
    try {
        $pdo->exec($idempotency);
    } catch (PDOException $e) {
        if ((int) $e->errorInfo[1] !== 1062) {
            throw $e;
        }
        $duplicate = true;
    }
    check($duplicate, 'Idempotency uniqueness per user and operation');
    $pdo->exec(str_replace("(1, 'transactions.create'", "(2, 'transactions.create'", $idempotency));
    check((int) scalar('SELECT COUNT(*) FROM idempotency_keys') === 2, 'Same key allowed for another account');
    $pdo->query('SELECT wallets_id FROM wallets WHERE wallets_id = 1 FOR UPDATE')->fetchAll();
    $pdo->exec($insert . "(1, 1, NULL, 'EXPENSE', NULL, 1, -100, '2026-11-20')");
    $pdo->exec('UPDATE wallets SET wallets_current_balance = wallets_current_balance - 100 WHERE wallets_id = 1');
    try {
        $pdo->exec($insert . "(1, 3, NULL, 'EXPENSE', NULL, 1, -100, '2026-11-20')");
        throw new RuntimeException('Expected foreign key failure');
    } catch (PDOException $e) {
        if ((int) $e->errorInfo[1] !== 1452) {
            throw $e;
        }
    }
} finally {
    $pdo->rollBack();
}
check((int) scalar('SELECT COUNT(*) FROM transactions') === 3
    && (int) scalar('SELECT COUNT(*) FROM idempotency_keys') === 0
    && (string) scalar('SELECT wallets_current_balance FROM wallets WHERE wallets_id = 1') === '55000', 'Explicit rollback restores ledger, balance and idempotency record');

rejects("INSERT INTO auth_sessions (users_id, token_hash, created_at, expires_at) VALUES (1, UNHEX(SHA2('test', 256)), '2026-11-20', '2026-11-19')", 3819, 'Reject invalid session lifetime');
rejects("INSERT INTO password_resets (users_id, token_hash, created_at, expires_at) VALUES (1, UNHEX(SHA2('test', 256)), '2026-11-20', '2026-11-19')", 3819, 'Reject invalid reset lifetime');
echo 'RESULT: ', $passed, '/', $passed, ' passed', PHP_EOL;
