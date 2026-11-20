<?php
declare(strict_types=1);

require dirname(__DIR__, 2) . '/backend/src/bootstrap.php';
$pdo = database(config());
$tables = $pdo->query('SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() ORDER BY TABLE_NAME')->fetchAll(PDO::FETCH_COLUMN);
$text = "# Đối chiếu mô hình với schema MySQL bước 03\n\n";
$text .= "Sinh từ metadata của MySQL sau migration 004; chỉ đọc cấu trúc, không xuất dữ liệu cá nhân. SQL 001–004 là nguồn triển khai. Bản đối chiếu này không thay thế tệp PowerDesigner đã mở và nghiệm thu.\n\n";
$text .= "ERD/PDM gốc ở `src/dgr/database-dgr/` có 7 thực thể nghiệp vụ và PDM đích SAP SQL Anywhere 17. Giữ các bản đang được chỉnh sửa; cần đồng bộ bản native sang MySQL 8 trước khi dùng PowerDesigner sinh DDL. Bảng kỹ thuật bổ sung: auth_sessions, password_resets, idempotency_keys, user_identities, email_verifications, email_outbox, schema_migrations.\n\n";
foreach ($tables as $table) {
    $text .= "## $table\n\n| Cột | Kiểu | NULL | Extra |\n| --- | --- | --- | --- |\n";
    $query = $pdo->prepare('SELECT COLUMN_NAME,COLUMN_TYPE,IS_NULLABLE,EXTRA FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? ORDER BY ORDINAL_POSITION');
    $query->execute([$table]);
    foreach ($query as $column) {
        $text .= '| ' . implode(' | ', $column) . " |\n";
    }
    $query = $pdo->prepare('SELECT INDEX_NAME,NON_UNIQUE,GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns_list FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? GROUP BY INDEX_NAME,NON_UNIQUE ORDER BY INDEX_NAME');
    $query->execute([$table]);
    $text .= "\nChỉ mục:\n\n";
    foreach ($query as $index) {
        $text .= '- `' . $index['INDEX_NAME'] . '` (' . $index['columns_list'] . ')' . ($index['NON_UNIQUE'] ? '' : ' UNIQUE') . ".\n";
    }
    $query = $pdo->prepare('SELECT CONSTRAINT_NAME,COLUMN_NAME,REFERENCED_TABLE_NAME,REFERENCED_COLUMN_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND REFERENCED_TABLE_NAME IS NOT NULL ORDER BY CONSTRAINT_NAME,ORDINAL_POSITION');
    $query->execute([$table]);
    $references = $query->fetchAll();
    if ($references) {
        $text .= "\nKhóa ngoại (các dòng cùng tên thuộc một khóa ghép):\n\n";
        foreach ($references as $reference) {
            $text .= '- `' . $reference['CONSTRAINT_NAME'] . '`: `' . $reference['COLUMN_NAME'] . '` → `' . $reference['REFERENCED_TABLE_NAME'] . '.' . $reference['REFERENCED_COLUMN_NAME'] . "`.\n";
        }
    }
    $text .= "\n";
}
file_put_contents(dirname(__DIR__) . '/model-reference.md', $text);
echo count($tables) . " tables exported (metadata only)\n";
