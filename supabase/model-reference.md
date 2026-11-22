# Database model reference

The source model is thesis/doc/2. Báo cáo đề tài.docx. The deployed schema is
the seven entities in the Supabase migrations. The approved implementation
adjustments are: matching bigint foreign keys for category IDs, numeric(19, 0)
for budget limits, destination_wallet_id for the transfer destination, and no
transactions_type.

PostgreSQL uses lowercase unquoted identifiers, so users_phoneNumber in the
report is represented as users_phonenumber in the database. The PHP API maps
that database field to its existing phone JSON property.

Use PostgreSQL information_schema or Supabase Table Editor to inspect the
deployed model. This file intentionally contains no machine-specific database
metadata or records.
