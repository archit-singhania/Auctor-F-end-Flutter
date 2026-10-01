# Portfolio notes and verification record

Suggested honest CV description: **Built an adaptive Flutter/FastAPI developer-evidence platform with private PostgreSQL-backed CV processing, authenticated resource ownership, GitHub OAuth provenance, timed server-graded assessments and explainable score histories. Designed the original identity, responsive glass navigation, accessible themes and recruiter sharing workflows.**

Do not claim measured user adoption, fraud prevention, benchmark results, production deployment, live GitHub validation or iOS release readiness without separate evidence.

## Feature map

| # | Capability | Connected interface |
|---|---|---|
| 1 | Owned accounts and expiring sessions | Sign in / Create workspace |
| 2 | Profile and persisted accessibility/theme preferences | Profile |
| 3 | Durable CV extraction, cancel/retry | Evidence / extraction jobs |
| 4 | Extraction provenance and original source download | Evidence / Review & edit / jobs |
| 5 | Revision comparison and restoration | Evidence / CV history |
| 6 | GitHub OAuth account ownership | Overview / Connect GitHub |
| 7 | Owned repository project binding | Evidence / Add project evidence |
| 8 | Public repo/language/star and recent event snapshots | Overview / Repository intelligence |
| 9 | Five multi-skill challenge tracks | Challenges |
| 10 | Owned timed attempts, server grading, replay protection | Challenge dialog |
| 11 | Badge outcomes and attempt history | Challenges / Assessment history |
| 12 | CV skill roadmap | Overview / Skill roadmap |
| 13 | Experience submission and private proof | Evidence / Add experience |
| 14 | Certificate submission and independent review | Evidence / Reviews |
| 15 | Coding-profile claim import and count review | Evidence / Add coding |
| 16 | Explainable v1 scoring and history | Overview / Activity |
| 17 | Activity and read status | Activity |
| 18 | Public profiles, privacy and revocable shares | Profile / Preview / Private sharing |
| 19 | Candidate search/filter/save/compare | Discover |
| 20 | PDF/JSON reports, QR and embed badge | Profile |

## Verified locally

- Eight backend tests passed against a real isolated PostgreSQL schema, including actual text-PDF jobs, independent reviews, account isolation, score idempotency, OAuth mocked at the provider boundary, project ownership and private-source/share access.
- Six standard Flutter tests passed at mobile/desktop sizes; analyzer reported no issues.
- Flutter JavaScript release web bundle built successfully. Secure-storage package currently prevents a WebAssembly build; JavaScript output is the supported verified target.
- Offscreen screenshots use the real Flutter widget tree and explicitly synthetic test fixtures. They are **layout evidence, not browser/live provider evidence**. Reproduce with `AUCTOR_QA_FONT_ROOT` pointing to Flutter's bundled material-font directory and run `flutter test test/render_artifacts_test.dart`; outputs appear in ignored `build/qa`.
- Android debug APK built successfully with the installed JDK 21 and an isolated package cache; native device execution has not been verified. Windows desktop builds require plugin symlink support and iOS requires macOS/signing credentials.

## Demo sequence

Start the API and web app as README describes. Create two local accounts; upload/review a CV; complete a challenge; check the actual +0.6 first-badge score; add a proof submission and inspect it with an operator-granted independent reviewer; opt into discovery; compare/save a candidate; create then revoke a share link. GitHub OAuth needs an operator-configured OAuth app and personal consent. No verification is fabricated when a provider is unavailable.

Original branding: `assets/brand/auctor-mark.svg`, exported platform launchers, favicon, PWA icons and social preview. Screenshots and real test output can accompany a portfolio write-up. No commits, deployment or provider-secret changes were performed.

