# Auctor: local release and manual UI tests

This is the acceptance walkthrough for all 20 connected capabilities. Use labelled synthetic inputs and separate local accounts. The [acceptance record](PORTFOLIO.md) distinguishes implementation from actual automated/browser coverage; live provider consent, hosted deployment and native-device execution are not silently counted as complete. The companion API repository has `docs/MANUAL_TESTS.md` with PostgreSQL isolation and token ownership checks.

## Open the existing local release

Open **http://localhost:8041** in Chrome. The API is **http://localhost:8011**, with [OpenAPI](http://localhost:8011/docs) and [readiness](http://localhost:8011/health). Previews stay accessible while their local processes are running. The release bundle exists at `D:\remaining-4-git-projs\auctor\Auctor-F-end-Flutter\build\web`, compiled for those local origins. Do not publish this bundle: it intentionally targets localhost.

The [74.96-second actual browser demo](demo/auctor-connected-workflow.webm) and [screenshots](PORTFOLIO.md#review-artifacts) show real UI/API operations with labelled QA data. [Final release metadata](RELEASE.md) records exact APK size/date/hash and passed results.

## Restart from source

Preserve the private API `.env.local`, database and private source files. In the first PowerShell window:

```powershell
Set-Location 'D:\remaining-4-git-projs\auctor\Auctor-B-end-FastAPI'
$env:APP_ENV='development'
$env:ALLOWED_ORIGINS='http://localhost:8041'
$env:WEB_URL='http://localhost:8041'
$env:OPENAI_API_KEY=''   # local heuristic extraction, no paid provider calls
$env:PYTHONDONTWRITEBYTECODE='1'
.\.venv\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8011
```

Expected: PostgreSQL connects, additive migration reaches schema version 2, `/health` returns 200 with ready/connected/auctor-api. Startup fails on an unavailable database/migration error. A second process on an occupied port fails: keep the existing preview or stop only the process you started before restarting. See API README for fresh-clone database/venv setup.

In a second window, serve the existing bundle without needing Flutter:

```powershell
Set-Location 'D:\remaining-4-git-projs\auctor\Auctor-F-end-Flutter'
& '..\Auctor-B-end-FastAPI\.venv\Scripts\python.exe' -m http.server 8041 --bind 127.0.0.1 --directory build/web
```

Open `http://localhost:8041` exactly; browser origin/port must match API CORS. To rebuild with this machine's verified Flutter 3.47.3 SDK:

```powershell
Set-Location 'D:\remaining-4-git-projs\auctor\Auctor-F-end-Flutter'
$env:GIT_CONFIG_COUNT='1'
$env:GIT_CONFIG_KEY_0='safe.directory'
$env:GIT_CONFIG_VALUE_0='C:/Users/dell/develop/flutter'
$env:PUB_CACHE='D:\remaining-4-git-projs\auctor\Auctor-F-end-Flutter\.pub-cache'
& 'C:\Users\dell\develop\flutter\bin\flutter.bat' pub get
& 'C:\Users\dell\develop\flutter\bin\flutter.bat' analyze
& 'C:\Users\dell\develop\flutter\bin\flutter.bat' test
& 'C:\Users\dell\develop\flutter\bin\flutter.bat' build web --release --no-wasm-dry-run --dart-define=API_BASE_URL=http://localhost:8011 --dart-define=WEB_BASE_URL=http://localhost:8041
```

SDK cache/network writes must be permitted. Here `pub get` can download successfully then report missing Windows Developer Mode/symlink support for native plugins; analysis/tests/web build were still verified. Native Windows compilation needs that support. JavaScript web is the supported verified target; secure-storage currently blocks WebAssembly.

## Synthetic setup

Create A in the normal browser and B in a separate browser profile/incognito window. Use names **Manual QA A (synthetic)**/**Manual QA B (synthetic)**, unique lowercase handles of 3–32 characters, `example.test` emails and passwords of at least 10 characters. The same browser context shares session storage. Email verification and password recovery are not implemented.

Generate five local fixture PDFs and one profile JSON without inserting database rows:

```powershell
Set-Location 'D:\remaining-4-git-projs\auctor\Auctor-B-end-FastAPI'
.\.venv\Scripts\python.exe scripts/create_manual_fixtures.py
```

Files appear in `D:\remaining-4-git-projs\auctor\Auctor-B-end-FastAPI\_data\manual-fixtures`. Documents explicitly identify synthetic software-test input, never real employment/certification/ownership proof. Exact heuristic segmentation may need correction in the CV editor.

## Foundations: accounts, premium layout and preferences

1. **New here? Create an account → Create private workspace** creates an owned empty workspace with score 0.0. Invalid handles/short passwords show validation; duplicates show a conflict. Wrong-password sign-in gives a generic credentials error. No other user's data appears.
2. **Profile → Display name/Your story → Save profile**, reload: changes persist. Change **Appearance** between light/dark/system, and enable **Reduce motion/Reduce transparency**. Expected: stored account preferences survive refresh/sign-in; immediate transitions for reduced motion; opaque navigation for reduced transparency; system theme follows browser/OS preference.
3. Inspect at 1440px and 390×844px with responsive browser tools. Expected: desktop rail becomes mobile dock; content/dialogs scroll without clipped controls; original A mark and readable champagne/pine/graphite surfaces appear in both themes. Resize an open dialog, keyboard-tab inputs and increase zoom. Native VoiceOver/TalkBack still needs a device pass.
4. Reload while signed in: session restores. **Sign out**, reload: landing screen remains and old API bearer token gives 401. A's CV/private files remain invisible to B.

## CV processing, provenance and versions (1–3)

1. **Evidence → Upload CV**, choose `synthetic-cv.pdf`. Expected: queued/running/succeeded, extracted skills and a revision with review-required provenance. Fast processing may finish before the first refresh. Download original source via its icon: owner-only file, no verification inferred from extraction.
2. **Review & edit** also works on an empty CV. Set skills `Docker, REST API, PostgreSQL, Redis`; add **QA Orders API** with Docker/PostgreSQL and a labelled synthetic experience. Add profile links deliberately; URLs do not prove ownership. **Save reviewed CV**, reload: data persists, revision is appended, edited claims stay unverified and add no score points.
3. **Compare** an older revision: accurate added/removed skills and project lists. **Restore** appends a new restoration revision and makes previous data current; existing revisions remain.
4. Edit a skill, stop only your API process, save: error appears and the dialog/draft remains open. Restart API and retry: edit persists. This failure path also has a widget test.
5. `invalid.pdf` produces an immediate non-PDF error. `blank.pdf`/`damaged.pdf` may queue but must end failed without fabricated content. **Retry** requeues failed/cancelled jobs; the same unreadable input can fail again. **Cancel** works while queued/running without replacing the prior CV. If processing already finished, conflict is correct; controlled integration tests cover race boundaries. Limit 10 MB: larger input gives 413. Scanned textless PDFs are not an OCR capability.

## GitHub ownership, binding and cached analytics (4–6: optional live gate)

Without OAuth settings **Overview → Connect GitHub** reports unconfigured and never verifies an arbitrary username. Operator live setup needs an OAuth app ID/secret, exact callback `http://localhost:8011/api/github/callback` and current `WEB_URL`. Consent personally with your own account. Expected: single-use state, return to workspace, confirmed identity and bounded public owned-repository/language/star/recent-event snapshot. Reconnect refreshes it; tokens are discarded.

**Evidence → Add evidence → project** selects a current CV project and owned repository. Expected: contribution for that bound project, rejected unowned repositories. **Disconnect GitHub** removes linked GitHub/project contributions and recomputes score. Ownership is provenance, not code-quality certification. API tests mock only the provider boundary; no live consent was performed.

Inspect **Repository intelligence**: snapshot timestamp, elapsed hours, language/repository/star/event counts and cache status. Current means under 24 hours, aging under seven days, stale thereafter. Scope says public owned repositories and up to 100 recent public events; it never claims complete contribution history. Reconnect updates freshness; page reload derives age from the cached snapshot.

## Catalog, grading, badge details, skills graph and roadmap (7–11)

1. **Challenges** lists JWT, Docker, REST API, PostgreSQL and Redis. **Start challenge** opens five questions with five-minute timer. Starting the same active track resumes its server attempt; closing/reopening never resets server expiry.
2. Repeatable practice key for Docker, matched by meaning because question order varies: **Separate build tooling from runtime**, **Content-addressed image**, **Runtime secret injection**, **Application readiness/liveness condition**, **Non-root with minimum permissions**. **Submit answers** yields **5/5 correct. Actual score change: +0.6.** for a fresh account. This known-answer demo is software testing, not independent candidate assessment.
3. **Done → Overview** shows 0.6/10; Challenges shows badge/history. Re-passing adds zero; a later failed attempt retains the badge. Incomplete selections disable submission; the server independently validates answers. Wait five minutes on a fresh attempt: UI disables submission, API returns 409 for lateness. Replaying the same submitted POST returns the original result without inflating score.
4. Overview roadmap follows CV skills and passed tracks. Add Redis: its implemented track appears; unsupported skills do not invent assessments. Original v1 weights remain GitHub 25%, coding 15%, badges 30%, projects 15%, experience 15%.

5. **Challenges → Badge details** opens earned state, five-question scope, server expiry, submitted time/results and actual deltas. Another account has its own history. Later failures never remove earned state even when older successes are outside the recent list.
6. **Overview → Skills and their evidence**, select Docker after passing. Expected: assessed status with separate CV declaration, project technology claim and assessment connections. **Inspect source connection** on the assessment opens badge details; project links navigate to Evidence. Unassessed skills stay claimed/owned provenance, never certified by repository ownership.
7. **Skill roadmap** ranks supported unassessed gaps, unsupported skills, then earned tracks for deeper practice. Each row explains why and gives concrete next steps. **Assess this gap** launches its exact mapped challenge. Add Unknown Tool: explicit unsupported reason, no invented challenge. Pass Docker: assessed status and **Practice again**.

## Experience, certificate inspection, coding imports and review audit (12–14, 17)

1. A: **Evidence → Add evidence**, choose experience with labelled synthetic title and appropriate source; then **Attach PDF proof → synthetic-proof.pdf**. Expected: pending, no points. Add certificate and coding claim of 150 similarly. Typed/extracted URLs never auto-verify.
2. Register a distinct reviewer. An operator with private database access grants the deliberate local role from the API repo:

   ```powershell
   .\.venv\Scripts\python.exe -m app.manage grant-reviewer manual-reviewer@example.test
   ```

3. Reviewer refreshes/signs in and opens **Reviews**, inspects source/downloads proof, chooses **Verify evidence** or **Reject**, and writes at least 10 characters explicitly identifying the synthetic workflow test. Expected: item leaves pending queue; A sees decision, reason and activity. One reviewed experience contributes at most 1.5; 150 coding problems contribute 0.75; certificates have zero v1 points.
4. Ordinary users have no reviewer queue; self-review is refused; B cannot download A's proof; approved proof cannot be overwritten (new submission required). Removing evidence removes its score contribution and retains score history. This verifies workflow controls, never synthetic employer legitimacy.

5. Certificates require **Certificate issuer** in the new UI, with optional reference ID/date. Owner/reviewer views show those fields; decisions store source/issuer/reviewer/time/rationale. Legacy records honestly show not supplied. Certificates add zero v1 points.
6. **Import coding profile JSON → coding-profile.json** imports 150 claimed problems with source/digest and user-supplied/unverified status, pending review and no score points. It is a bounded structured import, not a live provider scraper. Invalid JSON/unrecognized source returns 422; over 64 KB returns 413. Independent source inspection precedes approval; the synthetic fixture remains a software test.
7. **Activity → Reviewer decision audit** and reviewer **Reviews → Recorded decisions** preserve who/when/source/issuer/rationale. Remove reviewed evidence: audit remains. Ordinary users cannot read the global audit; B cannot read A's private audit.

## Explainable versioned scoring and evidence comparisons (15–16)

Overview exposes each fraction/weight/contribution. **Activity** lists actual edits/jobs/grades/reviews. **Mark all read**, reload: read state persists only for that account. **Score evolution** records signal changes; repeated refresh/replay does not invent growth. Total/component values agree with `/api/me` within displayed one-decimal rounding.

Open **Compare score signals** on a snapshot: actual total/component deltas and evidence/skill/project/badge add/remove/status changes. Certificate approval changes evidence with zero points. Old missing input baselines are labelled unavailable; oldest visible snapshots never invent earlier scores. Read flags are supporting functionality beyond the approved 20.

## Redacted profiles, revoke and candidate discovery (18–19)

1. With discovery off, **Profile → Create link → Copy**, open `/#/share/<id>` logged out/B's context. Expected: redacted profile with no private contact/source/proof contents. **Revoke**, refresh: unavailable/API 404; state survives restart. A cannot revoke B's link.
2. Enable **Discoverable public profile → Save profile**. **Copy profile link/Preview public profile** work at `/#/public/<handle>`. Disable/save: public profile, search entry and SVG vanish. Private links have their own revoke setting.
3. Make A/B and a third labelled local account discoverable. B: **Discover**, search A's name/handle/skill, change **Minimum score**, **Save** and **Saved candidates**. Reload: B's save persists; A cannot read it. Choose up to three **Compare** chips, then **Compare (n/3)**: correct profiles and score breakdown. Search excluding a selected record clears stale selection. Scores are contextual, not hiring guarantees.

## Exports, QR and embed (20)

**Profile → Download PDF report** creates a readable real PDF; **Export structured data** creates parseable JSON of A's record. Confirm selected download location; cancellation must not crash. **QR code** while discoverable encodes the copied public link (other devices cannot reach this computer through their own localhost). **Copy embed badge** supplies the public score SVG/link while opt-in is enabled. Disable discovery: badge API returns 404. Native picker/QR scanning needs separate device validation.

## Automated browser reproduction

The script creates labelled local QA accounts/CVs and performs actual sign-in/edit/save/readback/Docker grading/private link create/revoke/redaction/session reload/mobile themes. It refuses non-local origins. New QA records remain in the configured schema; existing data is not removed.

```powershell
Set-Location 'D:\remaining-4-git-projs\auctor\Auctor-F-end-Flutter'
$env:AUCTOR_API_URL='http://localhost:8011'
$env:AUCTOR_WEB_URL='http://localhost:8041'
$env:AUCTOR_PLAYWRIGHT='C:/Users/dell/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright'
New-Item -ItemType Directory -Force -Path 'build/qa-temp' | Out-Null
$env:TEMP='D:\remaining-4-git-projs\auctor\Auctor-F-end-Flutter\build\qa-temp'
$env:TMP=$env:TEMP
& 'C:\Program Files\nodejs\node.exe' scripts/browser-qa.cjs
```

Expected: PASS and no browser page errors. Installed Chrome/Playwright are required; use your own module path on another machine. `AUCTOR_RECORD_VIDEO=1` records a fresh context and replaces the demo only on success. Test screenshots live in ignored `build/browser-qa`; tracked screenshots/video document the actual successful run.

## Android artifact and other device gates

Debug APK: **`D:\remaining-4-git-projs\auctor\Auctor-F-end-Flutter\build\app\outputs\apk\debug\app-debug.apk`** (181,162,967 bytes; built 2026-10-03, SHA-256 in [release record](RELEASE.md)). It targets emulator API `http://10.0.2.2:8011` and web/profile origin `http://10.0.2.2:8041`; debug allows HTTP, release requires HTTPS. Start both services on reachable testing interfaces as needed. A physical device needs a rebuild with the computer's LAN address; these emulator aliases will not work there.

Rebuild with JDK 21 (JDK 25 was incompatible with Gradle) using the verified direct command:

```powershell
Set-Location 'D:\remaining-4-git-projs\auctor\Auctor-F-end-Flutter\android'
$env:JAVA_HOME='C:\Program Files\Java\jdk-21'
New-Item -ItemType Directory -Force -Path '../build/qa-temp' | Out-Null
$env:TEMP='D:\remaining-4-git-projs\auctor\Auctor-F-end-Flutter\build\qa-temp'
$env:TMP=$env:TEMP
# Isolate future Gradle downloads from a full system drive; first run refills cache.
$env:GRADLE_USER_HOME='D:\remaining-4-git-projs\auctor\Auctor-F-end-Flutter\.gradle-local'
$env:GIT_CONFIG_COUNT='1'
$env:GIT_CONFIG_KEY_0='safe.directory'
$env:GIT_CONFIG_VALUE_0='C:/Users/dell/develop/flutter'
$env:PUB_CACHE='D:\remaining-4-git-projs\auctor\Auctor-F-end-Flutter\.pub-cache'
$auctorDartDefine=(@('API_BASE_URL=http://10.0.2.2:8011','WEB_BASE_URL=http://10.0.2.2:8041') | ForEach-Object { [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($_)) }) -join ','
.\gradlew.bat '-Dorg.gradle.java.home=C:\Program Files\Java\jdk-21' assembleDebug '-Ptarget-platform=android-arm,android-arm64,android-x64' '-Ptarget=lib/main.dart' "-Pdart-defines=$auctorDartDefine"
```

Install deliberately on a test emulator/device and repeat sign-in/upload/question scrolling/theme/session restart/report picking. Compilation succeeded; device execution is unverified. iOS/macOS need macOS/Xcode/signing; Windows native needs Developer Mode/symlinks; Linux needs native toolchains.

The supplied APK includes both emulator origins shown above, confirmed in its compiled assets. Native execution, including opening QR/profile links and sharing on a device, remains a manual acceptance gate. The verified browser bundle already uses 8041 correctly. A physical device needs both origins rebuilt for its reachable hosts.

## Completed work and remaining gates

Implemented: exact approved 20 capabilities plus branding/themes/authentication foundations, owned PostgreSQL jobs, truthful v1 scores, CI definitions, tests, JS bundle, Android debug build, screenshots/video and guides. **18 API tests and 8 standard Flutter tests passed**, including graph source → badge details. Two Node production guard tests and Bash syntax passed; final build/analyzer/browser results are recorded in the acceptance record. Remote CI execution is not claimed.

Hosting is deferred. Outstanding: live GitHub consent, optional paid AI parsing, production private-volume/backups, owner-controlled exposed-credential rotation, native devices/iOS signing. No fabricated outcomes replace these gates. [Deferred deployment notes](DEPLOYMENT.md) record exact legacy target references and safe future activation.

macOS unsigned iOS release build/artifact, Android artifact upload and manual dispatch are configured in CI but unrun remotely. Unsigned compilation does not establish signed installation or device readiness.
