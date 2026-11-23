# Supabase PostgreSQL deployment

**Hosted status (2026-11-23):** a read-only Data API probe confirmed the seven expected table names exist. Direct PostgreSQL access from this workstation timed out, so column types, constraints, policies, and migration history are not fully verified. Do not re-run the initial `CREATE TABLE` migrations on this existing project until comparing the deployed schema in SQL Editor.

## Apply the schema

This migration creates the seven OurBudget tables and shared category rows. It
contains no DROP, TRUNCATE, or data-copy statements. Apply it only to a new,
empty Supabase project; it is not a conversion script for an existing MySQL
database.

The simplest deployment path is the Supabase Dashboard:

1. Open project ref ohztwpsabwfhovrcvxnq and select **SQL Editor**.
2. The current hosted project already has the seven table names. Do not run the initial CREATE migration there until comparing the deployed columns and constraints in SQL Editor.
3. Run the category seed only after confirming those shared rows are absent.
4. Inspect the seven tables, foreign keys, checks, indexes, RLS and identities
   in the dashboard, then run the test scripts from a secured backend host.

The CLI workflow is for a new empty project only. From the repository root,
use `supabase --workdir src/supabase db push`. Do not run it on the current
project until its migration history and deployed schema have been reconciled.


Never put that password in the repository or a command committed to shell
history.

## Configure the PHP backend

Copy src/backend/.env.example to src/backend/.env, then enter the database
password and Supabase secret key directly on the backend host. The supplied
database host is the direct endpoint; it requires IPv6 connectivity or an
IPv4 add-on. If the backend host is IPv4-only, copy the session pooler endpoint,
port, and username from Supabase connection settings into DB_HOST, DB_PORT,
and DB_USERNAME. Session pooling supports the persistent PDO connection and
prepared statements used by this application. Keep DB_SSLMODE=require.

The Flutter client continues to call the PHP API. Neither the secret key nor
database credentials are used by Flutter. The publishable key is not currently
needed by the client because direct Data API access is disabled for all seven
application tables.

## Existing data and cutover

The schema SQL does not read, copy, or remove MySQL rows. Export existing rows
from the old database and import them into Supabase in foreign-key order before
switching the API endpoint. Convert 32-byte MySQL binary hashes to PostgreSQL
bytea values when moving authentication records. Preserve IDs and advance the
identity sequences beyond their imported IDs. Compare row counts and financial
totals in a staging project before cutover. Keep the source database unchanged
until the application has passed acceptance checks.

Do not run this initial schema migration over existing public tables. No
hosted migration or data transfer was run from this workspace.
