const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret';
const ACCESS_EXP = process.env.ACCESS_EXP || '15m';
const REFRESH_EXP_MS = 1000 * 60 * 60 * 24 * 30; // 30 days in ms for refresh token expiry (opaque token)

function signAccessToken(payload) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: ACCESS_EXP });
}

function requireAuth(req, res, next) {
  const auth = req.headers.authorization || '';
  const parts = auth.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') return res.status(401).json({ error: 'missing_token' });
  const token = parts[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    return next();
  } catch (err) {
    return res.status(401).json({ error: 'invalid_token' });
  }
}

function requireRole(role) {
  return (req, res, next) => {
    if (!req.user) return res.status(401).json({ error: 'missing_auth' });
    if (!req.user.role) return res.status(403).json({ error: 'forbidden' });
    if (req.user.role !== role) return res.status(403).json({ error: 'forbidden' });
    return next();
  };
}

// Refresh token persistence using SQLite (refresh_tokens table)
const { randomUUID } = require('crypto');
const db = require('../db');

function issueRefreshToken(userId) {
  const token = randomUUID();
  const expiresAt = Date.now() + REFRESH_EXP_MS;
  try {
    db.run(
      `INSERT INTO refresh_tokens (token, user_id, expires_at) VALUES (?, ?, ?);`,
      [token, userId, expiresAt]
    );
    return token;
  } catch (err) {
    // fallback to ephemeral behavior if DB fails
    return token;
  }
}

function verifyRefreshToken(token, cb) {
  // callback style: cb(err, userId|null)
  db.get('SELECT user_id, expires_at FROM refresh_tokens WHERE token = ?', [token], (err, row) => {
    if (err) return cb(err, null);
    if (!row) return cb(null, null);
    if (Date.now() > row.expires_at) {
      db.run('DELETE FROM refresh_tokens WHERE token = ?', [token]);
      return cb(null, null);
    }
    return cb(null, row.user_id);
  });
}

function revokeRefreshToken(token) {
  db.run('DELETE FROM refresh_tokens WHERE token = ?', [token]);
}

module.exports = { signAccessToken, requireAuth, requireRole, issueRefreshToken, verifyRefreshToken, revokeRefreshToken };
