-- DEVELOPMENT ONLY. Two known demo credentials: see README.md. Import once.
SET NAMES utf8mb4;
SET SESSION time_zone = '+07:00';
START TRANSACTION;
INSERT INTO users (users_id, users_name, users_email, users_password) VALUES
    (1, 'Tài khoản thử A', 'demo.a@ourbudget.test', '$2y$10$eAtc/JOMq4vPdAdyMldEc.kiLwTP4eeAH/pKATvAj0ZyNVAylXMaq'),
    (2, 'Tài khoản thử B', 'demo.b@ourbudget.test', '$2y$10$eAtc/JOMq4vPdAdyMldEc.kiLwTP4eeAH/pKATvAj0ZyNVAylXMaq');
INSERT INTO wallets (wallets_id, users_id, walletcates_id, wallets_name,
    wallets_opening_balance, wallets_current_balance, wallets_priority) VALUES
    (1, 1, 1, 'Tiền mặt A', 100000, 100000, 10),
    (2, 1, 2, 'Ngân hàng A', 10000, 10000, 0),
    (3, 2, 1, 'Tiền mặt B', 200000, 200000, 10);
INSERT INTO income_categories (income_id, users_id, income_name) VALUES (101, 1, 'Làm thêm A'), (102, 2, 'Làm thêm B');
INSERT INTO outcome_categories (outcome_id, users_id, outcome_name) VALUES (101, 1, 'Cá nhân A'), (102, 2, 'Cá nhân B');
INSERT INTO transactions (transactions_id, users_id, wallets_id, destination_wallet_id,
    transactions_type, income_id, outcome_id, transactions_amount, transactions_note, transactions_occurred_at) VALUES
    (1, 1, 1, NULL, 'EXPENSE', NULL, 1, -25000, 'Bữa trưa', '2026-11-20 12:00:00'),
    (2, 1, 1, 2, 'TRANSFER', NULL, NULL, 20000, 'Chuyển nội bộ', '2026-11-20 12:05:00'),
    (3, 2, 3, NULL, 'INCOME', 1, NULL, 50000, 'Thu thử B', '2026-11-20 08:00:00');
-- Seed writes ledger and balances atomically; production writes belong to the API service.
UPDATE wallets SET wallets_current_balance = 55000 WHERE wallets_id = 1;
UPDATE wallets SET wallets_current_balance = 30000 WHERE wallets_id = 2;
UPDATE wallets SET wallets_current_balance = 250000 WHERE wallets_id = 3;
INSERT INTO budgets (budgets_id, users_id, outcome_id, budgets_amount_limit, budgets_period, budgets_start, budgets_end) VALUES
    (1, 1, NULL, 100000, 'MONTH', '2026-11-01', '2026-11-30'),
    (2, 1, 1, 50000, 'MONTH', '2026-11-01', '2026-11-30'),
    (3, 2, NULL, 200000, 'WEEK', '2026-11-16', '2026-11-22');
COMMIT;
