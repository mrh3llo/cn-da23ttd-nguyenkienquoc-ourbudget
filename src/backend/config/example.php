<?php
declare(strict_types=1);

// Copy to local.php (ignored by Git); never put credentials in public/.
return [
    'runtime_directory' => dirname(__DIR__) . '/storage/runtime',
'db_host' => 'db.ohztwpsabwfhovrcvxnq.supabase.co',
'db_port' => 5432,
'db_name' => 'postgres',
'db_user' => 'postgres',
'db_password' => '<INSERT_DATABASE_PASSWORD>',
'db_sslmode' => 'require',
'supabase_url' => '',
'supabase_publishable_key' => '',
    'google_server_client_id' => '171608086306-eov7trctrio9s8jpof6g8bu2k8qemg4n.apps.googleusercontent.com',
    // file is a local development mailbox; smtp requires explicit configuration.
    'mail_transport' => 'file',
    'mail_from' => 'noreply@ourbudget.test',
    'smtp_host' => '',
    'smtp_port' => 587,
    'smtp_username' => '',
    'smtp_password' => '',
    'smtp_encryption' => 'tls',
];
