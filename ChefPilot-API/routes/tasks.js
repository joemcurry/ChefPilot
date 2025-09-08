const express = require('express');
const router = express.Router();
const db = require('../db');
const { randomUUID } = require('crypto');

// Create task
const { requireAuth, requireRole } = require('../middleware/auth');
const { scopeTenant } = require('../middleware/scope');
router.post('/', requireAuth, scopeTenant, (req, res) => {
  const t = req.body;
  const id = randomUUID();
  db.run(
    `INSERT INTO tasks (id, tenant_id, title, description, type, schedule, assigned_to, assigned_by, status, due_date, requires_approval, image_required, image_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      id,
      t.tenant_id,
      t.title,
      t.description || null,
      t.type || null,
      t.schedule || null,
      t.assigned_to || null,
      t.assigned_by || null,
      t.status || 'pending',
      t.due_date || null,
      t.requires_approval ? 1 : 0,
      t.image_required ? 1 : 0,
      t.image_url || null,
    ],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      db.get('SELECT * FROM tasks WHERE id = ?', [id], (err, row) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json(row);
      });
    }
  );
});

// Get tasks
router.get('/', (req, res) => {
  const { status, assigned_to } = req.query;
  let sql = 'SELECT * FROM tasks';
  const params = [];
  const where = [];
  if (status) {
    where.push('status = ?');
    params.push(status);
  }
  if (assigned_to) {
    where.push('assigned_to = ?');
    params.push(assigned_to);
  }
  if (where.length) sql += ' WHERE ' + where.join(' AND ');

  db.all(sql, params, (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// Get task by id
router.get('/:id', (req, res) => {
  const id = req.params.id;
  db.get('SELECT * FROM tasks WHERE id = ?', [id], (err, row) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!row) return res.status(404).json({ error: 'Not found' });
    res.json(row);
  });
});

// Update task
router.put('/:id', requireAuth, scopeTenant, (req, res) => {
  const id = req.params.id;
  const t = req.body;
  db.run(
    `UPDATE tasks SET title = ?, description = ?, type = ?, schedule = ?, assigned_to = ?, assigned_by = ?, status = ?, due_date = ?, requires_approval = ?, approved_by = ?, approved_at = ?, image_required = ?, image_url = ?, updated_at = datetime('now') WHERE id = ?`,
    [
      t.title,
      t.description || null,
      t.type || null,
      t.schedule || null,
      t.assigned_to || null,
      t.assigned_by || null,
      t.status || null,
      t.due_date || null,
      t.requires_approval ? 1 : 0,
      t.approved_by || null,
      t.approved_at || null,
      t.image_required ? 1 : 0,
      t.image_url || null,
      id,
    ],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      db.get('SELECT * FROM tasks WHERE id = ?', [id], (err, row) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(row);
      });
    }
  );
});

// Delete task
router.delete('/:id', requireAuth, requireRole('Application Owner'), (req, res) => {
  const id = req.params.id;
  db.run('DELETE FROM tasks WHERE id = ?', [id], function (err) {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Deleted' });
  });
});

module.exports = router;
