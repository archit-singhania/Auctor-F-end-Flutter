# Auctor — full local audit, started 2026-10-05; completed 2026-10-06

Auctor is an owned developer-evidence workspace: Flutter web/mobile UI, FastAPI, PostgreSQL, private PDF storage and a durable extraction worker. All 20 approved capabilities have connected implementations. This audit verifies local software behavior and distinguishes external consent/device acceptance from implementation.

## What changed in this audit

- Rebuilt the interaction material with a reusable `LiquidGlass`: scoped backdrop blur, pearl/graphite tint, a highlighted rim, soft exterior elevation and pointer-responsive lighting. There is no idle animation or shader dependency. Evidence tables, score descriptions and documents remain readable opaque content.
- Applied this material to the desktop navigation rail, mobile navigation dock, workspace toolbar and every maintained modal sheet. Selected destinations use a restrained pine/champagne pill. Mobile navigation scrolls horizontally, with text and semantic selected states.
- Added persisted Increase contrast alongside light/dark/system, Reduce motion and Reduce transparency. Contrast or reduced transparency disables blur; reduced motion disables hover motion/navigation transitions. Icon/outlined controls use 48 px targets.
- Fixed actual mobile/large-text overflow in toolbar headings, assessment history, CV actions, section actions, GitHub controls, score ring and the candidate score filter. The regression suite visits all six normal destinations in light/dark at 390/1440 px and with 180% text.
- Bundled the licensed Inter font and CanvasKit engine locally so startup does not need a font/engine CDN. The original Auctor provenance mark and platform exports remain consistent.
- Fixed a response that sends HTTP headers then stalls: the complete JSON body has a deadline. Disposed controllers no longer notify listeners after asynchronous responses. Offline sign-out clears private local state and explicitly reports that server revocation could not be reached.
- Bounded appearance payloads and validated accessibility flags on the server. Preferences cannot silently treat the text `"true"` as a boolean.
- The actual browser continuation found that the installed file picker does not implement web `saveFile`. Source/proof and PDF/JSON reports now use a private local Blob download in browsers; native platforms retain their save picker. Desktop writes use its returned path, while mobile pickers write the supplied bytes. No bearer token is put in a download URL.
- Removed duplicate navigation announcements caused by the tooltip and visible label both entering accessibility semantics. A regression verifies the label is announced once and the control remains actionable.

