# Auctor local release record — 2026-10-06 continuation

All 20 approved capabilities have connected UI/backend implementations. The [October 5/6 full audit](FULL-AUDIT-2026-10-05.md) records the refreshed Liquid Glass interaction layer, local fonts/CanvasKit, large-text/accessibility corrections, bounded HTTP bodies, offline sign-out and the real browser-download correction. Live provider consent, public hosting, remote CI, signing and native-device acceptance remain separate gates.

## Completed build and test checks

| Check | Actual result |
|---|---|
| API/PostgreSQL | **18 passed in 72.72 s**, October 5, isolated generated schema/private files; completed result reused |
| Flutter | **17 passed**, October 6, including six destinations at 390/1440 px in both themes, 180% text, contrast/transparency, deadline/offline behavior and single navigation announcement |
| Maintained analysis | **No issues found**, `flutter analyze --no-pub lib test`, 14.3 s |
| JavaScript web release | **Built in 49.4 s**, October 6, local API/web origins and locally bundled Inter/CanvasKit |
| Android debug | **JDK 21 build successful in 44 s**, 236 tasks (28 executed, 208 up-to-date); process-scoped JDK and existing cache |
| Deployment guards | **2 Node tests and Bash syntax passed**, completed October 5 verification reused |
| Actual Chrome workflows | **22 groups passed, zero page errors**, including 14 completed groups resumed for the same generated account; [structured results](full-audit-browser-results-2026-10-06.json) |
| Final Chrome layout | **13 groups passed, zero page errors**, all six mobile destinations in both themes plus desktop/tablet; [structured results](full-audit-layout-results-2026-10-06.json) |

The initial October 5 JDK 25 Android build failed due to Gradle incompatibility. JDK 21 was selected only for the build process; no global Java/user IDE settings were modified. Upstream Cupertino-font/tree-shaking and Gradle/Kotlin deprecation notices remain in successful build logs. JavaScript is the supported verified web target; a WebAssembly release and native execution are not claimed.

## Current artifacts

| Artifact | Exact path | Bytes | Last write UTC | SHA-256 |
|---|---|---:|---|---|
| Android debug APK | `D:\remaining-4-git-projs\auctor\Auctor-F-end-Flutter\build\app\outputs\apk\debug\app-debug.apk` | 181,175,267 | 2026-10-06T06:39:19.3254527Z | `07DFE64A25B95D69B823CD3EF0235016FB608BEA20C14AD0D0B64BB5E9267E1D` |
| Web main bundle | `D:\remaining-4-git-projs\auctor\Auctor-F-end-Flutter\build\web\main.dart.js` | 3,064,304 | 2026-10-06T06:37:49.8018054Z | `C289C7A97AE4F0E3D0700D378AECC2DCF4E107A5DD0D6A78A04BBD3CE904BF75` |

Build outputs remain ignored. Android contains emulator API `http://10.0.2.2:8011` and web/profile origin `http://10.0.2.2:8041`, verified in its compiled kernel assets. The web build targets localhost:8011/8041. A physical device needs reachable origins rebuilt into both settings. These local artifacts do not qualify as public deployment bundles.

The 22 workflow groups used bundle SHA-256 `1652804630BE4698B1E6E2989CFF2CA92D3D560361C4C84963A99EF33B541B00`, before the final dock-width correction. The final bundle above passed the targeted 13-group layout check after that correction, with external HTTP origins blocked. Flutter attempted a built-in Google-font fallback at `fonts.gstatic.com`; that attempt was blocked while local Inter and CanvasKit returned HTTP 200 and all captured labels remained readable. [Final metadata](full-audit-metadata-2026-10-06.json) records both scopes and the 28 curated screenshot fingerprints.

## Historical evidence retained

The October 3 APK record was 181,162,967 bytes, SHA-256 `7C8824B5E26B2549D03DE4122E2400EFD206BB6F2039A26570045402FE271B52`; the October 3 web main was 3,048,954 bytes, SHA-256 `C1654C375E7B112A3A236E012194923BF3ECE136FAA8647CF8F0A4FCD6565078`. Those records are historical and do not describe the current build files above. The October 5 intermediate web main was 3,064,151 bytes, SHA-256 `D3B841148A675BCBF355731AF6EA1D0EB1CC4D98B462E3F9F6D09766898AC312`; the final web incorporates the browser download fix.

The unchanged [October 3 browser demonstration](demo/auctor-connected-workflow.webm) is **74.96 seconds**, VP8/WebM, 1440×1050, 25 fps: 7,086,737 bytes, last write 2026-10-03T05:21:37Z, SHA-256 `FD23A93527651A0641CF3FFBBBC02EBFABE3FE2746AE04F6449AB85FE9EC0AAF`. The nine existing top-level `docs/screenshots` files also retain their October 3 provenance. New captures are linked separately in the full audit; no new video replaces the historical demo.

## Use and remaining acceptance

Open **http://localhost:8041**; API readiness is **http://localhost:8011/health**. The local API/web preview processes were restarted for the October 6 audit. Follow the [all-20 manual guide](MANUAL_TESTS.md) for setup, synthetic fixtures, separate reviewer assignment, expected privacy/revoke/error/persistence/grading results and native-device testing. Preserve PostgreSQL, `_data` and the ignored private `.env.local`.

[Production activation](DEPLOYMENT.md) is prepared and deferred. Remaining gates are personal GitHub consent and live owned-repository statistics, optional paid extraction, production private-volume/backups and HTTPS, account-owner credential rotation, remote CI, iOS signing and actual native device/platform accessibility/picker/QR execution.

No commit, push, deployment, paid provider call, model download, credential rotation or deletion of ordinary user records occurred during this continuation. The browser creates labelled local synthetic accounts and changes only their evidence/privacy/reviewer state.
