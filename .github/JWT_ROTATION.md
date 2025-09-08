# JWT Secret Rotation & CI Setup

This short guide explains how to manage the `JWT_SECRET` used to sign access tokens for the ChefPilot-API.

1. Set the secret in GitHub Actions


	- Go to your repository → Settings → Secrets and variables → Actions → New repository secret
	- Name: `JWT_SECRET`
	- Value: a strong random secret (recommended: `openssl rand -hex 32`)

2. CI usage


	- The CI workflow writes `ChefPilot-API/.env` from `secrets.JWT_SECRET` so `dotenv` picks it up. The workflow includes a quick check and will fail early if `secrets.JWT_SECRET` is not set.

3. Rotating the secret safely


	- Add the new secret as `JWT_SECRET_NEW` in repository secrets.
	- Modify the server to accept tokens signed with `JWT_SECRET_NEW` during a transition. For example, in `middleware/auth.js` try verifying with the new secret first, then the old one if verification fails.
	- Update CI and deployments to write `JWT_SECRET` with the new secret value.
	- After a short grace period (e.g. 24-48 hours) where both secrets are accepted, remove the old secret and simplify verification.


4. Recommendations


	- Use short access token lifetimes (e.g., 15 minutes) and refresh tokens with secure revocation to reduce exposure when rotating.
	- For production use, store refresh tokens in a persistent store and use a secrets manager for JWT secrets.
	- Automate rotation using your cloud provider's secret manager and deployment pipelines.

