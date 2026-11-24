-- =========================================================
-- POSTGRESQL SCHEMA (v2): Sabah Malaria Control Locator
-- Supports combined statuses + Single/Double/Family nets
-- =========================================================

CREATE TABLE IF NOT EXISTS houses (
  record_id       TEXT PRIMARY KEY,
  house_id        TEXT NOT NULL,
  resident_name   TEXT NOT NULL,
  district        TEXT NOT NULL DEFAULT 'Sabah',
  lat             DOUBLE PRECISION,
  lng             DOUBLE PRECISION,

  -- Multiple net sizes per household
  net_single      INTEGER NOT NULL DEFAULT 0 CHECK (net_single >= 0),
  net_double      INTEGER NOT NULL DEFAULT 0 CHECK (net_double >= 0),
  net_family      INTEGER NOT NULL DEFAULT 0 CHECK (net_family >= 0),

  occupant_count  INTEGER NOT NULL DEFAULT 0 CHECK (occupant_count >= 0),
  spray_date      DATE,

  -- Independent control program statuses (a house can have both!)
  is_sprayed      BOOLEAN NOT NULL DEFAULT FALSE,
  nets_given      BOOLEAN NOT NULL DEFAULT FALSE,
  needs_followup  BOOLEAN NOT NULL DEFAULT FALSE,

  notes           TEXT DEFAULT '',
  updated_by      TEXT,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for fast searching and reporting
CREATE INDEX IF NOT EXISTS idx_houses_district ON houses (district);
CREATE INDEX IF NOT EXISTS idx_houses_statuses ON houses (is_sprayed, nets_given, needs_followup);
