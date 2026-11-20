-- Upgrade the original 001 schema ONCE, while the application is offline.
-- New installs: 001, 002, optional 003 demo, then 004. Do not rerun 004.
-- MySQL DDL commits implicitly: back up first; see README for recovery.
SET NAMES utf8mb4;
SET SESSION time_zone = '+07:00';
SET SESSION sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

ALTER TABLE users
    MODIFY users_password VARCHAR(255) CHARACTER SET ascii COLLATE ascii_bin NULL,
    ADD email_verified_at DATETIME NULL;

-- Preserve the old default wallet (highest old priority), then use ascending ranks.
CREATE TEMPORARY TABLE wallet_priority_migration (
    wallets_id BIGINT UNSIGNED PRIMARY KEY,
    new_priority INT UNSIGNED NOT NULL
);
INSERT INTO wallet_priority_migration
SELECT wallets_id, ROW_NUMBER() OVER (
    PARTITION BY users_id, wallets_is_active ORDER BY wallets_priority DESC, wallets_id
) - 1 FROM wallets;
ALTER TABLE wallets MODIFY wallets_priority INT NOT NULL DEFAULT 0;
UPDATE wallets w JOIN wallet_priority_migration m ON m.wallets_id = w.wallets_id
SET w.wallets_priority = m.new_priority;
DROP TEMPORARY TABLE wallet_priority_migration;
ALTER TABLE wallets
    DROP INDEX ix_wallets_default,
    ADD INDEX ix_wallets_default (users_id, wallets_is_active, wallets_priority, wallets_id),
    ADD CONSTRAINT ck_wallets_priority CHECK (wallets_priority >= 0),
    ADD active_priority INT GENERATED ALWAYS AS (
        CASE WHEN wallets_is_active = 1 THEN wallets_priority ELSE NULL END
    ) STORED,
    ADD UNIQUE KEY uq_wallets_active_priority (users_id, active_priority);

CREATE TABLE user_identities (
    identity_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    users_id BIGINT UNSIGNED NOT NULL,
    provider VARCHAR(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    provider_subject VARCHAR(255) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (identity_id),
    UNIQUE KEY uq_identity_subject (provider, provider_subject),
    UNIQUE KEY uq_identity_user_provider (users_id, provider),
    CONSTRAINT fk_identity_user FOREIGN KEY (users_id) REFERENCES users (users_id),
    CONSTRAINT ck_identity_provider CHECK (provider = 'google'),
    CONSTRAINT ck_identity_subject CHECK (CHAR_LENGTH(provider_subject) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE email_verifications (
    verification_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    users_id BIGINT UNSIGNED NOT NULL,
    email VARCHAR(254) NOT NULL,
    token_hash BINARY(32) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL,
    used_at DATETIME NULL,
    PRIMARY KEY (verification_id),
    UNIQUE KEY uq_verification_token (token_hash),
    KEY ix_verification_user_expiry (users_id, expires_at),
    CONSTRAINT fk_verification_user FOREIGN KEY (users_id) REFERENCES users (users_id),
    CONSTRAINT ck_verification_expiry CHECK (expires_at > created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE email_outbox (
    outbox_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    event_id VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    users_id BIGINT UNSIGNED NOT NULL,
    event_type VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    recipient VARCHAR(254) NOT NULL,
    payload JSON NOT NULL,
    status VARCHAR(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'pending',
    attempts INT UNSIGNED NOT NULL DEFAULT 0,
    next_attempt_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    locked_until DATETIME NULL,
    claim_token CHAR(32) CHARACTER SET ascii COLLATE ascii_bin NULL,
    sent_at DATETIME NULL,
    last_error VARCHAR(64) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (outbox_id),
    UNIQUE KEY uq_outbox_event (event_id),
    KEY ix_outbox_due (status, next_attempt_at, outbox_id),
    KEY ix_outbox_lease (status, locked_until),
    CONSTRAINT fk_outbox_user FOREIGN KEY (users_id) REFERENCES users (users_id),
    CONSTRAINT ck_outbox_status CHECK (status IN ('pending', 'processing', 'sent', 'failed', 'cancelled')),
    CONSTRAINT ck_outbox_event CHECK (event_type IN (
        'email.verify', 'auth.registered', 'auth.login',
        'transaction.created', 'transaction.updated', 'transaction.deleted'
    )),
    CONSTRAINT ck_outbox_event_id CHECK (CHAR_LENGTH(event_id) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE schema_migrations (
    version VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin PRIMARY KEY,
    applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO schema_migrations (version) VALUES ('004_step03_foundation');
