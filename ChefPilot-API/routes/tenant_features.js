const express = require('express');
const router = express.Router();
const db = require('../db');

// Simple permission helper: checks header 'x-user-role' for allowed roles
function checkPermission(req, res, next) {
  // preferred integration: req.user.role if a real auth middleware populates it
  const role = (req.headers['x-user-role'] || (req.user && req.user.role) || '').toString().toLowerCase();
  // development override header
  const dev = (req.headers['x-dev-sudo'] || '').toString();
  if (dev === '1') return next();
  if (role === 'app_owner' || role === 'tenant_owner' || role === 'application owner' || role === 'tenant owner') return next();
  return res.status(403).json({ error: 'forbidden' });
}

// List applied feature_ids for a tenant
router.get('/tenant/:tenantId', (req, res) => {
  const tenantId = req.params.tenantId;
  db.all(
    'SELECT tf.feature_id, f.name, f.description, f.enabled, tf.applied_at FROM tenant_features tf LEFT JOIN features f ON tf.feature_id = f.id WHERE tf.tenant_id = ?',
    [tenantId],
    (err, rows) => {
      if (err) return res.status(500).json({ error: 'db_error' });
      res.json(rows || []);
    }
  );
});

// Apply a feature to a tenant
router.post('/', checkPermission, (req, res) => {
  const { tenant_id, feature_id } = req.body || {};
  if (!tenant_id || !feature_id) return res.status(400).json({ error: 'tenant_and_feature_required' });
  db.run(
    'INSERT OR REPLACE INTO tenant_features (tenant_id, feature_id, applied_at) VALUES (?, ?, datetime(\'now\'))',
    [tenant_id, feature_id],
    function (err) {
      if (err) return res.status(500).json({ error: 'db_error' });
      return res.json({ ok: true });
    }
  );
});

// Remove a feature from a tenant
router.delete('/:tenantId/:featureId', checkPermission, (req, res) => {
  const { tenantId, featureId } = req.params;
  db.run('DELETE FROM tenant_features WHERE tenant_id = ? AND feature_id = ?', [tenantId, featureId], function (err) {
    if (err) return res.status(500).json({ error: 'db_error' });
    if (this.changes === 0) return res.status(404).json({ error: 'not_found' });
    return res.json({ ok: true });
  });
});

module.exports = router;
