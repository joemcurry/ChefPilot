const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3');

// Usage: node scripts/migrate.js [sql-file]
const sqlFile = process.argv[2] || 'sql/001_init.sql';
const dbPath = process.env.DB_PATH || path.join(__dirname, '..', 'data', 'chefpilot.sqlite3');

// Ensure data directory exists
const dataDir = path.dirname(dbPath);
if (!fs.existsSync(dataDir)) fs.mkdirSync(dataDir, { recursive: true });

if (!fs.existsSync(sqlFile)) {
  console.error('SQL file not found:', sqlFile);
  process.exit(1);
}

const sql = fs.readFileSync(sqlFile, 'utf8');

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Failed to open database:', err);
    process.exit(1);
  }

  db.exec(sql, (err) => {
    if (err) {
      console.error('Migration failed:', err);
      process.exit(1);
    }

    console.log('Migration applied:', sqlFile);
    db.close();
  });
});
