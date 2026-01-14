## 1.0.21

Improved postgres user creation in postStart hook:
  - Changed connection logic to try both postgres user and peer authentication (without user)
  - Database readiness check now tries both connection methods
  - This ensures postStart hook can connect even if postgres user doesn't exist yet
  - Fixes infinite retry loop when postgres user is missing

## 1.0.20

Fixed missing postgres user error:
  - Added creation of postgres user in 99-roles.sql initialization script
  - Added fallback in postStart hook to create postgres user if it doesn't exist
  - Fixes "role postgres does not exist" errors when database is already initialized
  - postStart hook now tries to connect without user first (peer auth) if postgres user doesn't exist

## 1.0.19

Fixed initialization script errors:
  - Made 99-logs.sql and 99-realtime.sql check if POSTGRES_USER exists before setting schema owner
  - Prevents "Peer authentication failed" errors when scripts run before user creation
  - Scripts now use DO blocks to safely check user existence before ALTER SCHEMA OWNER

## 1.0.18

Fixed postStart hook failures:
  - Removed `set -e` to prevent script termination on non-critical errors
  - Made all psql commands continue on error with warnings instead of failing
  - This prevents pod restarts due to FailedPostStartHook errors
  - Script now logs warnings but continues execution, allowing pod to start successfully

## 1.0.17

Fixed REPLICATION and schema ownership issues:
  - Removed attempt to add REPLICATION via ALTER USER (PostgreSQL doesn't allow this, REPLICATION can only be set at user creation)
  - Removed ALTER SCHEMA OWNER (requires being member of role, causes "must be member of role" error)
  - Now using only GRANT statements which don't require role membership
  - Added warning if existing user doesn't have REPLICATION (requires user recreation to add REPLICATION)
  - Changed ownership of existing tables/sequences to POSTGRES_USER (this works as superuser)

## 1.0.16

Fixed ownership and REPLICATION issues:
  - Added REPLICATION privilege check and grant for existing users (fixes "must be superuser or replication role to start walsender")
  - Changed ownership of all existing tables and sequences in _realtime and _analytics schemas to POSTGRES_USER
  - This fixes "permission denied for table schema_migrations" errors by ensuring user owns the tables

## 1.0.15

Fixed GRANT commands error handling:
  - Wrapped GRANT ALL PRIVILEGES ON ALL TABLES/SEQUENCES commands in DO blocks with exception handling
  - Prevents script failure when some tables cannot be accessed during grant operations
  - Errors are logged as warnings instead of causing script termination

## 1.0.14

Fixed permissions on existing tables in schemas:
  - Added GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA for _realtime and _analytics
  - Added GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA for _realtime and _analytics
  - This fixes "permission denied for table schema_migrations" errors on existing tables

## 1.0.13

Fixed schema permissions for realtime and analytics:
  - Added GRANT CREATE ON SCHEMA for _realtime and _analytics schemas
  - Added ALTER DEFAULT PRIVILEGES for SEQUENCES in addition to TABLES
  - This fixes "permission denied for table schema_migrations" errors

## 1.0.12

Fixed database user creation issues in postStart hook:
  - REPLICATION privilege now only added when creating new user (not when updating existing)
  - Changed schema ownership to GRANT permissions (avoids "must be member of role" error)
  - Added ALTER DEFAULT PRIVILEGES for automatic permissions on future tables in schemas

## 1.0.11

Fixed database user creation in postStart hook:
  - Added REPLICATION privilege for realtime WAL (walsender) support
  - Added automatic creation of _realtime and _analytics schemas
  - Set schema ownership to POSTGRES_USER
  - Configured default search_path for user (public, _realtime, _analytics)

## 1.0.10

Improved postStart hook for database user creation:
  - Fixed variable substitution in SQL command (removed heredoc, using direct psql -c)
  - Removed SUPERUSER privilege requirement (using CREATEDB CREATEROLE instead)
  - Added better error handling and logging
  - Added validation of environment variables before execution
Added init containers to realtime, meta, and analytics services to wait for database user creation before starting main containers

## 1.0.8

Fixed GOTRUE_SMTP_PORT configuration error by replacing placeholder string "SMTP_PORT" with numeric value "587".
Removed deprecated GOTRUE_JWT_DEFAULT_GROUP_NAME environment variable.
Updated Makefile to automatically extract version from Chart.yaml and remove old .tgz files before packaging.
Fixed database user authentication issues:
  - Added password setup for supabase_admin user in database initialization script (99-roles.sql)
  - Changed realtime, meta, and analytics services to read DB_USER/DB_USERNAME from secrets instead of hardcoded values
  - Added postStart lifecycle hook in database container to automatically create/update user from POSTGRES_USER secret after database startup

## 1.0.2

Fixed AWS_SECRET_ACCESS_KEY to use accessKey instead of keyId in storage deployment when using secretRef.
Added envFrom support for storage deployment to load secrets from vault.

## 1.0.1

Initial patched version with db service fix.

## 1.0.0

Added PG bouncer to help prevent the service from being overwhelmed with calls to the database. This is a breaking change as the database service name has changed. 

The previous direct connection can still be acccessed through  the `<SERVICE_NAME>-direct` service.


## 0.1.1

Fixes incorrect hardcoding of the kong config for functions

https://github.com/supabase-community/supabase-kubernetes/pull/99/files

## 0.1.0

Added the ability to customize the kong declarative yml for the dashboard as well as the start up script to allow for use of plugins like oidc.

Also added the ability to use `envFrom` syntax for the kong deployment so that sensitive environment variables can be loaded from a secret.

## 0.0.9

Added support for automatically exposing the needed SAML metadata and ACS routes through kong if auth.environment.GOTRUE_SAML_ENABLED is set to "true"