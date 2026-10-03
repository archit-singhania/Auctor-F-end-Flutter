# Deferred production activation

No push, publication or hosted-resource mutation was performed. Local releases/manual testing come first. The current `build/web` embeds localhost:8011 and must remain a local review bundle.

## Existing target references

- Frontend repository homepage metadata identifies `https://auctor-f-end-flutter.vercel.app`. A read-only check on 2026-10-01 returned **404 DEPLOYMENT_NOT_FOUND**.
- Retained legacy API reference is `https://auctor-b-end-fastapi-production.up.railway.app`. Read-only `/health` and `/openapi.json` checks on 2026-10-01 returned **404 Application not found**.
- Repository remotes are `github.com/archit-singhania/Auctor-F-end-Flutter` and `github.com/archit-singhania/Auctor-B-end-FastAPI`.

These references do not establish current ownership or a working deployment. There is no local `.vercel/project.json` link. The owner must confirm the existing Vercel team/project and Railway service/database/volume before reusing them. Do not substitute an invented final API URL.

## API setup before frontend

1. Rotate formerly tracked credentials through the owning provider accounts. The ignored `.env.local` is preserved; source removal neither rotates credentials nor erases history. Database/provider secrets stay server-only.
2. Configure protected `DATABASE_URL`, intended `DB_SCHEMA`, and backups before additive migrations. Attach a **private persistent volume**, for example `/data`, and set `STORAGE_PATH=/data/auctor`. Railway supplies `RAILWAY_VOLUME_MOUNT_PATH`; another host must provide `STORAGE_VOLUME_PATH`. The mount directory must exist at runtime and contain the absolute storage path. Never expose it as a static/public directory. Configure database and file backup/restore separately.
3. Set `APP_ENV=production`, `PUBLIC_API_URL` to the confirmed public HTTPS API origin, `WEB_URL` to the confirmed HTTPS frontend origin, and exact comma-separated `ALLOWED_ORIGINS` including WEB_URL. Wildcards/local/HTTP origins, URL credentials, paths and queries are refused. Startup checks volume containment/write access; Unix files/directories use restrictive permissions. This does not certify provider durability or completed backups.
4. Optional GitHub OAuth requires protected client ID/secret and exact `GITHUB_REDIRECT_URI=<PUBLIC_API_URL>/api/github/callback`, also registered in the OAuth app. Leave both client settings empty for honest unconfigured behavior. Optional OpenAI is server-only. Deliberate reviewer role grants require independent identity checks.
5. `railway.json`/Procfile run Uvicorn on `$PORT`; `/health` gates Railway readiness. Startup refuses production defaults before accepting uploads. Confirm HTTP 200 with `status=ready`, `database=connected`, `schema_version=2`, `service=auctor-api`, `environment=production`, `storage=private-volume`. Test owned private files over HTTPS and restart to verify both records and file persistence.

Volume attachment, account access, backup validation, credential rotation and live consent remain owner-controlled tasks. See [Railway volumes](https://docs.railway.com/volumes) and [health checks](https://docs.railway.com/deployments/healthchecks).

## Vercel setup

Configure only public URLs: `AUCTOR_API_URL=<confirmed production API HTTPS origin>` and `AUCTOR_WEB_URL=<confirmed frontend HTTPS origin>`. They enter the client bundle; database/provider credentials must never enter these client settings.

`vercel.json` runs `scripts/vercel-install.sh`: download Flutter **3.47.3**, verify the exact locally tested revision, then fetch locked dependencies. `scripts/vercel-build.sh` calls `production-config.cjs` before JS compilation. It rejects missing/local/non-HTTPS URLs, redirects, unavailable/old/development APIs and API health without production/private-volume readiness. Only then does it build `build/web` with the confirmed origins. SPA rewrites and no-cache headers keep stable Flutter filenames fresh.

The scripts passed local Bash syntax checks and two Node production gate tests. No Vercel Linux build or Railway deployment has run. See [Vercel project configuration](https://vercel.com/docs/project-configuration/vercel-json) and [Flutter web deployment](https://docs.flutter.dev/deployment/web).

## Later hosted acceptance

When publishing is authorized, repeat [manual tests](MANUAL_TESTS.md) over HTTPS with labelled test accounts: session restore, CV processing/edit/restore, real OAuth consent, server grading/replay, independent reviews, contact/file privacy, search, revoke, exports, browser errors and mobile layouts. Restart to prove file persistence; test backup restore in a disposable environment. Native device/signing evidence remains separate.
