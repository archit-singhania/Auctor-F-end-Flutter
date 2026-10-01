# Portfolio notes and verification record

Suggested honest CV description: **Built an adaptive Flutter/FastAPI developer-evidence platform with private PostgreSQL-backed CV processing, authenticated resource ownership, GitHub OAuth provenance, timed server-graded assessments and explainable score histories. Designed the original identity, responsive glass navigation, accessible themes and recruiter sharing workflows.**

Do not claim measured user adoption, fraud prevention, benchmark results, production deployment, live GitHub validation or iOS release readiness without separate evidence.

## Feature map

All 20 capabilities have connected interfaces and backend operations. Validation below identifies the actual coverage; it does not claim that every control was exercised in a browser or on a native device. API checks use a real isolated PostgreSQL schema. Provider-boundary checks use explicit fixtures.

| # | Capability / connected interface | Acceptance and validation |
|---|---|---|
| 1 | Owned accounts and expiring sessions / Sign in | Browser sign-in/session reload; API account isolation and logout invalidate access. |
| 2 | Persistent profile, themes and accessibility / Profile | API preference readback; light/dark real browser images; responsive widget checks. |
| 3 | Durable CV extraction, cancel/retry / Evidence | Real text-PDF job completes; controlled job-state API checks enforce owned cancel/retry. |
| 4 | Extraction provenance and source download / Evidence | API source download is owner-only; extraction is explicitly unverified. |
| 5 | CV review, revision comparison and restore / Evidence | Browser review/save persists a version; API restore checks ownership/readback; failed saves preserve drafts in widget test. |
| 6 | GitHub OAuth ownership / Overview | State is single-use; provider fixture confirms account ID. Live consent remains operator setup. |
| 7 | Owned repository project binding / Evidence | Provider fixture binds a repository to a CV project; disconnect removes contributions. |
| 8 | Repository/language/star/recent-event snapshots / Overview | Connected snapshot interface and bounded provider import; real provider statistics not claimed. |
| 9 | Five skill tracks / Challenges | API returns five tracks; real browser renders the catalog and Docker questions. |
| 10 | Timed server grading and replay protection / Challenge dialog | Browser grades 5/5 for +0.6; API rejects expired/foreign attempts and makes replays idempotent. |
| 11 | Badges and attempt history / Challenges | API preserves earned badges after a failed retry; actual browser score readback is 0.6. |
| 12 | CV skill roadmap / Overview | Connected derived roadmap maps CV skills to implemented tracks; responsive workspace render checks. |
| 13 | Experience and private proof / Evidence | API proof upload/download ownership and independent approval contribute 1.5; removal recomputes score. |
| 14 | Certificates and independent review / Reviews | API self-review rejection, private reviewer access and immutable reviewed proof; certificates do not invent score points. |
| 15 | Reviewed coding-profile count / Evidence | API approves a sourced 150-count claim for 0.75 points; extracted URLs alone prove nothing. |
| 16 | Explainable v1 score and history / Overview, Activity | Pure/API tests preserve .25/.15/.30/.15/.15 weights and history; browser displays real assessment delta. |
| 17 | Activity and read status / Activity | API read operation persists account-scoped read flags. |
| 18 | Public profiles and revocable sharing / Profile | Real browser creates/revokes a private link; API checks discovery opt-in, redaction and revoked 404. |
| 19 | Candidate search/filter/save/compare / Discover | API score filter and account-specific save/unsave; connected comparison supports three candidates and clears stale selection after search. |
| 20 | Reports, QR and embed / Profile | API outputs real PDF/JSON and opt-in SVG; QR/download/embed controls connected. Native picker/device execution remains unverified. |

## Verified locally

- Nine backend tests passed against a real isolated PostgreSQL schema, including actual text-PDF jobs, revisions, cancel/retry state transitions, independent reviews/private proof, account isolation, score idempotency, activity, candidate saves, exports, OAuth mocked at the provider boundary and project ownership.
- Seven standard Flutter tests passed at mobile/desktop sizes; analyzer reported no issues. The additional failure-path test confirms that failed CV saves retain the edited draft for retry.
- Isolated headless Chrome passed actual sign-in, CV review/save/readback, five-question Docker submission with server-graded +0.6, profile, private share creation/revocation/redaction, persisted session reload, and mobile light/dark layouts. No browser page errors were observed. `scripts/browser-qa.cjs` reproduces this against local `AUCTOR_API_URL` and `AUCTOR_WEB_URL`; it creates clearly labelled local QA records and requires Playwright/installed Chrome. Never target production with this test.
- Flutter JavaScript release web bundle built successfully. Secure-storage package currently prevents a WebAssembly build; JavaScript output is the supported verified target.
- Offscreen screenshots use the real Flutter widget tree and explicitly synthetic test fixtures. They are **layout evidence, not browser/live provider evidence**. Reproduce with `AUCTOR_QA_FONT_ROOT` pointing to Flutter's bundled material-font directory and run `flutter test test/render_artifacts_test.dart`; outputs appear in ignored `build/qa`.
- Android debug APK built successfully with the installed JDK 21 and an isolated package cache; native device execution has not been verified. Windows desktop builds require plugin symlink support and iOS requires macOS/signing credentials.

## Demo sequence

Start the API and web app as README describes. Create two local accounts; upload/review a CV; complete a challenge; check the actual +0.6 first-badge score; add a proof submission and inspect it with an operator-granted independent reviewer; opt into discovery; compare/save a candidate; create then revoke a share link. GitHub OAuth needs an operator-configured OAuth app and personal consent. No verification is fabricated when a provider is unavailable.

Original branding: `assets/brand/auctor-mark.svg`, exported platform launchers, favicon, PWA icons and social preview. Screenshots and real test output can accompany a portfolio write-up. No commits, deployment or provider-secret changes were performed.

## Review artifacts

The following are real Chrome renders connected to the local API, with explicitly labelled QA data: [landing](screenshots/landing-desktop.png), [workspace](screenshots/overview-desktop.png), [CV editor](screenshots/cv-review.png), [assessment](screenshots/challenge-result.png), [profile](screenshots/profile-desktop.png), [mobile](screenshots/overview-mobile.png) and [mobile dark](screenshots/overview-mobile-dark.png). The desktop overview precedes the challenge; mobile screenshots show its actual 0.6 result.

The Android debug artifact is generated at `build/app/outputs/apk/debug/app-debug.apk`; the review web bundle is `build/web`. Generated builds remain ignored. No iOS build, device run, hosted deployment, live provider consent, remote CI execution or credential rotation is claimed.

The [actual connected browser demonstration](demo/auctor-connected-workflow.webm) shows CV editing, server grading, private-link revocation and responsive themes. Its [fixture and reproduction notes](demo/README.md) distinguish demonstration data from live provider evidence.

