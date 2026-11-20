-- Import once after 001_schema.sql. These categories are read-only in the API.
SET NAMES utf8mb4;
SET SESSION time_zone = '+07:00';
START TRANSACTION;
INSERT INTO wallet_categories (walletcates_id, walletcates_name, walletcates_icon) VALUES
    (1, 'Tiền mặt', 'payments'),
    (2, 'Tài khoản ngân hàng', 'account_balance'),
    (3, 'Ví điện tử', 'account_balance_wallet');
INSERT INTO income_categories (income_id, users_id, income_name, income_icon) VALUES
    (1, NULL, 'Lương', 'work'),
    (2, NULL, 'Trợ cấp', 'school'),
    (3, NULL, 'Thu khác', 'add');
INSERT INTO outcome_categories (outcome_id, users_id, outcome_name, outcome_icon) VALUES
    (1, NULL, 'Ăn uống', 'restaurant'),
    (2, NULL, 'Di chuyển', 'directions_bus'),
    (3, NULL, 'Học tập', 'school'),
    (4, NULL, 'Chi khác', 'more_horiz');
COMMIT;
