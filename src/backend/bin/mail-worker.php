<?php
declare(strict_types=1);

require dirname(__DIR__) . '/src/bootstrap.php';
require dirname(__DIR__) . '/src/Mailer.php';
if (PHP_SAPI !== 'cli') {
    exit(1);
}
try {
    $settings = config();
    $pdo = database($settings);
    // One bounded batch per invocation; schedule every minute with Task Scheduler/cron.
    $limit = in_array('--once', $argv, true) ? 1 : 50;
    $processed = 0;
    while ($processed < $limit && MailQueue::workOne($pdo, fn(array $row) => deliverMail($row, $settings))) {
        $processed++;
    }
    echo "Processed: $processed\n";
} catch (Throwable $e) {
    fwrite(STDERR, 'Worker unavailable: ' . get_class($e) . PHP_EOL);
    exit(1);
}
