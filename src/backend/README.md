# OurBudget PHP API

PHP 8.2, PDO PostgreSQL, PHPMailer, and firebase/php-jwt. The API remains the
only application database client; Flutter continues to call the existing
versioned REST endpoints. Supabase Auth is not used.

## Configuration

Copy .env.example to .env and set DB_PASSWORD to the PostgreSQL password from
the Supabase project's database settings. Keep .env on the server and out of
source control. DB_SSLMODE=require enforces encrypted PostgreSQL transport.
SUPABASE_SECRET_KEY is server-only and is not used by this custom API.

The supplied direct database hostname is configured by default. If the
deployment host cannot reach the direct endpoint, select the Supabase session
pooler connection details and update DB_HOST, DB_PORT, and DB_USERNAME. Do not
use transaction pooling for this persistent PDO connection.

## Database

Apply the ordered SQL files in ../supabase/migrations/ to a new Supabase project
before starting the API. The schema has seven OurBudget entities and enables
RLS with no grants for client API roles. The backend connects using server-side
PostgreSQL credentials; neither database credentials nor the secret key belong
in Flutter.

## Runtime

Configuration, Composer vendor files, and storage stay outside the public
webroot. The API and mail worker share a persistent runtime directory. Email
queue files and rate-limit files remain outside the database.

## Local checks

Install PHP extensions pdo_pgsql and openssl, run composer install, then
configure an empty disposable PostgreSQL database ending in _test for the
integration tests. Do not point tests at the hosted or personal database.


Run schema checks with a disposable database: php ../supabase/tests/verify.php and php ../supabase/tests/verify-report.php.
