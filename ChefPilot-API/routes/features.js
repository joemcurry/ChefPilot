const express = require('express');
const router = express.Router();
const db = require('../db');
const { v4: uuidv4 } = require('uuid');

// List features
router.get('/', (req, res) => {
  db.all('SELECT * FROM features', [], (err, rows) => {
    if (err) return res.status(500).json({ error: 'db_error' });
    res.json(rows || []);
  });
});

// Get single
router.get('/:id', (req, res) => {
  const id = req.params.id;
  db.get('SELECT * FROM features WHERE id = ?', [id], (err, row) => {
    if (err) return res.status(500).json({ error: 'db_error' });
    if (!row) return res.status(404).json({ error: 'not_found' });
    res.json(row);
  });
});

// Create
router.post('/', (req, res) => {
  const { name, description, enabled } = req.body || {};
  if (!name) return res.status(400).json({ error: 'name_required' });
  const id = uuidv4();
  db.run(
    'INSERT INTO features(id,name,description,enabled,created_at,updated_at) VALUES(?,?,?,?,datetime(\'now\'),datetime(\'now\'))',
    [id, name, description || '', enabled ? 1 : 0],
    function (err) {
      if (err) return res.status(500).json({ error: 'db_error' });
      // return the created row
      db.get('SELECT * FROM features WHERE id = ?', [id], (err2, row) => {
        if (err2) return res.status(500).json({ error: 'db_error' });
        res.status(201).json(row);
      });
    }
  );
});

// Update
router.put('/:id', (req, res) => {
  const id = req.params.id;
  const { name, description, enabled } = req.body || {};
  db.run(
    'UPDATE features SET name = ?, description = ?, enabled = ?, updated_at = datetime(\'now\') WHERE id = ?',
    [name || '', description || '', enabled ? 1 : 0, id],
    function (err) {
      if (err) return res.status(500).json({ error: 'db_error' });
      if (this.changes === 0) return res.status(404).json({ error: 'not_found' });
      res.json({ ok: true });
    }
  );
});

// Delete
router.delete('/:id', (req, res) => {
  const id = req.params.id;
  db.run('DELETE FROM features WHERE id = ?', [id], function (err) {
    if (err) return res.status(500).json({ error: 'db_error' });
    if (this.changes === 0) return res.status(404).json({ error: 'not_found' });
    res.json({ ok: true });
  });
});

module.exports = router;
