# Portfolio notes and verification record

Suggested honest CV description: **Built an adaptive Flutter/FastAPI developer-evidence platform with private PostgreSQL-backed CV processing, authenticated resource ownership, GitHub OAuth provenance, timed server-graded assessments and explainable score histories. Designed the original identity, responsive glass navigation, accessible themes and recruiter sharing workflows.**

Do not claim measured user adoption, fraud prevention, benchmark results, production deployment, live GitHub validation or iOS release readiness without separate evidence.

## Feature map

The following map uses the exact 20 approved feature labels; owned authentication, persistent themes/accessibility and original branding are additional foundations. All 20 have connected source/UI/backend implementations. This is implementation completion, not completion of live-provider, remote CI, deployment or native-device gates. API checks use real isolated PostgreSQL; provider-boundary checks use explicit fixtures.

| # | Capability / connected interface | Acceptance and validation |
|---|---|---|
| 1 | Observable CV parsing jobs, retry/cancel / Evidence | Actual text-PDF completion, controlled owned cancel/retry/lease tests; durable PostgreSQL jobs in `app/platform.py`. |
| 2 | Source-linked extraction confidence and editable claims / Evidence | Owner-only source downloads, qualitative review-required confidence, unverified claims and real browser save/readback. Confidence is not a calibrated probability. |
| 3 | CV revision comparison/restoration / Evidence | Connected comparison/restore; API verifies append-only restoration and owner separation; failed saves keep drafts. |
| 4 | GitHub OAuth ownership / Overview | Single-use state and provider fixture confirm account ID; live personal consent remains a gate. |
| 5 | Explicit repository → project evidence binding / Evidence | Owned snapshot binding and current CV project enforced; fixture verifies disconnect contributions. |
| 6 | Cached repository/contribution analytics and freshness / Overview | `app/insights.py` derives age/current/aging/stale, languages/stars/events with exact limited scope; deterministic freshness test. Live statistics are not claimed. |
| 7 | Backend multi-skill challenge catalog / Challenges | Five real server tracks; browser renders catalog/Docker questions. |
| 8 | Server-graded timed attempts/replay protection / Challenge | Actual 5/5/+0.6, API expiry/foreign-attempt/replay tests; no answer keys sent before submission. |
| 9 | Badge detail pages/attempt history / Badge details | Owned details endpoint, expiry/result/scope display and durable earned state; API and widget source-link checks. |
| 10 | Evidence-backed skills graph / Overview | Real graph nodes/edges distinguish CV claims, declared project technologies, owned provenance and scoped assessments; API projection/ownership plus interactive widget test. |
| 11 | Personalized skill-gap roadmap / Overview | Server ranks current CV/project gaps, maps exact supported aliases, explains practice steps, launches matching track; unsupported skills remain honest gaps. API/pure tests. |
| 12 | Experience-proof submission/reviewer workflow / Evidence, Reviews | Private PDF ownership, independent decisions, at most 1.5 points and removal; actual API checks. |
| 13 | Certificate evidence and issuer/source inspection / Evidence, Reviews | Issuer/reference/date fields, source/proof inspection and durable decision snapshot; API issuer readback. Certificates add no v1 points. |
| 14 | Coding-profile imports with honest verification status / Evidence | Bounded JSON import with source/count/digest, explicit user-supplied/unverified status; API import/privacy/error checks. Manual count and independent 150-count approval contribute 0.75. No live provider count scrape is claimed. |
| 15 | Explainable versioned score calculation / Overview | Formula v1 and original weights/denominators remain tested; no silent scoring migration. |
| 16 | Score history/evidence-change comparisons / Activity | Stored input snapshots and component deltas identify add/remove/status changes including zero-point certificate changes; legacy missing baselines labelled unknown. API/pure comparison tests. |
| 17 | Reviewer decisions/audit trail / Activity, Reviews | Append-only reviewer identity/time/source/issuer/rationale; persists after evidence removal; API authorization/readback checks. Read-status is additional supporting functionality. |
| 18 | Public recruiter profiles/privacy/revocation / Profile | Redacted opt-in profiles and private shares; actual browser create/revoke and API 404/privacy checks. |
| 19 | Opt-in discovery/saved profiles/comparison / Discover | API current profile filters, account-specific save/unsave and UI comparison up to three; stale selections cleared. |
| 20 | PDF/JSON evidence reports, QR/profile badges / Profile | Real PDF/JSON and opt-in SVG, connected QR/download/embed; API report/privacy checks. Native picker/scanning execution remains a gate. |

