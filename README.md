# Auctor · Proof of your craft

A responsive Flutter evidence workspace with an original provenance identity, warm ivory/deep graphite themes, muted jade and champagne accents, and restrained glass navigation. Bundled Newsreader gives display headings an editorial rhythm; Inter keeps evidence and controls readable. A desktop rail becomes a mobile dock. Reduced-motion and opaque-surface preferences follow the authenticated account.

## Run

Use Flutter stable and the companion FastAPI v2 API. `flutter pub get`, then `flutter run -d chrome --web-port 8080 --dart-define=API_BASE_URL=http://localhost:8000`. The API must explicitly allow `http://localhost:8080`. Web secure session storage requires HTTPS or localhost. For Android emulator use the host alias `http://10.0.2.2:8000` in a debug network configuration; release manifests require HTTPS. For mobile/public sharing pass `--dart-define=WEB_BASE_URL=https://your-web-domain`.

`flutter build web --release --dart-define=API_BASE_URL=https://your-api-domain --dart-define=WEB_BASE_URL=https://your-web-domain` creates a reviewable production bundle. Do not deploy the localhost default. Vercel configuration revalidates stable Flutter filenames instead of caching old bundles forever. GitHub OAuth callback is configured in the API and returns to the current `WEB_URL` workspace route.

Vercel's pinned build requires explicit public `AUCTOR_API_URL`/`AUCTOR_WEB_URL` and refuses an unavailable, development or storage-unconfigured API. Hosting is deferred; [activation notes](docs/DEPLOYMENT.md) document the existing target references and required private production setup.

## Working journeys

- Create/sign into an owned private workspace; sessions persist in platform secure storage.
- Upload a text PDF; follow durable extraction states, cancel/retry, review extracted claims, edit skills/projects/experience/profile links, inspect revision comparisons and restore versions.
- Confirm GitHub ownership by OAuth, inspect public repository snapshots, then bind an owned repository to a CV project.
- Complete five timed server-graded skill tracks; see actual score changes and assessment history.
- Submit experience, certificate or coding-profile evidence; attach private proof PDFs. Authorized independent reviewers inspect sources and record decisions.
- Inspect explainable weighted score, skill roadmap, notifications and score evolution.
- Search opt-in candidates, filter by score, save candidates and compare up to three profiles.
- Edit your public identity; enable discovery, preview public evidence, copy share links, show QR, create/revoke private sharing links, download PDF/JSON reports and copy an embeddable score badge.

The app exposes honest pending/unconfigured states. Extracted profile URLs do not prove ownership; imported coding counts require independent review. Private contact information and source PDFs are omitted from public profiles. Native desktop downloads write the selected file; mobile/web platform pickers save the supplied bytes.

## Source

`lib/main.dart` mounts `lib/premium/app.dart`; `lib/premium/controller.dart` owns authentication/network/persistence state. `lib/premium/visual_theme.dart` defines semantic color and typography styles. The previous `lib/core`, `lib/features` and `lib/shared` implementation remains as migration reference and is not mounted. `assets/brand/auctor-mark.svg` is the original mark; `export_brand.py` reproducibly exports matching platform icons. Flutter bundles the licensed Inter/Newsreader fonts and CanvasKit engine for local rendering without external font/engine requests. The standalone `/landing/index.html` uses the same local fonts, accurate product copy, system light/dark appearance and real workspace links.

## Verification and limitations

Run `flutter analyze`, `flutter test` and `flutter build web --release`. Tests cover bearer ownership/error handling, real responsive landing/workspace/evidence/profile layouts at 390 and 1440px and overflow detection. Android debug APK was built locally with JDK 21; CI also builds Android. Native device execution remains unverified. Windows native plugin builds require Windows Developer Mode/symlink support; iOS signing/build verification requires macOS/Xcode and operator certificates. These environment requirements are distinct from the verified web build.

Backend tests use isolated local PostgreSQL and mocked provider boundaries; live GitHub OAuth/OpenAI credentials, deployment HTTPS/storage/backups and account-owner credential rotation remain operator setup.

See [the fresh full audit, all 20 features and manual/visual expectations](docs/FULL-AUDIT-2026-10-05.md), and [the 20-capability acceptance record](docs/PORTFOLIO.md). Local Chrome QA also exercises real sign-in, CV saves, server assessment grading, share revocation and session restoration. `scripts/browser-qa.cjs` uses isolated Chrome and creates labelled QA accounts; configure its local API/web URLs and Playwright path before running it against a local instance.

Follow [the full manual test guide](docs/MANUAL_TESTS.md) for exact startup commands, synthetic input generation, all 20 feature journeys, expected errors/privacy/persistence and the built Android artifact. The browser script refuses non-local targets. No live OAuth, native-device execution or hosted deployment is claimed.

See [the October 6 visual refinement](docs/VISUAL-REFINEMENT-2026-10-06.md) for the richer palette, bundled editorial typography, rebuilt public landing, matching PDF/SVG exports, fresh browser screenshots and current verification results.

