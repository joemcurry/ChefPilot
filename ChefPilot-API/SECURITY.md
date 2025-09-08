# Security & Secrets Guidance (ChefPilot-API)

This document contains minimal, actionable guidance for local development and CI/production.

## Local development

- Use the provided `.env.example` as a template. Copy to `.env` and fill values.

- Never commit `.env` with real secrets. Add `.env` to `.gitignore`.

- For dev only, simple secrets may be used; treat them as ephemeral.

## CI and production

- Store secrets in a dedicated secret store. Recommended options:

  GitHub Actions Secrets, HashiCorp Vault, or a cloud provider secrets manager.

- Populate CI environment variables from the secret store; do not echo secrets in logs.

- Rotate secrets (JWT secret, DB credentials) on a regular cadence (e.g., quarterly) or immediately after suspected exposure.

## JWT

- Use a strong random secret for `JWT_SECRET` (32+ bytes). Use HS256 or an

  asymmetric alternative for production.

- Implement refresh tokens and short-lived access tokens.

## Environment

- Required environment keys (see `.env.example`):

  `PORT`, `NODE_ENV`, `DB_PATH`, `JWT_SECRET`, `API_BASE_URL`, `UPLOADS_DIR`.

## PIN / Parent-Child association (security recommendations)

- Generate association PINs using a cryptographically secure RNG.

- PINs should be at least 8 characters or use an alphanumeric token.

- PINs must be single-use or expire after a short window (e.g., 24 hours).

- Rate-limit PIN verification endpoints and log attempts; alert for repeated failures.

- Provide a secure recovery flow for lost PINs requiring owner verification (email or admin portal).

## File uploads

- Validate file types and sizes at the server. Only allow jpg/png/pdf and

  limit to <5MB by default.

- Scan files for malware in production using a scanning service or agent.

- Store files with tenant isolation and secure filenames (e.g., `{tenant_id}_{id}_{type}.{ext}`).

## Audit

- Log important security events (login failures, PIN attempts, admin actions)

  with non-sensitive context.

