# Đối chiếu mô hình với schema MySQL bước 03

Sinh từ metadata của MySQL sau migration 004; chỉ đọc cấu trúc, không xuất dữ liệu cá nhân. SQL 001–004 là nguồn triển khai. Bản đối chiếu này không thay thế tệp PowerDesigner đã mở và nghiệm thu.

ERD/PDM gốc ở `src/dgr/database-dgr/` có 7 thực thể nghiệp vụ và PDM đích SAP SQL Anywhere 17. Giữ các bản đang được chỉnh sửa; cần đồng bộ bản native sang MySQL 8 trước khi dùng PowerDesigner sinh DDL. Bảng kỹ thuật bổ sung: auth_sessions, password_resets, idempotency_keys, user_identities, email_verifications, email_outbox, schema_migrations.

## auth_sessions

| Cột | Kiểu | NULL | Extra |
| --- | --- | --- | --- |
| session_id | bigint unsigned | NO | auto_increment |
| users_id | bigint unsigned | NO |  |
| token_hash | binary(32) | NO |  |
| created_at | datetime | NO | DEFAULT_GENERATED |
| expires_at | datetime | NO |  |
| revoked_at | datetime | YES |  |

Chỉ mục:

- `ix_sessions_user_expiry` (users_id,expires_at).
- `PRIMARY` (session_id) UNIQUE.
- `uq_sessions_hash` (token_hash) UNIQUE.

Khóa ngoại (các dòng cùng tên thuộc một khóa ghép):

- `fk_sessions_user`: `users_id` → `users.users_id`.

## budgets

| Cột | Kiểu | NULL | Extra |
| --- | --- | --- | --- |
| budgets_id | bigint unsigned | NO | auto_increment |
| users_id | bigint unsigned | NO |  |
| outcome_id | bigint unsigned | YES |  |
| budgets_amount_limit | bigint | NO |  |
| budgets_period | varchar(5) | NO |  |
| budgets_start | date | NO |  |
| budgets_end | date | NO |  |
| budgets_created_at | datetime | NO | DEFAULT_GENERATED |

Chỉ mục:

- `fk_budgets_outcome` (outcome_id).
- `ix_budgets_user_period` (users_id,budgets_start,budgets_end).
- `PRIMARY` (budgets_id) UNIQUE.

Khóa ngoại (các dòng cùng tên thuộc một khóa ghép):

- `fk_budgets_outcome`: `outcome_id` → `outcome_categories.outcome_id`.
- `fk_budgets_user`: `users_id` → `users.users_id`.

## email_outbox

| Cột | Kiểu | NULL | Extra |
| --- | --- | --- | --- |
| outbox_id | bigint unsigned | NO | auto_increment |
| event_id | varchar(128) | NO |  |
| users_id | bigint unsigned | NO |  |
| event_type | varchar(32) | NO |  |
| recipient | varchar(254) | NO |  |
| payload | json | NO |  |
| status | varchar(12) | NO |  |
| attempts | int unsigned | NO |  |
| next_attempt_at | datetime | NO | DEFAULT_GENERATED |
| locked_until | datetime | YES |  |
| claim_token | char(32) | YES |  |
| sent_at | datetime | YES |  |
| last_error | varchar(64) | YES |  |
| created_at | datetime | NO | DEFAULT_GENERATED |

Chỉ mục:

- `fk_outbox_user` (users_id).
- `ix_outbox_due` (status,next_attempt_at,outbox_id).
- `ix_outbox_lease` (status,locked_until).
- `PRIMARY` (outbox_id) UNIQUE.
- `uq_outbox_event` (event_id) UNIQUE.

Khóa ngoại (các dòng cùng tên thuộc một khóa ghép):

- `fk_outbox_user`: `users_id` → `users.users_id`.

## email_verifications

| Cột | Kiểu | NULL | Extra |
| --- | --- | --- | --- |
| verification_id | bigint unsigned | NO | auto_increment |
| users_id | bigint unsigned | NO |  |
| email | varchar(254) | NO |  |
| token_hash | binary(32) | NO |  |
| created_at | datetime | NO | DEFAULT_GENERATED |
| expires_at | datetime | NO |  |
| used_at | datetime | YES |  |

Chỉ mục:

- `ix_verification_user_expiry` (users_id,expires_at).
- `PRIMARY` (verification_id) UNIQUE.
- `uq_verification_token` (token_hash) UNIQUE.

