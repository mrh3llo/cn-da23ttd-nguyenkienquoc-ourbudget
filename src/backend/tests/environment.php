<?php
declare(strict_types=1);
require dirname(__DIR__).'/src/bootstrap.php';
$file = tempnam(sys_get_temp_dir(), 'ourbudget-env-');
$passed = 0;
function envCheck(bool $value): void { global $passed; if (!$value) throw new RuntimeException('Environment test failed'); $passed++; }
try {
    file_put_contents($file, "# comment\nDB_PASSWORD='a # b=\$literal'\nDB_PORT=5432\nDB_HOST=localhost\nDB_SSLMODE=require\n");
    $values=readEnvironment($file);
    envCheck($values['DB_PASSWORD']==='a # b=$literal');
    envCheck($values['DB_PORT']==='5432');
    envCheck(databaseEnvironment([], $values)['db_sslmode']==='require');
    envCheck(databaseEnvironment(['db_host'=>'old'], $values)['db_host']==='localhost');
    putenv('OURBUDGET_DB_HOST=legacy');
    envCheck(databaseEnvironment([], $values)['db_host']==='localhost');
    putenv('DB_HOST=process');
    envCheck(databaseEnvironment([], $values)['db_host']==='process');
    putenv('DB_PASSWORD=');
    envCheck(databaseEnvironment([], $values)['db_password']==='');
    foreach (["DB_PASSWORD='secret", "DB_HOST=a\nDB_HOST=b", 'not-valid'] as $invalid) {
        file_put_contents($file,$invalid); $rejected=false;
        try {readEnvironment($file);} catch (RuntimeException $e) {$rejected=true; envCheck(!str_contains($e->getMessage(),'secret'));}
        envCheck($rejected);
    }
    envCheck(readEnvironment($file.'.missing')===[]);
    $defaults=require dirname(__DIR__).'/config/example.php';
    $defaults['db_password']='test-only-password';
    foreach (['db_host'=>'bad;host', 'db_port'=>'not-a-port', 'db_name'=>'bad/name', 'db_sslmode'=>'disable'] as $key=>$value) {
        $rejected=false;
        try {database(array_replace($defaults,[$key=>$value]));} catch (InvalidArgumentException) {$rejected=true;}
        envCheck($rejected);
    }
    echo "Environment: $passed passed\n";
} finally { unlink($file); foreach (['DB_HOST','DB_PASSWORD','OURBUDGET_DB_HOST'] as $key) putenv($key); }
