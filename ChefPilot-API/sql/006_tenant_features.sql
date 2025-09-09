-- Create mapping table between tenants and features
CREATE TABLE IF NOT EXISTS tenant_features (
  tenant_id TEXT NOT NULL,
  feature_id TEXT NOT NULL,
  applied_at TEXT DEFAULT (datetime('now')),
  PRIMARY KEY (tenant_id, feature_id),
  FOREIGN KEY(feature_id) REFERENCES features(id) ON DELETE CASCADE
);