Khóa ngoại (các dòng cùng tên thuộc một khóa ghép):

- `fk_verification_user`: `users_id` → `users.users_id`.

## idempotency_keys

| Cột | Kiểu | NULL | Extra |
| --- | --- | --- | --- |
| idempotency_id | bigint unsigned | NO | auto_increment |
| users_id | bigint unsigned | NO |  |
| operation | varchar(32) | NO |  |
| idempotency_key | varchar(128) | NO |  |
| request_hash | binary(32) | NO |  |
| response_status | smallint unsigned | NO |  |
| response_body | json | NO |  |
| created_at | datetime | NO | DEFAULT_GENERATED |

Chỉ mục:

- `PRIMARY` (idempotency_id) UNIQUE.
- `uq_idempotency_request` (users_id,operation,idempotency_key) UNIQUE.

Khóa ngoại (các dòng cùng tên thuộc một khóa ghép):

- `fk_idempotency_user`: `users_id` → `users.users_id`.

## income_categories

| Cột | Kiểu | NULL | Extra |
| --- | --- | --- | --- |
| income_id | bigint unsigned | NO | auto_increment |
| users_id | bigint unsigned | YES |  |
| income_name | varchar(150) | NO |  |
| income_icon | varchar(150) | YES |  |
| income_is_active | tinyint(1) | NO |  |

Chỉ mục:

- `ix_income_owner_active` (users_id,income_is_active).
- `PRIMARY` (income_id) UNIQUE.

Khóa ngoại (các dòng cùng tên thuộc một khóa ghép):

- `fk_income_user`: `users_id` → `users.users_id`.

## outcome_categories

| Cột | Kiểu | NULL | Extra |
| --- | --- | --- | --- |
| outcome_id | bigint unsigned | NO | auto_increment |
| users_id | bigint unsigned | YES |  |
| outcome_name | varchar(150) | NO |  |
| outcome_icon | varchar(150) | YES |  |
| outcome_is_active | tinyint(1) | NO |  |

Chỉ mục:

- `ix_outcome_owner_active` (users_id,outcome_is_active).
- `PRIMARY` (outcome_id) UNIQUE.

Khóa ngoại (các dòng cùng tên thuộc một khóa ghép):

- `fk_outcome_user`: `users_id` → `users.users_id`.

## password_resets

| Cột | Kiểu | NULL | Extra |
| --- | --- | --- | --- |
| reset_id | bigint unsigned | NO | auto_increment |
| users_id | bigint unsigned | NO |  |
| token_hash | binary(32) | NO |  |
| created_at | datetime | NO | DEFAULT_GENERATED |
| expires_at | datetime | NO |  |
| used_at | datetime | YES |  |

Chỉ mục:

- `ix_resets_user_expiry` (users_id,expires_at).
- `PRIMARY` (reset_id) UNIQUE.
- `uq_resets_hash` (token_hash) UNIQUE.

Khóa ngoại (các dòng cùng tên thuộc một khóa ghép):

- `fk_resets_user`: `users_id` → `users.users_id`.

## schema_migrations

| Cột | Kiểu | NULL | Extra |
| --- | --- | --- | --- |
| version | varchar(64) | NO |  |
| applied_at | datetime | NO | DEFAULT_GENERATED |

Chỉ mục:

- `PRIMARY` (version) UNIQUE.

## transactions

| Cột | Kiểu | NULL | Extra |
| --- | --- | --- | --- |
| transactions_id | bigint unsigned | NO | auto_increment |
| users_id | bigint unsigned | NO |  |
| wallets_id | bigint unsigned | NO |  |
| destination_wallet_id | bigint unsigned | YES |  |
| transactions_type | varchar(8) | NO |  |
| income_id | bigint unsigned | YES |  |
| outcome_id | bigint unsigned | YES |  |
| transactions_amount | bigint | NO |  |
| transactions_note | text | YES |  |
| transactions_occurred_at | datetime | NO |  |
| transactions_created_at | datetime | NO | DEFAULT_GENERATED |
| transactions_updated_at | datetime | NO | DEFAULT_GENERATED on update CURRENT_TIMESTAMP |

Chỉ mục:

