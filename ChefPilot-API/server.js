require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const cors = require('cors');
app.use(cors());
app.use(bodyParser.json());

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Auth & validation
const db = require('./db');
const bcrypt = require('bcryptjs');
const { requireFields } = require('./middleware/validate');
const { signAccessToken, issueRefreshToken, verifyRefreshToken, revokeRefreshToken } = require('./middleware/auth');

app.post('/api/auth/login', requireFields(['username', 'password']), (req, res) => {
  const { username, password } = req.body || {};

  db.get('SELECT * FROM users WHERE username = ?', [username], (err, user) => {
    if (err) return res.status(500).json({ error: 'Internal error' });
    if (!user) return res.status(401).json({ error: 'Invalid credentials' });

    const match = bcrypt.compareSync(password, user.password);
    if (!match) return res.status(401).json({ error: 'Invalid credentials' });
    const payload = { username: user.username, id: user.id, role: user.user_type || 'Tenant User' };
    const access = signAccessToken(payload);
    const refresh = issueRefreshToken(user.id);

    // Update last_login timestamp and return it in the response
    db.run("UPDATE users SET last_login = datetime('now') WHERE id = ?", [user.id], (err2) => {
      // ignore update error, but try to read the value back
      db.get('SELECT last_login FROM users WHERE id = ?', [user.id], (err3, row) => {
        const lastLogin = (row && row.last_login) ? row.last_login : null;
        return res.json({ token: access, refresh_token: refresh, user: { username: user.username, id: user.id, role: user.user_type, last_login: lastLogin }, tenant_id: 'dev-tenant' });
      });
    });
  });
});

// Refresh access token
app.post('/api/auth/refresh', requireFields(['refresh_token']), (req, res) => {
  const { refresh_token } = req.body;
  verifyRefreshToken(refresh_token, (err, userId) => {
    if (err || !userId) return res.status(401).json({ error: 'invalid_refresh' });
    db.get('SELECT * FROM users WHERE id = ?', [userId], (err2, user) => {
      if (err2 || !user) return res.status(401).json({ error: 'invalid_refresh' });
      const payload = { username: user.username, id: user.id, role: user.user_type || 'Tenant User' };
      const access = signAccessToken(payload);
      return res.json({ token: access });
    });
  });
});

// Logout (revoke refresh token)
app.post('/api/auth/logout', requireFields(['refresh_token']), (req, res) => {
  const { refresh_token } = req.body;
  revokeRefreshToken(refresh_token);
  res.json({ ok: true });
});

// Mount API routes
const tenantsRouter = require('./routes/tenants');
const tasksRouter = require('./routes/tasks');
const tempLogsRouter = require('./routes/temperature-logs');
const usersRouter = require('./routes/users');
const billingRouter = require('./routes/billing');
const pricingOverridesRouter = require('./routes/pricing_overrides');
const featuresRouter = require('./routes/features');
const tenantFeaturesRouter = require('./routes/tenant_features');

app.use('/api/tenants', tenantsRouter);
app.use('/api/tasks', tasksRouter);
app.use('/api/temperature-logs', tempLogsRouter);
app.use('/api/users', usersRouter);
app.use('/api/billing', billingRouter);
app.use('/api/pricing-overrides', pricingOverridesRouter);
app.use('/api/features', featuresRouter);
app.use('/api/tenant-features', tenantFeaturesRouter);

// Basic error handler
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server when run directly
if (require.main === module) {
  const port = process.env.PORT || 3000;
  app.listen(port, () => console.log(`ChefPilot-API listening on ${port}`));
}

module.exports = app;