The design uses the requested [Liquid Glass Design gallery](https://liquidglassdesign.com/), [guide](https://liquidglassdesign.com/guide), and [prompt library](https://liquidglassdesign.com/prompts) as visual references. An original implementation applies their restrained floating controls and soft lighting; no gallery assets are copied. It follows [Apple material guidance](https://developer.apple.com/design/human-interface-guidelines/materials) by keeping glass in the interaction layer. Flutter uses a clipped [BackdropFilter](https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html), rather than claiming Apple's native optical refraction.

## What to expect visually

At desktop width, a floating glass rail sits beside a tinted toolbar and spacious ivory evidence cards. The score summary has a champagne progress ring, with transparent component calculations beneath. Graphite mode retains visible text, edges and selected controls. At 390 px, navigation becomes a scrollable floating dock, toolbar actions move onto a second line and the score explanation stacks below its ring. Sheets have softly lit rounded frames; their forms/actions scroll within the viewport. At 180% text, content grows and scrolls instead of clipping; the dock remains reachable. The interface becomes opaque with stronger borders under Increase contrast or Reduce transparency.

## Start and inspect

Open **http://localhost:8041**. API readiness: **http://localhost:8011/health**; OpenAPI: **http://localhost:8011/docs**. The local release intentionally targets those origins and is not a public deployment bundle.

PowerShell window 1:

```powershell
Set-Location 'D:\remaining-4-git-projs\auctor\Auctor-B-end-FastAPI'
$env:APP_ENV='development'
$env:ALLOWED_ORIGINS='http://localhost:8041'
$env:WEB_URL='http://localhost:8041'
$env:OPENAI_API_KEY='' # Local extraction; no paid provider call.
$env:PYTHONDONTWRITEBYTECODE='1'
.\.venv\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8011
```

PowerShell window 2:

```powershell
Set-Location 'D:\remaining-4-git-projs\auctor\Auctor-F-end-Flutter'
& '..\Auctor-B-end-FastAPI\.venv\Scripts\python.exe' -m http.server 8041 --bind 127.0.0.1 --directory build/web
```

Reuse an already running preview instead of starting a second process on its port. PostgreSQL and the private ignored `.env.local` must remain available; do not overwrite its private DSN or delete `_data`. A fresh clone uses each repository's README setup instructions. `/health` must report ready/connected/schema 2/development/local-private. A failed database migration stops startup.

Generate labelled synthetic input:

```powershell
Set-Location 'D:\remaining-4-git-projs\auctor\Auctor-B-end-FastAPI'
.\.venv\Scripts\python.exe scripts/create_manual_fixtures.py
```

The ignored `_data/manual-fixtures` contains `synthetic-cv.pdf`, `synthetic-proof.pdf`, `coding-profile.json`, `invalid.pdf`, `damaged.pdf` and `blank.pdf`. These prove software workflow behavior, never real employment/certification or independent competence. Register separate developer and reviewer test accounts with unique `example.test` addresses, lowercase handles and passwords of at least ten characters.

## All 20 capabilities: manual actions and expected results

| # | Feature and where to check | Expected real result |
|---|---|---|
| 1 | Evidence → Upload CV, choose text PDF; Cancel/Retry on active/failed jobs | PostgreSQL job transitions queued/running/succeeded or failed; actual claims read back. Cancelled/failed jobs retry; unreadable inputs stay failed and never replace the old CV. |
| 2 | Evidence → original-source download → Review & edit | Owner sees the exact source, review-required provenance and editable claims. Saved claims remain unverified; a source URL alone proves no ownership. |
| 3 | Evidence → CV history → Compare/Restore | Correct added/removed skills/projects; restoration appends a durable revision and preserves old ones. Another account cannot restore your revision. |
| 4 | Overview → Connect GitHub | Configured OAuth requires personal consent and single-use state. Without settings, explicit unconfigured error; arbitrary public usernames never become verified. |
| 5 | Evidence → Add evidence → project | Choose a current CV project and an OAuth-owned repository. Unowned repositories are refused. Disconnecting GitHub removes its provenance contributions. |
| 6 | Overview → Repository intelligence | Cached public owned repositories/languages/stars and bounded recent-event scope, real sync time and current/aging/stale status. Reconnect refreshes the snapshot. |
| 7 | Challenges | Five implemented server tracks: JWT, Docker, REST API, PostgreSQL and Redis. Unsupported CV skills never invent challenges. |
| 8 | Challenges → Start challenge → select all answers → Submit | Five-minute server deadline, server grading, owned attempts and idempotent replay. A fresh Docker 5/5 yields +0.6; re-passing adds zero, failed retries retain the badge. |
| 9 | Challenges → Badge details / assessment history | Owned earned state, actual question scope, start/expiry/submission/result and deltas. A badge means passing the scoped five-question assessment. |
| 10 | Overview → Skills and their evidence → skill → Inspect source connection | CV declarations, project technologies, owned provenance and scoped assessments remain distinct; assessment sources open their actual badge detail. |
| 11 | Overview → Skill roadmap → Assess this gap | Actual CV/project gaps are ranked and map to the exact supported challenge. Unsupported skills have an honest reason and next steps. |
| 12 | Evidence → experience → Attach PDF proof; distinct Reviews account | Pending proof adds no points. Independent approval/rejection persists; self-review is forbidden. One reviewed experience contributes at most 1.5. |
| 13 | Evidence → certificate → issuer/reference/date/source; Reviews | Issuer/source/proof and rationale are inspectable and retained in review audit. Certificates add zero formula-v1 points. |
| 14 | Evidence → Import coding profile JSON | Recognized HTTPS profile source and bounded integer count/digest import as user-supplied/unverified. 150 approved problems contribute 0.75; upload alone contributes zero. |
| 15 | Overview → What contributes | GitHub 25%, coding 15%, badges 30%, projects 15%, experience 15%; fractions and actual points agree with persisted eligible evidence. |
| 16 | Activity → Score evolution → Compare score signals | Durable score/input snapshots, true component/evidence deltas including zero-point changes; missing older baselines explicitly labelled. |
| 17 | Activity → Reviewer decision audit; Reviews → Recorded decisions | Reviewer/time/source/issuer/rationale remain after evidence removal. Ordinary users cannot read the global audit or another account's private audit. |
| 18 | Profile → Save profile → Create link / public opt-in / Revoke | Redacted recruiter profile omits private contacts/proof bytes. Discovery is opt-in; private share can work separately. Revoke makes that link unavailable/404 and survives restart. |
| 19 | Discover → search/minimum score → Save → select Compare | Only opted-in candidates appear; saved state is account-owned. Compare two/three profiles using actual evidence/score components. Turning privacy off removes public access. |
| 20 | Profile → Download PDF / Export structured data / QR / Copy embed badge | Real parseable downloads, readable QR and discoverable-profile SVG. Exports are owned redacted reports; private records cannot be selected by a client `user_id`. |

For repeatable local Docker practice, choose: Separate build tooling from runtime; Content-addressed image; Runtime secret injection; Application readiness/liveness condition; Non-root with minimum permissions. Question order changes. This known-answer check tests software grading, not a candidate assessment.

To enable only a deliberately created local reviewer, use the operator command from the API repository:

```powershell
.\.venv\Scripts\python.exe -m app.manage grant-reviewer your-local-reviewer@example.test
```

Sign in to that distinct account, inspect labelled synthetic proof and record a rationale of at least ten characters. Never grant arbitrary candidates reviewer privileges. [The detailed manual guide](MANUAL_TESTS.md) adds denied access, timeout, failed-save, invalid-PDF, share-revocation and persistence checks for every journey.

## Verification boundaries

Backend tests use a randomly named isolated local PostgreSQL schema and separate temporary private files; teardown removes only that exact generated schema. User database records/files are preserved. Browser tests create clearly labelled local synthetic accounts, exercise actual Flutter controls/native browser file pickers and inspect API read-back; they refuse non-local targets. The role grant changes only the generated synthetic reviewer.

Live GitHub OAuth consent, optional paid parsing, physical Android/iOS execution, VoiceOver/TalkBack, native camera/pickers, macOS signed iOS, public deployment, HTTPS/private volume/backups and account-owner credential rotation are separate acceptance gates. There is no production deployment or automatic proof of employer/certificate legitimacy. Secrets formerly present in Git history still require owner-controlled rotation before publication. No user records, source environments or credentials were deleted by this audit.

## Evidence and artifacts

Fresh numerical results, screenshots and artifact fingerprints below are recorded from completed checks on this source. Historical October 3 videos in `docs/demo` remain labelled with their original date; the fresh captures are linked separately.

| Check | Completed result and date |
|---|---|
| PostgreSQL/API tests | **18 passed in 72.72 s**, October 5. Reused the completed run; only the generated isolated schema and temporary private files were removed. |
| Maintained Flutter analysis | `flutter analyze --no-pub lib test`: **No issues found**, 14.3 s, October 6. |
| Flutter regression suite | **17 passed**, October 6. The prior October 5 run had 16; the new test verifies one accessible navigation label and an actionable control. |
| JavaScript web release | **Built successfully in 49.4 s**, October 6, using the local 8011/8041 origins, bundled Inter and bundled CanvasKit. The earlier October 5 build completed in 166.6 s before the browser export correction. |
| Android debug | **JDK 21 build successful in 44 s**, 236 tasks (28 executed, 208 up-to-date), October 6. The initial JDK 25 attempt failed; no global Java/Flutter settings were changed. Both emulator origins were verified in the final APK's compiled assets. |
| Production guards | **2 Node tests and Bash syntax passed** in the completed October 5 verification; no production activation occurred. |
| Actual Chrome workflows | **22 groups passed, zero page errors**, including 14 previously completed groups resumed for the same generated account. See [workflow results](full-audit-browser-results-2026-10-06.json). |
| Final Chrome layout | **13 groups passed, zero page errors**: all six 390 px destinations in both themes, plus desktop/tablet. See [final layout results](full-audit-layout-results-2026-10-06.json). |

| Current artifact | Bytes | Last write UTC | SHA-256 |
|---|---:|---|---|
| `build/app/outputs/apk/debug/app-debug.apk` | 181,175,267 | 2026-10-06T06:39:19.3254527Z | `07DFE64A25B95D69B823CD3EF0235016FB608BEA20C14AD0D0B64BB5E9267E1D` |
| `build/web/main.dart.js` | 3,064,304 | 2026-10-06T06:37:49.8018054Z | `C289C7A97AE4F0E3D0700D378AECC2DCF4E107A5DD0D6A78A04BBD3CE904BF75` |

The builds retain upstream Cupertino-font/tree-shaking and Gradle/Kotlin deprecation notices. The maintained analysis and tests pass; these notices are not presented as native-device validation. JavaScript is the verified web target. The local web release is a review artifact; the Android debug artifact targets the emulator aliases documented above. Neither is a public deployment bundle.

The full 22-group workflow used the preceding bundle SHA-256 `1652804630BE4698B1E6E2989CFF2CA92D3D560361C4C84963A99EF33B541B00`. A final dock-width correction kept the mobile Challenges label on one line; the final source then passed the analyzer, 17 tests, both builds and the targeted 13-group layout check. Workflow/backend behavior was unchanged, so the completed full journey was reused.

Every external HTTP origin was blocked during the final layout check. Flutter attempted its built-in fallback at `fonts.gstatic.com`; the blocked attempt is recorded separately from local Inter and CanvasKit, which returned HTTP 200. The final captures show readable labels in both themes. Reproduce with `scripts/full-audit-browser.cjs` and `scripts/full-audit-layout.cjs`; [final metadata](full-audit-metadata-2026-10-06.json) records exact artifact and curated screenshot fingerprints.

The stable [October 6 screenshot folder](screenshots/full-audit-2026-10-06) contains 28 curated captures: 13 workflow captures from the preceding bundle and 15 layout captures from the final bundle. Inspect the final [desktop overview](screenshots/full-audit-2026-10-06/overview-glass-desktop.png), [dark desktop](screenshots/full-audit-2026-10-06/overview-glass-desktop-dark.png), [light mobile dock](screenshots/full-audit-2026-10-06/mobile-light-overview.png), [dark mobile dock](screenshots/full-audit-2026-10-06/mobile-dark-overview.png) and [tablet](screenshots/full-audit-2026-10-06/overview-768.png). Workflow evidence includes [CV comparison](screenshots/full-audit-2026-10-06/cv-version-comparison.png), [server grading](screenshots/full-audit-2026-10-06/server-graded-docker.png), [candidate comparison](screenshots/full-audit-2026-10-06/candidate-comparison.png) and [owner review audit](screenshots/full-audit-2026-10-06/owner-review-audit.png). Transient failure captures remain only in ignored logs.