- `fk_transactions_income` (income_id).
- `fk_transactions_outcome` (outcome_id).
- `ix_transactions_budget` (users_id,transactions_type,outcome_id,transactions_occurred_at).
- `ix_transactions_destination` (users_id,destination_wallet_id,transactions_occurred_at,transactions_id).
- `ix_transactions_history` (users_id,transactions_occurred_at,transactions_id).
- `ix_transactions_wallet_history` (users_id,wallets_id,transactions_occurred_at,transactions_id).
- `PRIMARY` (transactions_id) UNIQUE.

Khóa ngoại (các dòng cùng tên thuộc một khóa ghép):

- `fk_transactions_destination`: `users_id` → `wallets.users_id`.
- `fk_transactions_destination`: `destination_wallet_id` → `wallets.wallets_id`.
- `fk_transactions_income`: `income_id` → `income_categories.income_id`.
- `fk_transactions_outcome`: `outcome_id` → `outcome_categories.outcome_id`.
- `fk_transactions_user`: `users_id` → `users.users_id`.
- `fk_transactions_wallet`: `users_id` → `wallets.users_id`.
- `fk_transactions_wallet`: `wallets_id` → `wallets.wallets_id`.

## user_identities

| Cột | Kiểu | NULL | Extra |
| --- | --- | --- | --- |
| identity_id | bigint unsigned | NO | auto_increment |
| users_id | bigint unsigned | NO |  |
| provider | varchar(16) | NO |  |
| provider_subject | varchar(255) | NO |  |
| created_at | datetime | NO | DEFAULT_GENERATED |

Chỉ mục:

- `PRIMARY` (identity_id) UNIQUE.
- `uq_identity_subject` (provider,provider_subject) UNIQUE.
- `uq_identity_user_provider` (users_id,provider) UNIQUE.

Khóa ngoại (các dòng cùng tên thuộc một khóa ghép):

- `fk_identity_user`: `users_id` → `users.users_id`.

## users

| Cột | Kiểu | NULL | Extra |
| --- | --- | --- | --- |
| users_id | bigint unsigned | NO | auto_increment |
| users_name | varchar(100) | NO |  |
| users_password | varchar(255) | YES |  |
| users_email | varchar(254) | NO |  |
| users_phone_number | varchar(20) | YES |  |
| users_avatar_url | varchar(2048) | YES |  |
| users_is_active | tinyint(1) | NO |  |
| users_created_at | datetime | NO | DEFAULT_GENERATED |
| users_updated_at | datetime | NO | DEFAULT_GENERATED on update CURRENT_TIMESTAMP |
| email_verified_at | datetime | YES |  |

Chỉ mục:

- `PRIMARY` (users_id) UNIQUE.
- `uq_users_email` (users_email) UNIQUE.

## wallet_categories

| Cột | Kiểu | NULL | Extra |
| --- | --- | --- | --- |
| walletcates_id | bigint unsigned | NO | auto_increment |
| walletcates_name | varchar(150) | NO |  |
| walletcates_icon | varchar(150) | YES |  |

Chỉ mục:

- `PRIMARY` (walletcates_id) UNIQUE.
- `uq_walletcates_name` (walletcates_name) UNIQUE.

## wallets

| Cột | Kiểu | NULL | Extra |
| --- | --- | --- | --- |
| wallets_id | bigint unsigned | NO | auto_increment |
| users_id | bigint unsigned | NO |  |
| walletcates_id | bigint unsigned | NO |  |
| wallets_name | varchar(100) | NO |  |
| wallets_opening_balance | bigint | NO |  |
| wallets_current_balance | bigint | NO |  |
| wallets_priority | int | NO |  |
| wallets_is_active | tinyint(1) | NO |  |
| wallets_created_at | datetime | NO | DEFAULT_GENERATED |
| active_priority | int | YES | STORED GENERATED |

Chỉ mục:

- `fk_wallets_category` (walletcates_id).
- `ix_wallets_default` (users_id,wallets_is_active,wallets_priority,wallets_id).
- `PRIMARY` (wallets_id) UNIQUE.
- `uq_wallets_active_priority` (users_id,active_priority) UNIQUE.
- `uq_wallets_owner` (users_id,wallets_id) UNIQUE.

Khóa ngoại (các dòng cùng tên thuộc một khóa ghép):

- `fk_wallets_category`: `walletcates_id` → `wallet_categories.walletcates_id`.
- `fk_wallets_user`: `users_id` → `users.users_id`.