## Verified locally

- Eighteen backend tests passed: real isolated PostgreSQL/temporary private files, actual text-PDF jobs, revisions, job states, reviews/private proof, account isolation, score replay, activity/saves/exports, provider-boundary OAuth, graph/roadmap/badge/issuer/audit projections and bounded unverified profile imports. Pure checks cover graph/freshness/evidence comparisons and production volume/origin guards.
- Eight standard Flutter tests passed: mobile/desktop layouts, safe API failures, retained CV drafts and interactive graph source → scoped badge details. Final analyzer/build results are recorded alongside the release artifacts.
- Isolated headless Chrome passed actual sign-in, CV review/save/readback, five-question Docker submission with server-graded +0.6, profile, private share creation/revocation/redaction, persisted session reload, and mobile light/dark layouts. No browser page errors were observed. `scripts/browser-qa.cjs` reproduces this against local `AUCTOR_API_URL` and `AUCTOR_WEB_URL`; it creates clearly labelled local QA records and requires Playwright/installed Chrome. Never target production with this test.
- Flutter JavaScript release web bundle built successfully. Secure-storage package currently prevents a WebAssembly build; JavaScript output is the supported verified target.
- Offscreen screenshots use the real Flutter widget tree and explicitly synthetic test fixtures. They are **layout evidence, not browser/live provider evidence**. Reproduce with `AUCTOR_QA_FONT_ROOT` pointing to Flutter's bundled material-font directory and run `flutter test test/render_artifacts_test.dart`; outputs appear in ignored `build/qa`.
- Android debug APK built successfully with the installed JDK 21 and an isolated package cache; native device execution has not been verified. Windows desktop builds require plugin symlink support and iOS requires macOS/signing credentials.

## Demo sequence

Start the API and web app as README describes. Create two local accounts; upload/review a CV; complete a challenge; check the actual +0.6 first-badge score; add a proof submission and inspect it with an operator-granted independent reviewer; opt into discovery; compare/save a candidate; create then revoke a share link. GitHub OAuth needs an operator-configured OAuth app and personal consent. No verification is fabricated when a provider is unavailable.

Original branding: `assets/brand/auctor-mark.svg`, exported platform launchers, favicon, PWA icons and social preview. Screenshots and real test output can accompany a portfolio write-up. No commits, deployment or provider-secret changes were performed.

## Review artifacts

These are real same-run Chrome renders on 2026-10-03, connected to the local API with labelled QA data: [landing](screenshots/landing-desktop.png), [workspace](screenshots/overview-desktop.png), [CV editor](screenshots/cv-review.png), [assessment](screenshots/challenge-result.png), [badge details](screenshots/badge-detail.png), [skills graph](screenshots/skills-graph.png), [profile](screenshots/profile-desktop.png), [mobile](screenshots/overview-mobile.png) and [mobile dark](screenshots/overview-mobile-dark.png). Desktop overview precedes grading; badge/graph/mobile show the actual 0.6 assessment result.

The Android debug artifact is generated at `build/app/outputs/apk/debug/app-debug.apk`; the review web bundle is `build/web`. Generated builds remain ignored. No iOS build, device run, hosted deployment, live provider consent, remote CI execution or credential rotation is claimed.

The [actual connected browser demonstration](demo/auctor-connected-workflow.webm) shows CV editing, server grading, private-link revocation and responsive themes. Its [fixture and reproduction notes](demo/README.md) distinguish demonstration data from live provider evidence.

The [complete manual test guide](MANUAL_TESTS.md) provides startup commands and expected outcomes for all 20 capabilities, including errors, persistence, reviewer setup and native-device gates. [Production activation](DEPLOYMENT.md) remains deferred; environment-gated Vercel/Railway configuration and two Node production-readiness tests are prepared without publishing.

The [architecture diagram](ARCHITECTURE.md) maps active modules and trust boundaries. CI includes a macOS unsigned iOS release build/artifact and manual dispatch, unrun remotely; signing and device validation remain outstanding.

[Final release metadata](RELEASE.md) records actual passed totals, exact final APK/web/video size/hash/date, screenshot provenance and deferred gates. The final Chrome flow and Android rebuild both passed after the graph/badge/issuer/audit/import additions; analyzer was clean.

