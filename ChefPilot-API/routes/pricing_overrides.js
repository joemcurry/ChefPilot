const express = require('express');
const router = express.Router();
const db = require('../db');

// Ensure pricing_overrides table exists
db.run(`CREATE TABLE IF NOT EXISTS pricing_overrides (
  id TEXT PRIMARY KEY,
  tenantId TEXT,
  featureId TEXT,
  standalonePricePerUser REAL,
  parentTenantPricePerUser REAL,
  trialDays INTEGER,
  override TEXT,
  effectiveAt TEXT,
  price REAL,
  priceType TEXT,
  createdAt TEXT
)`);

// Safe ALTER checks (in case older DB doesn't have new columns)
db.all("PRAGMA table_info('pricing_overrides')", (err, cols) => {
  if (err) return;
  const names = (cols || []).map(c => c.name);
  const safeAlter = (sql) => db.run(sql, (err) => {
    if (err) {
      // ignore duplicate column errors from repeated migrations
      if (String(err).includes('duplicate column')) return;
      console.error('Migration error', err);
    }
  });
  if (!names.includes('standalonePricePerUser')) safeAlter('ALTER TABLE pricing_overrides ADD COLUMN standalonePricePerUser REAL');
  if (!names.includes('parentTenantPricePerUser')) safeAlter('ALTER TABLE pricing_overrides ADD COLUMN parentTenantPricePerUser REAL');
  if (!names.includes('trialDays')) safeAlter('ALTER TABLE pricing_overrides ADD COLUMN trialDays INTEGER');
  if (!names.includes('override')) safeAlter('ALTER TABLE pricing_overrides ADD COLUMN override TEXT');
  if (!names.includes('effectiveAt')) safeAlter('ALTER TABLE pricing_overrides ADD COLUMN effectiveAt TEXT');
  if (!names.includes('price')) safeAlter('ALTER TABLE pricing_overrides ADD COLUMN price REAL');
  if (!names.includes('priceType')) safeAlter('ALTER TABLE pricing_overrides ADD COLUMN priceType TEXT');
  if (!names.includes('createdAt')) safeAlter('ALTER TABLE pricing_overrides ADD COLUMN createdAt TEXT');
});

// List all overrides
router.get('/', (req, res) => {
  db.all('SELECT * FROM pricing_overrides ORDER BY createdAt DESC', [], (err, rows) => {
    if (err) return res.status(500).json({ error: 'internal' });
    return res.json(rows || []);
  });
});

// List overrides for a tenant
router.get('/tenant/:tenantId', (req, res) => {
  const { tenantId } = req.params;
  db.all('SELECT * FROM pricing_overrides WHERE tenantId = ? ORDER BY effectiveAt ASC', [tenantId], (err, rows) => {
    if (err) return res.status(500).json({ error: 'internal' });
    return res.json(rows || []);
  });
});

// Create/insert an override
router.post('/', (req, res) => {
  const body = req.body || {};
  const tenantId = body.tenantId;
  const featureId = body.featureId;
  if (!tenantId || !featureId) return res.status(400).json({ error: 'tenantId and featureId required' });

  const standalonePricePerUser = body.standalonePricePerUser != null ? body.standalonePricePerUser : null;
  const parentTenantPricePerUser = body.parentTenantPricePerUser != null ? body.parentTenantPricePerUser : null;
  const trialDays = body.trialDays != null ? parseInt(body.trialDays, 10) : 0;
  const override = body.override ? JSON.stringify(body.override) : null;
  const effectiveAt = body.effectiveAt || new Date().toISOString();
  const price = body.price != null ? body.price : null;
  const priceType = body.priceType != null ? body.priceType : null;
  const createdAt = new Date().toISOString();

  const id = `${tenantId}-${featureId}-${Date.now()}`;
  db.run(
  'INSERT INTO pricing_overrides (id, tenantId, featureId, standalonePricePerUser, parentTenantPricePerUser, trialDays, override, effectiveAt, price, priceType, createdAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
  [id, tenantId, featureId, standalonePricePerUser, parentTenantPricePerUser, trialDays, override, effectiveAt, price, priceType, createdAt],
    (err) => {
      if (err) return res.status(500).json({ error: 'internal' });
      return res.status(201).json({ ok: true, id });
    }
  );
});

// Delete an override by id
router.delete('/:id', (req, res) => {
  const { id } = req.params;
  db.run('DELETE FROM pricing_overrides WHERE id = ?', [id], function(err) {
    if (err) return res.status(500).json({ error: 'internal' });
    if (this.changes === 0) return res.status(404).json({ error: 'not_found' });
    return res.json({ ok: true });
  });
});

// Update an override by id
router.put('/:id', (req, res) => {
  const { id } = req.params;
  const body = req.body || {};
  // allow partial updates; only update provided fields
  const fields = [];
  const values = [];
  if (body.featureId != null) { fields.push('featureId = ?'); values.push(body.featureId); }
  if (body.standalonePricePerUser != null) { fields.push('standalonePricePerUser = ?'); values.push(body.standalonePricePerUser); }
  if (body.parentTenantPricePerUser != null) { fields.push('parentTenantPricePerUser = ?'); values.push(body.parentTenantPricePerUser); }
  if (body.trialDays != null) { fields.push('trialDays = ?'); values.push(parseInt(body.trialDays, 10)); }
  if (body.override != null) { fields.push('override = ?'); values.push(JSON.stringify(body.override)); }
  if (body.effectiveAt != null) { fields.push('effectiveAt = ?'); values.push(body.effectiveAt); }
  if (body.price != null) { fields.push('price = ?'); values.push(body.price); }
  if (body.priceType != null) { fields.push('priceType = ?'); values.push(body.priceType); }
  if (fields.length === 0) return res.status(400).json({ error: 'no_fields' });
  values.push(id);
  const sql = `UPDATE pricing_overrides SET ${fields.join(', ')} WHERE id = ?`;
  db.run(sql, values, function(err) {
    if (err) return res.status(500).json({ error: 'internal' });
    if (this.changes === 0) return res.status(404).json({ error: 'not_found' });
    return res.json({ ok: true });
  });
});

module.exports = router;
