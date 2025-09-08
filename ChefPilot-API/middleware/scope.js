const db = require('../db');

async function scopeTenant(req, res, next) {
  // If owner, allow
  const user = req.user || {};
  if (user.role === 'Application Owner') return next();

  // Tenant users must provide tenant_id in body or params
  const tenantId = req.body.tenant_id || req.params.tenant_id || req.params.id || null;
  if (!tenantId) return res.status(403).json({ error: 'tenant_required' });

  // Verify tenant exists
  db.get('SELECT * FROM tenants WHERE id = ?', [tenantId], (err, row) => {
    if (err) return res.status(500).json({ error: 'internal' });
    if (!row) return res.status(403).json({ error: 'invalid_tenant' });

    // Check mapping table for membership
    const userId = user.id;
    if (!userId) return res.status(401).json({ error: 'missing_auth' });

    db.get('SELECT * FROM user_tenants WHERE user_id = ? AND tenant_id = ?', [userId, tenantId], (err2, mapping) => {
      if (err2) return res.status(500).json({ error: 'internal' });
      if (!mapping) return res.status(403).json({ error: 'not_a_member' });
      // attach tenant and membership
      req.tenant = row;
      req.tenant_membership = mapping;
      return next();
    });
  });
}

module.exports = { scopeTenant };
