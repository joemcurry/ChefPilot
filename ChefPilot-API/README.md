# ChefPilot-API

Minimal README for local development of the API.

## Requirements

- Node.js 18+ and npm
- SQLite3 for production/local DB if used (optional for this scaffold)

## Quick start

Copy example env and run:

```bash
cp .env.example .env
npm install
npm start
```

Default API base: `http://127.0.0.1:3000`

## Run tests

```bash
npm test
```

## Database migrations

SQL migration files live under `./sql/`. For SQLite, run them with the `sqlite3` CLI or a small migration runner. Example using sqlite3:

```bash
sqlite3 data/chefpilot.sqlite3 < sql/001_init.sql
```

Notes:

- Do NOT commit `.env` with real secrets. Use `.env.example` as template.
- Use GitHub Actions secrets or a secrets manager for CI/production.
