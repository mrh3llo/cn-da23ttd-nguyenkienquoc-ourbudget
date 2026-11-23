# PostgreSQL schema

The canonical DDL is in `src/supabase/migrations/`. It contains the seven report entities: users, wallet categories, wallets, income categories, outcome categories, transactions, and budgets. The existing custom PHP authentication remains in the users table; no Supabase Auth tables or new OurBudget entities are introduced.

PostgreSQL folds unquoted identifiers to lowercase. Accordingly, the report's users_phoneNumber is stored as users_phonenumber; PHP maps it to the same existing API field phone. IDs use identity columns, category IDs and their foreign keys use bigint, amounts use integer minor units, budget limits use numeric(19, 0), and 32-byte SHA-256 hashes use bytea.

Transaction classification is encoded by amount sign and destination wallet. Transfers have a positive amount, no income/expense category, and a non-null destination; income is positive with only income_id; expense is negative with only outcome_id. The check constraint rejects zero values, category mismatches, and same-wallet transfers. Financial totals exclude rows whose destination_wallet_id is non-null.

RLS is enabled for all seven tables. The custom PHP API connects with its server-side PostgreSQL credentials; the mobile application continues to use the PHP REST API and does not receive database credentials or the Supabase secret key.
