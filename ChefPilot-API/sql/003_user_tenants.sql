-- Create mapping table between users and tenants
CREATE TABLE IF NOT EXISTS user_tenants (
  user_id TEXT NOT NULL,
  tenant_id TEXT NOT NULL,
  role TEXT DEFAULT 'member',
  created_at TEXT DEFAULT (datetime('now')),
  PRIMARY KEY(user_id, tenant_id)
);
