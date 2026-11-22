# OurBudget database

Supabase PostgreSQL is the only supported database target. The schema follows
the seven entities in thesis/doc/2. Báo cáo đề tài.docx, with the approved
technical attributes on users and the approved transaction classification.

## Deploy

1. In Supabase, open **SQL Editor** for project ohztwpsabwfhovrcvxnq.
2. Run the timestamped SQL files in supabase/migrations/ in ascending order,
   or apply the same migrations using the Supabase CLI.
3. Confirm that the seven application tables exist in the public schema.
4. Do not run the retired MySQL scripts; they were removed during this migration.

The schema migration does not drop or alter existing data. A read-only Supabase
Data API probe confirmed all seven table names exist in the hosted public schema.
The publishable-key request was denied table access as intended. A secret-key
request was also denied, so this does not validate server-role Data API access;
the PHP architecture uses PostgreSQL credentials directly and does not require
that API path. Direct PostgreSQL TCP access from this workstation timed out.
The probes made no schema changes and read or wrote no application rows.

## Transaction rules

transactions_type is not present. A positive amount with income_id is
income; a negative amount with outcome_id is expense; a positive amount with
destination_wallet_id is a transfer. Reports and budgets must filter
destination_wallet_id IS NULL before summing income or expense.

The custom PHP API remains the only application database client. RLS is enabled
on every application table, and anon/authenticated receive no table grants.
Do not add client policies or expose the database key to Flutter without a
separate access-control review.

Use [SUPABASE.md](SUPABASE.md) for deployment. Migrations are in `migrations/`,
and disposable database checks are in `tests/`. Keep this root `supabase/`
directory as the deployed schema source of truth; `src/database/` is retired.
