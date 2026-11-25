-- =========================================================
-- SUPABASE / POSTGRESQL SETUP: Sabah Malaria Control App
-- Run this once in Supabase Dashboard -> SQL Editor -> New Query
-- =========================================================

-- 1. Create the shared houses table
CREATE TABLE IF NOT EXISTS public.houses (
  record_id       TEXT PRIMARY KEY,
  house_id        TEXT NOT NULL,
  resident_name   TEXT NOT NULL,
  district        TEXT NOT NULL DEFAULT 'Sabah',
  lat             DOUBLE PRECISION,
  lng             DOUBLE PRECISION,

  -- Multiple bed net sizes per house (Single, Double, Family only)
  net_single      INTEGER NOT NULL DEFAULT 0 CHECK (net_single >= 0),
  net_double      INTEGER NOT NULL DEFAULT 0 CHECK (net_double >= 0),
  net_family      INTEGER NOT NULL DEFAULT 0 CHECK (net_family >= 0),

  occupant_count  INTEGER NOT NULL DEFAULT 0 CHECK (occupant_count >= 0),
  spray_date      DATE,

  -- Combined control program statuses (a house can be sprayed AND given nets)
  is_sprayed      BOOLEAN NOT NULL DEFAULT FALSE,
  nets_given      BOOLEAN NOT NULL DEFAULT FALSE,
  needs_followup  BOOLEAN NOT NULL DEFAULT FALSE,

  notes           TEXT DEFAULT '',
  updated_by      TEXT,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Add indexes for fast searching and filtering
CREATE INDEX IF NOT EXISTS idx_houses_district ON public.houses (district);
CREATE INDEX IF NOT EXISTS idx_houses_statuses ON public.houses (is_sprayed, nets_given, needs_followup);

-- 3. Enable Row Level Security (CRITICAL: blocks unauthenticated public access)
ALTER TABLE public.houses ENABLE ROW LEVEL SECURITY;

-- 4. Allow ONLY signed-in ("authenticated") team members to read/write houses
DROP POLICY IF EXISTS "Team members can read houses" ON public.houses;
CREATE POLICY "Team members can read houses"
  ON public.houses FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS "Team members can insert houses" ON public.houses;
CREATE POLICY "Team members can insert houses"
  ON public.houses FOR INSERT
  TO authenticated
  WITH CHECK (true);

DROP POLICY IF EXISTS "Team members can update houses" ON public.houses;
CREATE POLICY "Team members can update houses"
  ON public.houses FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Team members can delete houses" ON public.houses;
CREATE POLICY "Team members can delete houses"
  ON public.houses FOR DELETE
  TO authenticated
  USING (true);

-- =========================================================
-- FUTURE MIGRATION NOTE (Moving to On-Premise PostgreSQL):
-- Export anytime using standard PostgreSQL pg_dump:
--   pg_dump "YOUR_SUPABASE_DB_CONNECTION_STRING" -t public.houses > houses_backup.sql
-- Then import into your on-premise PostgreSQL server:
--   psql -h localhost -U postgres -d malaria_db < houses_backup.sql
-- =========================================================
