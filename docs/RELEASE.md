# Auctor local release record — 2026-10-03

The exact 20 approved capabilities are implemented with connected UI/backend operations; authenticated ownership, adaptive themes/accessibility and original branding are additional foundations. This local release does not close live provider, hosted production, remote CI, signed iOS or native-device acceptance gates.

## Verified outputs

| Check | Actual result |
|---|---|
| Backend | **18 passed**, latest isolated local PostgreSQL run in 60.54s; generated schema and temporary private files only |
| Flutter | **8 standard tests passed**, including draft retention and graph source → scoped badge detail |
| Analyzer | **No issues found** on final source |
| Web | JavaScript release build succeeded in 84.3s, local API/web origins compiled explicitly |
| Android | JDK 21 debug build succeeded in **3m 21s**, 236 tasks, latest feature views and both emulator origins included |
| Deployment guards | **2 Node tests passed**, plus Bash syntax; local/unconfigured/unready production API refused |
| Actual browser | Isolated Chrome passed sign-in, CV edit/save/readback, timed server Docker 5/5/+0.6, owned badge detail, graph/roadmap readback and visible graph, profile, private-link create/revoke/redaction, session reload, mobile light/dark; **zero page errors** |

Tests run against local labelled fixtures; provider-boundary OAuth tests mock only the external provider. Browser screenshots/video are actual Flutter/FastAPI/PostgreSQL operations, not UI mockups. The known-answer practice assessment is explicitly software testing.

## Artifacts

| Artifact | Exact path | Bytes | Last write UTC | SHA-256 |
|---|---|---:|---|---|
| Android debug APK | `D:\remaining-4-git-projs\auctor\Auctor-F-end-Flutter\build\app\outputs\apk\debug\app-debug.apk` | 181,162,967 | 2026-10-03T05:35:15Z | `7C8824B5E26B2549D03DE4122E2400EFD206BB6F2039A26570045402FE271B52` |
| Web main bundle | `D:\remaining-4-git-projs\auctor\Auctor-F-end-Flutter\build\web\main.dart.js` | 3,048,954 | 2026-10-03T05:12:52Z | `C1654C375E7B112A3A236E012194923BF3ECE136FAA8647CF8F0A4FCD6565078` |
| Browser demo | `D:\remaining-4-git-projs\auctor\Auctor-F-end-Flutter\docs\demo\auctor-connected-workflow.webm` | 7,086,737 | 2026-10-03T05:21:37Z | `FD23A93527651A0641CF3FFBBBC02EBFABE3FE2746AE04F6449AB85FE9EC0AAF` |

The video is **74.96 seconds**, VP8/WebM, 1440×1050, 25fps. Build outputs remain ignored; screenshots/video are review evidence. APK targets Android emulator API `http://10.0.2.2:8011` and web/profile origin `http://10.0.2.2:8041`; the web bundle targets localhost:8011/8041. Neither is a ready public deployment artifact. Android native execution remains unverified.

Both emulator origins were confirmed in the compiled APK assets. Start the API and web preview on reachable testing interfaces before an emulator journey. A physical device needs both origins rebuilt for its reachable hosts. Browser sharing was verified against the local 8041 preview; native QR and sharing still require device execution.

## Screenshot provenance

All nine tracked screenshots were copied from the same successful final isolated Chrome run on 2026-10-03. Account is **QA Developer (test account)**, handle `qa-1791004811613`; CV project **QA Orders API** and listed skills are synthetic. GitHub remains visibly unconnected; no live ownership or employer claims are invented. New [badge detail](screenshots/badge-detail.png) shows the actual 5/5/+0.6/server expiry; [skills graph](screenshots/skills-graph.png) shows CV/project declarations separately from the scoped earned assessment. Mobile screenshots change actual viewport/media preference after session reload; the fixed video canvas leaves unused space beside the mobile viewport.

## Use and remaining acceptance

Open **http://localhost:8041**; API **http://localhost:8011/health** currently returns ready/connected/schema 2/development/local-private. API process is kept running locally and the web server serves `build/web`; processes depend on this computer remaining available. Follow [UI manual tests](MANUAL_TESTS.md) and the companion API `docs/MANUAL_TESTS.md` for restart/setup, labelled PDF/profile inputs and exact expected privacy/persistence/error/revoke/grading results.

The [exact feature matrix](PORTFOLIO.md) and [architecture](ARCHITECTURE.md) provide reviewer context. [Deployment setup](DEPLOYMENT.md) is prepared and deferred. CI defines web/Android verification and artifacts plus macOS unsigned iOS release/artifact and manual dispatch; those remote jobs have not run. Remaining gates: live personal GitHub consent, optional paid AI parsing, actual production volume/backups, owner-controlled formerly exposed credential rotation, iOS signing and native device/platform validation.

No commits, push, deployment, provider credential rotation or user-data deletion were performed by this release work.
