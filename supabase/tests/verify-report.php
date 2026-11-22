<?php
declare(strict_types=1);
require_once dirname(__DIR__,2).'/src/backend/src/bootstrap.php';
$settings=config();
if (!str_ends_with($settings['db_name'],'_test')) throw new RuntimeException('Use a disposable _test database');
$pdo=database($settings);
$expected=['budgets','income_categories','outcome_categories','transactions','users','wallet_categories','wallets'];
$actual=$pdo->query("SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_name IN ('budgets','income_categories','outcome_categories','transactions','users','wallet_categories','wallets') ORDER BY table_name")->fetchAll(PDO::FETCH_COLUMN);
if ($actual!==$expected) throw new RuntimeException('Expected the seven report entities');
$columns=$pdo->query("SELECT table_name,column_name,data_type FROM information_schema.columns WHERE table_schema='public'")->fetchAll();
$found=[];
foreach ($columns as $column) $found[$column['table_name']][$column['column_name']]=$column['data_type'];
foreach (['users'=>[['users_phonenumber','character varying'],['users_sessions_hash','bytea']],'wallet_categories'=>[['walletcates_id','bigint']],'transactions'=>[['destination_wallet_id','integer']],'budgets'=>[['budgets_amount_limit','numeric']]] as $table=>$specs) {
    foreach ($specs as [$column,$type]) if (($found[$table][$column]??null)!==$type) throw new RuntimeException("Unexpected PostgreSQL type for $table.$column");
}
if (isset($found['transactions']['transactions_type'])) throw new RuntimeException('transactions_type must not exist');
$rls=$pdo->query("SELECT relname,relrowsecurity FROM pg_class JOIN pg_namespace ON pg_namespace.oid=relnamespace WHERE nspname='public' AND relname IN ('users','wallet_categories','wallets','income_categories','outcome_categories','transactions','budgets')")->fetchAll(PDO::FETCH_KEY_PAIR);
if (count($rls)!==7 || count(array_filter($rls,fn($value)=>$value==='t' || $value===true))!==7) throw new RuntimeException('RLS must be enabled for all seven tables');
$publicAccess=$pdo->query("SELECT has_table_privilege('anon','public.users','SELECT') OR has_table_privilege('authenticated','public.users','SELECT')")->fetchColumn();
if ($publicAccess==='t' || $publicAccess===true || $publicAccess===1) throw new RuntimeException('Client roles must not have direct table access');
echo "PostgreSQL schema: seven entities, documented types, no transactions_type, RLS enabled.\n";
