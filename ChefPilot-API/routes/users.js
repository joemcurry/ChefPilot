const express = require('express');
const router = express.Router();
const db = require('../db');

// Ensure user_audit table exists
db.run(`CREATE TABLE IF NOT EXISTS user_audit (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  changed_by TEXT,
  changes_json TEXT,
  created_at TEXT DEFAULT (datetime('now'))
)`);

// Ensure demographic columns exist on users table
db.all("PRAGMA table_info(users)", [], (err, cols) => {
  if (err) return;
  const existing = (cols || []).map(c => c.name);
  const toAdd = [
    { name: 'first_name', sql: 'ALTER TABLE users ADD COLUMN first_name TEXT' },
    { name: 'last_name', sql: 'ALTER TABLE users ADD COLUMN last_name TEXT' },
    { name: 'phone', sql: 'ALTER TABLE users ADD COLUMN phone TEXT' },
    { name: 'address', sql: 'ALTER TABLE users ADD COLUMN address TEXT' },
  { name: 'dob', sql: 'ALTER TABLE users ADD COLUMN dob TEXT' },
  { name: 'last_login', sql: "ALTER TABLE users ADD COLUMN last_login TEXT" },
  ];
  toAdd.forEach(col => {
    if (!existing.includes(col.name)) {
      try {
        db.run(col.sql, []);
      } catch (e) {
        // ignore
      }
    }
  });
});

// Return list of users (id, username, user_type, basic demographics) for admin UI
router.get('/', (req, res) => {
  db.all('SELECT id, username, user_type, email, first_name, last_name, last_login FROM users', [], (err, rows) => {
    if (err) return res.status(500).json({ error: 'Internal error' });
    res.json(rows.map(r => ({ id: r.id, username: r.username, user_type: r.user_type, email: r.email, first_name: r.first_name, last_name: r.last_name, last_login: r.last_login })));
  });
});

// Get single user
router.get('/:id', (req, res) => {
  const id = req.params.id;
  db.get('SELECT id, username, user_type, email, first_name, last_name, phone, address, dob, last_login FROM users WHERE id = ?', [id], (err, row) => {
    if (err) return res.status(500).json({ error: 'Internal error' });
    if (!row) return res.status(404).json({ error: 'Not found' });
    res.json(row);
  });
});

// Return audit history for a given user
router.get('/:id/audit', (req, res) => {
  const id = req.params.id;
  const limit = parseInt(req.query.limit || '100', 10) || 100;
  db.all('SELECT id, user_id, changed_by, changes_json, created_at FROM user_audit WHERE user_id = ? ORDER BY created_at DESC LIMIT ?', [id, limit], (err, rows) => {
    if (err) return res.status(500).json({ error: 'Internal error' });
    // parse changes_json for convenience
    const parsed = (rows || []).map(r => ({ id: r.id, user_id: r.user_id, changed_by: r.changed_by, created_at: r.created_at, changes: (() => { try { return JSON.parse(r.changes_json || '{}'); } catch (e) { return r.changes_json; } })() }));
    res.json(parsed);
  });
});

// Update user (partial)
router.put('/:id', (req, res) => {
  const id = req.params.id;
  // Fetch existing user
  db.get('SELECT id, username, user_type, email FROM users WHERE id = ?', [id], (err, existing) => {
    if (err) return res.status(500).json({ error: 'Internal error' });
    if (!existing) return res.status(404).json({ error: 'Not found' });

    // Validate inputs
    const updates = {};
    if (req.body.username != null) {
      const v = (req.body.username || '').toString().trim();
      if (v.length < 3) return res.status(400).json({ error: 'username too short' });
      updates.username = v;
    }
    if (req.body.email != null) {
      const v = (req.body.email || '').toString().trim();
      // simple email validation
      const emailRe = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
      if (!emailRe.test(v)) return res.status(400).json({ error: 'invalid email' });
      updates.email = v;
    }
    if (req.body.user_type != null) {
      updates.user_type = (req.body.user_type || '').toString().trim();
    }
    if (req.body.first_name != null) {
      updates.first_name = (req.body.first_name || '').toString().trim();
    }
    if (req.body.last_name != null) {
      updates.last_name = (req.body.last_name || '').toString().trim();
    }
    if (req.body.phone != null) {
      updates.phone = (req.body.phone || '').toString().trim();
      // basic phone validation (digits, +, spaces, dashes)
      const phoneRe = /^[\d\s+\-()]{6,20}$/;
      if (!phoneRe.test(updates.phone)) return res.status(400).json({ error: 'invalid phone' });
    }
    if (req.body.address != null) {
      updates.address = (req.body.address || '').toString().trim();
    }
    if (req.body.dob != null) {
      updates.dob = (req.body.dob || '').toString().trim();
      // expect YYYY-MM-DD
      const dobRe = /^\d{4}-\d{2}-\d{2}$/;
      if (!dobRe.test(updates.dob)) return res.status(400).json({ error: 'invalid dob, expected YYYY-MM-DD' });
    }
    if (Object.keys(updates).length === 0) return res.status(400).json({ error: 'No valid fields' });

    // Prepare SQL
    const fields = Object.keys(updates).map(k => `${k} = ?`);
    const values = Object.keys(updates).map(k => updates[k]);
    values.push(id);
    const sql = `UPDATE users SET ${fields.join(', ')} WHERE id = ?`;

    db.run(sql, values, function(err) {
      if (err) {
        // unique constraint on username might fail
        return res.status(500).json({ error: 'Internal error' });
      }
      if (this.changes === 0) return res.status(404).json({ error: 'Not found' });

      // compute change set compared to existing
      const changes = {};
      for (const k of Object.keys(updates)) {
        if ((existing[k] || '') !== (updates[k] || '')) changes[k] = { from: existing[k], to: updates[k] };
      }

      // insert audit row
      const changedBy = (req.headers && req.headers.authorization) ? req.headers.authorization : 'system';
      db.run('INSERT INTO user_audit (user_id, changed_by, changes_json) VALUES (?, ?, ?)', [id, changedBy, JSON.stringify(changes)], (err2) => {
        // ignore audit insert errors
        // return updated row
        db.get('SELECT id, username, user_type, email FROM users WHERE id = ?', [id], (err3, row) => {
          if (err3) return res.status(500).json({ error: 'Internal error' });
          res.json(row);
        });
      });
    });
  });
});

module.exports = router;
