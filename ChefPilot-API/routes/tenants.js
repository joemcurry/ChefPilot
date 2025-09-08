const express = require('express');
const router = express.Router();
const db = require('../db');
const { randomUUID } = require('crypto');

// Create tenant
const { requireAuth, requireRole } = require('../middleware/auth');
const { scopeTenant } = require('../middleware/scope');
router.post('/', requireAuth, scopeTenant, (req, res) => {
  const { name, type, parent_id, pin, user_limit, restaurant_type } = req.body;
  const id = randomUUID();
  db.run(
    `INSERT INTO tenants (id, name, type, parent_id, pin, user_limit, restaurant_type) VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [id, name, type, parent_id || null, pin || null, user_limit || 0, restaurant_type || null],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      db.get('SELECT * FROM tenants WHERE id = ?', [id], (err, row) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json(row);
      });
    }
  );
});

// Get tenants
router.get('/', (req, res) => {
  db.all('SELECT * FROM tenants', [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// Get tenant by id
router.get('/:id', (req, res) => {
  const id = req.params.id;
  db.get('SELECT * FROM tenants WHERE id = ?', [id], (err, row) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!row) return res.status(404).json({ error: 'Not found' });
    res.json(row);
  });
});

// Update tenant
router.put('/:id', requireAuth, scopeTenant, (req, res) => {
  const id = req.params.id;
  const { name, type, parent_id, pin, user_limit, restaurant_type } = req.body;
  db.run(
    `UPDATE tenants SET name = ?, type = ?, parent_id = ?, pin = ?, user_limit = ?, restaurant_type = ?, updated_at = datetime('now') WHERE id = ?`,
    [name, type, parent_id || null, pin || null, user_limit || 0, restaurant_type || null, id],
    function (err) {
      if (err) return res.status(500).json({ error: err.message });
      db.get('SELECT * FROM tenants WHERE id = ?', [id], (err, row) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(row);
      });
    }
  );
});

// Delete tenant
router.delete('/:id', requireAuth, requireRole('Application Owner'), (req, res) => {
  const id = req.params.id;
  db.run('DELETE FROM tenants WHERE id = ?', [id], function (err) {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: 'Deleted' });
  });
});

// Associate current tenant with a parent using parent PIN
// Body: { parent_pin: string, tenant_id: string }
router.post('/associate', requireAuth, (req, res) => {
  const { parent_pin, tenant_id } = req.body;
  const user = req.user || {};
  if (!parent_pin) return res.status(400).json({ error: 'parent_pin_required' });
  if (!tenant_id) return res.status(400).json({ error: 'tenant_id_required' });

  // Verify tenant exists and is not already a child
  db.get('SELECT * FROM tenants WHERE id = ?', [tenant_id], (err, tenantRow) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!tenantRow) return res.status(404).json({ error: 'tenant_not_found' });
    if (tenantRow.parent_id) return res.status(409).json({ error: 'already_associated' });

    // Find parent by PIN
    db.get('SELECT * FROM tenants WHERE pin = ?', [parent_pin], (err2, parentRow) => {
      if (err2) return res.status(500).json({ error: err2.message });
      if (!parentRow) return res.status(404).json({ error: 'parent_not_found' });

      // Update tenant parent_id
      db.run('UPDATE tenants SET parent_id = ?, updated_at = datetime("now") WHERE id = ?', [parentRow.id, tenant_id], function (err3) {
        if (err3) return res.status(500).json({ error: err3.message });
        // Optionally, map the tenant owner user to the parent (no automatic mapping here)
        db.get('SELECT * FROM tenants WHERE id = ?', [tenant_id], (err4, updated) => {
          if (err4) return res.status(500).json({ error: err4.message });
          res.json(updated);
        });
      });
    });
  });
});

module.exports = router;
