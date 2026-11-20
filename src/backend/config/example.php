<?php
declare(strict_types=1);

// Copy to local.php (ignored by Git); never put credentials in public/.
return [
    'db_host' => '127.0.0.1',
    'db_port' => 3306,
    'db_name' => 'ourbudget',
    'db_user' => 'ourbudget_app',
    'db_password' => '',
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
