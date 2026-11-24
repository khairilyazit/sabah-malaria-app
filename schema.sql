-- =========================================================
-- POSTGRESQL SCHEMA: Sabah Malaria Control House Locator
-- Works on both Supabase (Cloud) AND On-Premise PostgreSQL!
-- =========================================================

CREATE TABLE IF NOT EXISTS houses (
  record_id       TEXT PRIMARY KEY,
  house_id        TEXT NOT NULL,
  resident_name   TEXT NOT NULL,
  district        TEXT NOT NULL DEFAULT 'Sabah',
  lat             DOUBLE PRECISION,
  lng             DOUBLE PRECISION,
  net_count       INTEGER NOT NULL DEFAULT 0 CHECK (net_count >= 0),
  net_size        TEXT NOT NULL CHECK (net_size IN ('Single', 'Double', 'Family')),
  occupant_count  INTEGER NOT NULL DEFAULT 0 CHECK (occupant_count >= 0),
  spray_date      DATE,
  status          TEXT NOT NULL DEFAULT 'Pending'
                    CHECK (status IN ('Pending', 'Sprayed', 'Nets Distributed', 'Follow-up')),
  notes           TEXT DEFAULT '',
  updated_by      TEXT,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Speeds up searching by Village/District and filtering by Status
CREATE INDEX IF NOT EXISTS idx_houses_district ON houses (district);
CREATE INDEX IF NOT EXISTS idx_houses_status ON houses (status);
