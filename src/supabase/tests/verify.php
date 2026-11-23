<?php
declare(strict_types=1);
require_once dirname(__DIR__,2).'/src/backend/src/bootstrap.php';
$settings=config();
if (!str_ends_with($settings['db_name'],'_test')) throw new RuntimeException('Use a disposable _test database');
$pdo=database($settings);
if ((int)$pdo->query("SELECT count(*) FROM information_schema.tables WHERE table_schema='public' AND table_name IN ('users','wallet_categories','wallets','income_categories','outcome_categories','transactions','budgets')")->fetchColumn()!==0) throw new RuntimeException('Use a test database without OurBudget tables');
foreach (glob(dirname(__DIR__,2).'/migrations/*.sql') as $migration) $pdo->exec(file_get_contents($migration));
$pdo->beginTransaction();
try {
    $pdo->exec("INSERT INTO users(users_name,users_email) VALUES('Test','finance@ourbudget.test')");
    $user=(int)$pdo->query('SELECT users_id FROM users')->fetchColumn();
    $walletCategory=(int)$pdo->query('SELECT walletcates_id FROM wallet_categories ORDER BY walletcates_id LIMIT 1')->fetchColumn();
    $incomeCategory=(int)$pdo->query('SELECT income_id FROM income_categories ORDER BY income_id LIMIT 1')->fetchColumn();
    $expenseCategory=(int)$pdo->query('SELECT outcome_id FROM outcome_categories ORDER BY outcome_id LIMIT 1')->fetchColumn();
    $wallet=$pdo->prepare('INSERT INTO wallets(users_id,walletcates_id,wallets_name) VALUES(?,?,?) RETURNING wallets_id');
    $wallet->execute([$user,$walletCategory,'Source']);$source=(int)$wallet->fetchColumn();
    $wallet->execute([$user,$walletCategory,'Destination']);$destination=(int)$wallet->fetchColumn();
    $insert=$pdo->prepare('INSERT INTO transactions(users_id,wallets_id,destination_wallet_id,income_id,outcome_id,transactions_amount,transactions_occured_at) VALUES(?,?,?,?,?,?,CURRENT_TIMESTAMP)');
    $insert->execute([$user,$source,null,$incomeCategory,null,10000]);
    $pdo->exec("UPDATE wallets SET wallets_current_balance=wallets_current_balance+10000 WHERE wallets_id=$source");
    $insert->execute([$user,$source,null,null,$expenseCategory,-2500]);
    $pdo->exec("UPDATE wallets SET wallets_current_balance=wallets_current_balance-2500 WHERE wallets_id=$source");
    $insert->execute([$user,$source,$destination,null,null,3000]);
    $pdo->exec("UPDATE wallets SET wallets_current_balance=wallets_current_balance-3000 WHERE wallets_id=$source");
    $pdo->exec("UPDATE wallets SET wallets_current_balance=wallets_current_balance+3000 WHERE wallets_id=$destination");
    $sum=$pdo->prepare('SELECT COALESCE(SUM(CASE WHEN transactions_amount>0 THEN transactions_amount ELSE 0 END),0) income, COALESCE(-SUM(CASE WHEN transactions_amount<0 THEN transactions_amount ELSE 0 END),0) expense FROM transactions WHERE users_id=? AND destination_wallet_id IS NULL');
    $sum->execute([$user]);$totals=$sum->fetch();
    if ((int)$totals['income']!==10000 || (int)$totals['expense']!==2500) throw new RuntimeException('Income/expense totals must exclude transfers');
    $balances=$pdo->query("SELECT wallets_id,wallets_current_balance FROM wallets WHERE users_id=$user ORDER BY wallets_id")->fetchAll(PDO::FETCH_KEY_PAIR);
    if ((int)$balances[$source]!==4500 || (int)$balances[$destination]!==3000 || array_sum($balances)!==7500) throw new RuntimeException('Transfer must move funds without changing aggregate balance');
    $pdo->rollBack();
} catch (Throwable $error) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    throw $error;
}
echo "PostgreSQL migration and transaction classification passed; test rows rolled back.\n";
