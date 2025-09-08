# ChefPilot

Quick start and developer notes for the ChefPilot repository.

## Quick start (API)

1. Copy environment variables locally:

```bash
cp ChefPilot-API/.env.example ChefPilot-API/.env
# Edit ChefPilot-API/.env and fill secrets (JWT_SECRET, DB path, etc.)
```

1. Install and run the API:

```bash
cd ChefPilot-API
npm install
npm start
```

API defaults to
<http://127.0.0.1:3000> (see `.env`).

## Running tests (API)

```bash
cd ChefPilot-API
npm test
```

## Repo notes / quick wins added

1. Added an exceptions & governance section to `agent.md` to allow documented, approved deviations from strict rules.
1. Added `ChefPilot-API/.env.example` with recommended environment variables.
1. Added a GitHub Actions CI skeleton at `.github/workflows/ci.yml` to run API tests and lint on PRs.

If you want, I can:

- Add a small Supertest integration test and a sample migration script in
	`/ChefPilot-API/sql/`.

- Wire up a secrets manager example for CI (GitHub Actions) and production.
