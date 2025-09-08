-- Initial schema for ChefPilot-API (SQLite recommended)

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  user_type TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);

-- Note: Don't store plaintext passwords in SQL. Use the seed script to insert
-- test users with hashed passwords: `node scripts/seed.js` or `npm run seed`.

-- Tenants table
CREATE TABLE IF NOT EXISTS tenants (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT,
  parent_id TEXT,
  pin TEXT,
  user_limit INTEGER DEFAULT 0,
  restaurant_type TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
  id TEXT PRIMARY KEY,
  tenant_id TEXT,
  title TEXT NOT NULL,
  description TEXT,
  type TEXT,
  schedule TEXT,
  assigned_to TEXT,
  assigned_by TEXT,
  status TEXT DEFAULT 'pending',
  due_date TEXT,
  requires_approval INTEGER DEFAULT 1,
  approved_by TEXT,
  approved_at TEXT,
  image_required INTEGER DEFAULT 0,
  image_url TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);

-- Temperature logs table
CREATE TABLE IF NOT EXISTS temperature_logs (
  id TEXT PRIMARY KEY,
  tenant_id TEXT,
  temperature REAL,
  unit TEXT,
  location TEXT,
  safe_min REAL,
  safe_max REAL,
  is_safe INTEGER,
  notes TEXT,
  logged_at TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);
