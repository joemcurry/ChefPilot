const express = require('express');
const router = express.Router();
const db = require('../db');
const { randomUUID } = require('crypto');

// Create temperature log
const { requireAuth, requireRole } = require('../middleware/auth');
const { scopeTenant } = require('../middleware/scope');
router.post('/', requireAuth, scopeTenant, (req, res) => {
  const t = req.body;
  const id = randomUUID();
  const is_safe = (t.temperature >= t.safe_min && t.temperature <= t.safe_max) ? 1 : 0;
  db.run(
    `INSERT INTO temperature_logs (id, tenant_id, temperature, unit, location, safe_min, safe_max, is_safe, notes, logged_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      id,
      t.tenant_id,
      t.temperature,
      t.unit || 'F',
      t.location || null,
      t.safe_min || null,
      t.safe_max || null,
      is_safe,
      t.notes || null,
      t.logged_at || null,
    ],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      db.get('SELECT * FROM temperature_logs WHERE id = ?', [id], (err, row) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json(row);
      });
    }
  );
});

// Get logs
router.get('/', (req, res) => {
  const { start_date, end_date } = req.query;
  let sql = 'SELECT * FROM temperature_logs';
  const params = [];
  const where = [];
  if (start_date) {
    where.push('logged_at >= ?');
    params.push(start_date);
  }
  if (end_date) {
    where.push('logged_at <= ?');
    params.push(end_date);
  }
  if (where.length) sql += ' WHERE ' + where.join(' AND ');

  db.all(sql, params, (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// Get log by id
router.get('/:id', (req, res) => {
  const id = req.params.id;
  db.get('SELECT * FROM temperature_logs WHERE id = ?', [id], (err, row) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!row) return res.status(404).json({ error: 'Not found' });
    res.json(row);
  });
});

// Delete log
router.delete('/:id', requireAuth, requireRole('Application Owner'), scopeTenant, (req, res) => {
  const id = req.params.id;
  db.run('DELETE FROM temperature_logs WHERE id = ?', [id], function (err) {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Deleted' });
  });
});

module.exports = router;
