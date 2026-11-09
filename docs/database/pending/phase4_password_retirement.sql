-- =========================================================
-- ROBO CELL SECURITY MIGRATION: PHASE 4 (PENDING RETIREMENT)
-- =========================================================
-- WARNING: DO NOT EXECUTE UNTIL ALL USERS HAVE MIGRATED TO SUPABASE AUTH.
-- 
-- Description: Drop legacy password column from public.users after 100% auth migration.

BEGIN;

-- Drop legacy password column
ALTER TABLE public.users DROP COLUMN IF EXISTS password;

COMMIT;
