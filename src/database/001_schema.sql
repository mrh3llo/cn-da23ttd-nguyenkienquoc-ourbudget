-- OurBudget: MySQL >= 8.0.16, InnoDB. Run in a NEW, explicitly selected database.
-- No DROP/IF NOT EXISTS: a second import must fail instead of masking schema drift.
SET NAMES utf8mb4;
SET SESSION time_zone = '+07:00';
SET SESSION sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE TABLE users (
    users_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    users_name VARCHAR(100) NOT NULL,
    users_password VARCHAR(255) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    users_email VARCHAR(254) NOT NULL,
    users_phone_number VARCHAR(20) NULL,
    users_avatar_url VARCHAR(2048) NULL,
    users_is_active BOOLEAN NOT NULL DEFAULT TRUE,
    users_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    users_updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (users_id),
    UNIQUE KEY uq_users_email (users_email),
    CONSTRAINT ck_users_active CHECK (users_is_active IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE auth_sessions (
    session_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    users_id BIGINT UNSIGNED NOT NULL,
    token_hash BINARY(32) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL,
    revoked_at DATETIME NULL,
    PRIMARY KEY (session_id),
    UNIQUE KEY uq_sessions_hash (token_hash),
    KEY ix_sessions_user_expiry (users_id, expires_at),
    CONSTRAINT fk_sessions_user FOREIGN KEY (users_id) REFERENCES users (users_id),
    CONSTRAINT ck_sessions_expiry CHECK (expires_at > created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE password_resets (
    reset_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    users_id BIGINT UNSIGNED NOT NULL,
    token_hash BINARY(32) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL,
    used_at DATETIME NULL,
    PRIMARY KEY (reset_id),
    UNIQUE KEY uq_resets_hash (token_hash),
    KEY ix_resets_user_expiry (users_id, expires_at),
    CONSTRAINT fk_resets_user FOREIGN KEY (users_id) REFERENCES users (users_id),
    CONSTRAINT ck_resets_expiry CHECK (expires_at > created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE wallet_categories (
    walletcates_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    walletcates_name VARCHAR(150) NOT NULL,
    walletcates_icon VARCHAR(150) NULL,
    PRIMARY KEY (walletcates_id),
    UNIQUE KEY uq_walletcates_name (walletcates_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE wallets (
    wallets_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    users_id BIGINT UNSIGNED NOT NULL,
    walletcates_id BIGINT UNSIGNED NOT NULL,
    wallets_name VARCHAR(100) NOT NULL,
    wallets_opening_balance BIGINT NOT NULL DEFAULT 0,
    wallets_current_balance BIGINT NOT NULL DEFAULT 0,
    wallets_priority SMALLINT NOT NULL DEFAULT 0,
    wallets_is_active BOOLEAN NOT NULL DEFAULT TRUE,
    wallets_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (wallets_id),
    UNIQUE KEY uq_wallets_owner (users_id, wallets_id),
    KEY ix_wallets_default (users_id, wallets_is_active, wallets_priority DESC, wallets_id),
    CONSTRAINT fk_wallets_user FOREIGN KEY (users_id) REFERENCES users (users_id),
    CONSTRAINT fk_wallets_category FOREIGN KEY (walletcates_id) REFERENCES wallet_categories (walletcates_id),
    CONSTRAINT ck_wallets_active CHECK (wallets_is_active IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE income_categories (
    income_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    users_id BIGINT UNSIGNED NULL COMMENT 'NULL = shared read-only system category',
    income_name VARCHAR(150) NOT NULL,
    income_icon VARCHAR(150) NULL,
    income_is_active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (income_id),
    KEY ix_income_owner_active (users_id, income_is_active),
    CONSTRAINT fk_income_user FOREIGN KEY (users_id) REFERENCES users (users_id),
    CONSTRAINT ck_income_active CHECK (income_is_active IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE outcome_categories (
    outcome_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    users_id BIGINT UNSIGNED NULL COMMENT 'NULL = shared read-only system category',
    outcome_name VARCHAR(150) NOT NULL,
    outcome_icon VARCHAR(150) NULL,
    outcome_is_active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (outcome_id),
    KEY ix_outcome_owner_active (users_id, outcome_is_active),
    CONSTRAINT fk_outcome_user FOREIGN KEY (users_id) REFERENCES users (users_id),
    CONSTRAINT ck_outcome_active CHECK (outcome_is_active IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE transactions (
    transactions_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    users_id BIGINT UNSIGNED NOT NULL,
    wallets_id BIGINT UNSIGNED NOT NULL,
    destination_wallet_id BIGINT UNSIGNED NULL,
    transactions_type VARCHAR(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    income_id BIGINT UNSIGNED NULL,
    outcome_id BIGINT UNSIGNED NULL,
    transactions_amount BIGINT NOT NULL,
    transactions_note TEXT NULL,
    transactions_occurred_at DATETIME NOT NULL,
    transactions_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    transactions_updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (transactions_id),
    KEY ix_transactions_history (users_id, transactions_occurred_at, transactions_id),
    KEY ix_transactions_wallet_history (users_id, wallets_id, transactions_occurred_at, transactions_id),
    KEY ix_transactions_destination (users_id, destination_wallet_id, transactions_occurred_at, transactions_id),
    KEY ix_transactions_budget (users_id, transactions_type, outcome_id, transactions_occurred_at),
    CONSTRAINT fk_transactions_user FOREIGN KEY (users_id) REFERENCES users (users_id),
    CONSTRAINT fk_transactions_wallet FOREIGN KEY (users_id, wallets_id) REFERENCES wallets (users_id, wallets_id),
    CONSTRAINT fk_transactions_destination FOREIGN KEY (users_id, destination_wallet_id) REFERENCES wallets (users_id, wallets_id),
    CONSTRAINT fk_transactions_income FOREIGN KEY (income_id) REFERENCES income_categories (income_id),
    CONSTRAINT fk_transactions_outcome FOREIGN KEY (outcome_id) REFERENCES outcome_categories (outcome_id),
    -- Omitted ON DELETE/UPDATE means RESTRICT in InnoDB, also compatible with CHECK.
    CONSTRAINT ck_transactions_shape CHECK (
        (transactions_type = 'INCOME' AND transactions_amount > 0
            AND income_id IS NOT NULL AND outcome_id IS NULL AND destination_wallet_id IS NULL)
        OR (transactions_type = 'EXPENSE' AND transactions_amount < 0
            AND transactions_amount > -9223372036854775808
            AND outcome_id IS NOT NULL AND income_id IS NULL AND destination_wallet_id IS NULL)
        OR (transactions_type = 'TRANSFER' AND transactions_amount > 0
            AND income_id IS NULL AND outcome_id IS NULL AND destination_wallet_id IS NOT NULL
            AND destination_wallet_id <> wallets_id)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE budgets (
    budgets_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    users_id BIGINT UNSIGNED NOT NULL,
    outcome_id BIGINT UNSIGNED NULL COMMENT 'NULL = total expense budget',
    budgets_amount_limit BIGINT NOT NULL,
    budgets_period VARCHAR(5) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    budgets_start DATE NOT NULL,
    budgets_end DATE NOT NULL,
    budgets_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (budgets_id),
    KEY ix_budgets_user_period (users_id, budgets_start, budgets_end),
    CONSTRAINT fk_budgets_user FOREIGN KEY (users_id) REFERENCES users (users_id),
    CONSTRAINT fk_budgets_outcome FOREIGN KEY (outcome_id) REFERENCES outcome_categories (outcome_id),
    CONSTRAINT ck_budgets_amount CHECK (budgets_amount_limit > 0),
    CONSTRAINT ck_budgets_period CHECK (budgets_period IN ('WEEK', 'MONTH') AND budgets_end >= budgets_start)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE idempotency_keys (
    idempotency_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    users_id BIGINT UNSIGNED NOT NULL,
    operation VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    idempotency_key VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    request_hash BINARY(32) NOT NULL,
    response_status SMALLINT UNSIGNED NOT NULL,
    response_body JSON NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (idempotency_id),
    UNIQUE KEY uq_idempotency_request (users_id, operation, idempotency_key),
    CONSTRAINT fk_idempotency_user FOREIGN KEY (users_id) REFERENCES users (users_id),
    CONSTRAINT ck_idempotency_operation CHECK (operation IN ('transactions.create', 'transfers.create')),
    CONSTRAINT ck_idempotency_key CHECK (CHAR_LENGTH(idempotency_key) > 0),
    CONSTRAINT ck_idempotency_status CHECK (response_status = 201)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
