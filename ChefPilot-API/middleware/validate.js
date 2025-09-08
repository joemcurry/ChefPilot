// Simple request body validation helpers
function requireFields(fields) {
  return (req, res, next) => {
    const missing = [];
    for (const f of fields) {
      if (!req.body || req.body[f] === undefined || req.body[f] === null) missing.push(f);
    }
    if (missing.length) return res.status(400).json({ error: 'missing_fields', fields: missing });
    next();
  };
}

module.exports = { requireFields };
