const express = require('express');
const router = express.Router();
const db = require('../db');

// Ensure billing_schedule table exists
db.run(`CREATE TABLE IF NOT EXISTS billing_schedule (
  id TEXT PRIMARY KEY,
  featureId TEXT,
  pricePerUserMonthly REAL,
  standalonePricePerUser REAL,
  parentTenantPricePerUser REAL,
  trialDays INTEGER,
  override TEXT,
  effectiveAt TEXT
)`);

// Ensure new columns exist (safe to run on existing DB)
db.all("PRAGMA table_info('billing_schedule')", (err, cols) => {
  if (err) return;
  const names = (cols || []).map(c => c.name);
  const safeAlter = (sql) => db.run(sql, (e) => {
    if (e) {
      if (String(e).includes('duplicate column')) return;
      console.error('Migration error', e);
    }
  });
  if (!names.includes('standalonePricePerUser')) safeAlter('ALTER TABLE billing_schedule ADD COLUMN standalonePricePerUser REAL');
  if (!names.includes('parentTenantPricePerUser')) safeAlter('ALTER TABLE billing_schedule ADD COLUMN parentTenantPricePerUser REAL');
  if (!names.includes('trialDays')) safeAlter('ALTER TABLE billing_schedule ADD COLUMN trialDays INTEGER');
  if (!names.includes('override')) safeAlter('ALTER TABLE billing_schedule ADD COLUMN override TEXT');
});

// GET current pricing (for demo return latest schedule entries that are effective now or fallback)
router.get('/current', (req, res) => {
  const now = new Date().toISOString();
  db.all("SELECT * FROM billing_schedule WHERE effectiveAt <= ? ORDER BY effectiveAt DESC", [now], (err, rows) => {
    if (err) return res.status(500).json({ error: 'Internal error' });
    if (rows.length) return res.json(rows);
    // fallback sample
    return res.json([{ featureId: 'default', standalonePricePerUser: 9.99, parentTenantPricePerUser: 7.99, trialDays: 14 }]);
  });
});

// GET future schedules
router.get('/future', (req, res) => {
  const now = new Date().toISOString();
  db.all("SELECT * FROM billing_schedule WHERE effectiveAt > ? ORDER BY effectiveAt ASC", [now], (err, rows) => {
    if (err) return res.status(500).json({ error: 'Internal error' });
    return res.json(rows);
  });
});

// Schedule a pricing update
router.post('/schedule', (req, res) => {
  const body = req.body || {};
  const featureId = body.featureId;
  const effectiveAt = body.effectiveAt;
  // Allow either legacy pricePerUserMonthly or new standalone/parent fields
  const standalonePricePerUser = body.standalonePricePerUser != null ? body.standalonePricePerUser : body.pricePerUserMonthly;
  const parentTenantPricePerUser = body.parentTenantPricePerUser != null ? body.parentTenantPricePerUser : body.pricePerUserMonthly;
  const trialDays = body.trialDays != null ? parseInt(body.trialDays, 10) : 0;
  const override = body.override ? JSON.stringify(body.override) : null;

  if (!featureId || !effectiveAt) return res.status(400).json({ error: 'missing' });
  const id = `${featureId}-${Date.now()}`;
  db.run(
    'INSERT INTO billing_schedule (id, featureId, pricePerUserMonthly, standalonePricePerUser, parentTenantPricePerUser, trialDays, override, effectiveAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    [id, featureId, standalonePricePerUser, standalonePricePerUser, parentTenantPricePerUser, trialDays, override, effectiveAt],
    (err) => {
      if (err) return res.status(500).json({ error: 'internal' });
      res.status(201).json({ ok: true, id });
    }
  );
});

// Update an existing scheduled pricing entry
router.put('/:id', (req, res) => {
  const id = req.params.id;
  const body = req.body || {};
  // Allow updating same fields as scheduling
  const featureId = body.featureId;
  const effectiveAt = body.effectiveAt;
  const standalonePricePerUser = body.standalonePricePerUser != null ? body.standalonePricePerUser : body.pricePerUserMonthly;
  const parentTenantPricePerUser = body.parentTenantPricePerUser != null ? body.parentTenantPricePerUser : body.pricePerUserMonthly;
  const trialDays = body.trialDays != null ? parseInt(body.trialDays, 10) : null;
  const override = body.override ? JSON.stringify(body.override) : null;

  // Build set clause dynamically
  const updates = [];
  const params = [];
  if (featureId != null) { updates.push('featureId = ?'); params.push(featureId); }
  if (standalonePricePerUser != null) { updates.push('standalonePricePerUser = ?'); params.push(standalonePricePerUser); }
  if (parentTenantPricePerUser != null) { updates.push('parentTenantPricePerUser = ?'); params.push(parentTenantPricePerUser); }
  if (trialDays != null) { updates.push('trialDays = ?'); params.push(trialDays); }
  if (override != null) { updates.push('override = ?'); params.push(override); }
  if (effectiveAt != null) { updates.push('effectiveAt = ?'); params.push(effectiveAt); }

  if (!updates.length) return res.status(400).json({ error: 'missing' });

  const sql = `UPDATE billing_schedule SET ${updates.join(', ')} WHERE id = ?`;
  params.push(id);
  db.run(sql, params, function(err) {
    if (err) return res.status(500).json({ error: 'internal' });
    if (this.changes === 0) return res.status(404).json({ error: 'not found' });
    return res.json({ ok: true });
  });
});

module.exports = router;
