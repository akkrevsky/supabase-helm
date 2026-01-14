## 1.0.30

Create missing Supabase system roles in postStart hook:
  - Creates roles if they don't exist (not just update passwords)
  - Creates: authenticator, anon, authenticated, service_role, pgbouncer, supabase_admin, supabase_auth_admin, supabase_functions_admin, supabase_storage_admin
  - Grants anon/authenticated/service_role to authenticator
  - Fixes "Role supabase_storage_admin does not exist" error on non-standard PVCs
  - Each role created with appropriate privileges (SUPERUSER, CREATEDB, CREATEROLE, REPLICATION, BYPASSRLS, etc.)

## 1.0.29

Added password sync for Supabase system users in postStart hook:
  - Updates passwords for authenticator, pgbouncer, supabase_admin, supabase_auth_admin, supabase_functions_admin, supabase_storage_admin
  - Fixes "password authentication failed for user authenticator" error on existing PVCs
  - Only updates password if user exists (safe for fresh installs)
  - Uses POSTGRES_PASSWORD from secret for all system users

## 1.0.28

Simplified postStart hook with password authentication:
  - Switched from peer auth to password auth via TCP (127.0.0.1)
  - Connect as POSTGRES_USER directly (must already exist in DB)
  - Removed complex fallback logic - if POSTGRES_USER can't connect, fail with clear error
  - Clear error message if PVC has different roles/password than current secret
  - Optionally creates 'postgres' role if it doesn't exist
  - Simplified schema/privilege grants using POSTGRES_USER
  - Added `set -eu` for better error handling

## 1.0.27

Added POSTGRES_USER as connection fallback:
  - Added attempt to connect using POSTGRES_USER (may be the database owner)
  - This handles cases where database is initialized but default users don't exist
  - Improved error message suggesting PVC deletion if connection fails
  - Fixes connection issues when database is already initialized without proper roles

## 1.0.26

Fixed postgres role creation with fallback logic:
  - Changed to try peer authentication without -U first (uses system user postgres)
  - If that fails, queries pg_database to find the actual database owner
  - Connects as the database owner to create postgres role
  - This handles cases where supabase_admin doesn't exist (database already initialized)
  - Fixes "Role supabase_admin does not exist" errors by using database owner instead

## 1.0.25

Fixed postgres role creation by using supabase_admin:
  - Changed to use supabase_admin (default user in Supabase) for database connections
  - This is the standard default user created during Supabase initialization
  - Simplifies connection logic by using known default user instead of querying database owner
  - Fixes "role postgres does not exist" errors by using supabase_admin to create postgres role

## 1.0.24

Fixed postgres role creation by using database owner:
  - Changed to query pg_database to find the actual database owner
  - Connects as the database owner (created during initdb) instead of trying to use non-existent postgres role
  - This allows creating postgres role even when peer authentication requires existing role
  - Fixes "role postgres does not exist" errors by using the actual database owner for connections

## 1.0.23

Fixed postgres role creation using template1 database:
  - Changed to connect to template1 database instead of POSTGRES_DB (template1 always exists)
  - Uses CREATE ROLE instead of CREATE USER (they are equivalent)
  - This allows creating postgres role even when connecting as postgres system user via peer auth
  - Fixes "role postgres does not exist" errors when trying to connect to POSTGRES_DB

## 1.0.22

Fixed peer authentication issues in postStart hook:
  - Changed to use `su - postgres` to switch to postgres system user before running psql commands
  - This allows peer authentication to work correctly (container runs as root, but needs postgres system user)
  - Fixes "Peer authentication failed for user root" errors
  - Database readiness check and postgres user creation now use postgres system user

## 1.0.21

Fixed postgres user creation logic in postStart hook:
  - Changed database readiness check to use peer authentication (without user) instead of postgres user
  - This allows hook to connect even when postgres user doesn't exist yet
  - Creates postgres user using peer authentication before attempting to use it
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