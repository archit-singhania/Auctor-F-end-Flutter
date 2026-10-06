# Auctor visual refinement · October 6, 2026

The maintained Flutter client now uses warm ivory, deep graphite, patinated jade and champagne. Newsreader adds an editorial display voice; Inter remains the body/control typeface. Both fonts are bundled with their SIL license files, so the typography has no runtime font-provider dependency.

`lib/premium/visual_theme.dart` owns semantic colors and typography for authentication, the workspace, public profiles and reviewer views. Light-theme text uses bronze rather than pale champagne; dark-theme accents use champagne and jade mist. Chips, fields, focus rings, menus, notifications, navigation and readable content cards follow the same tokens. Glass remains on navigation and dialogs, with reduced motion/transparency and high contrast retained. Modal headings now expose their title correctly to assistive navigation.

The independently served `/landing/index.html` now matches the product. Its workspace links work; illustrative scores, placeholder pricing, invented testimonials and disconnected video controls were removed. It supports system light/dark appearance, small screens, reduced motion/transparency and local fonts.

The companion API's PDF and SVG outputs share the same identity. The PDF has a serif heading, score card, flowing evidence and numbered pages. A three-page synthetic report was rendered and inspected for text wrapping, escaping and footer alignment. SVG width adapts to the handle length; a maximum-length handle was checked as valid XML. JSON, privacy, score weights and access rules are unchanged.

## Verification

- Flutter analysis: no issues found.
- Flutter tests: **23 passed**, including all six developer destinations at 390/1440 pixels in both themes, 180% text, opaque/high-contrast behavior, dialog heading semantics and five font-loaded visual fixture captures.
- Production JavaScript web build: passed, targeting the existing local API/web origins (8011/8041).
- API/PostgreSQL: **18 tests passed** in an isolated temporary schema/private-file directory.
- Real local Chrome workflow: passed sign-in, CV review/save/readback, server-graded Docker assessment (5/5; +0.6), badge details, graph/roadmap readback, profile, private share/revocation/redaction, persistent session restoration and mobile light/dark; zero browser page errors.
- Marketing Chrome checks: desktop, 390-pixel mobile and dark theme passed; local fonts and working workspace links confirmed; no horizontal overflow or browser page errors.
- Android debug APK: the final packaging rebuild passed offline with JDK 21 in 2m 35s (236 tasks; 28 executed, 208 up-to-date). The archive contains both bundled fonts, both SIL license files and the emulator API/profile origins (8011/8041). It reused the documented local Gradle cache; no global Java settings changed. Native device execution is not claimed.

The font licenses are explicitly listed in `pubspec.yaml`. The license-only packaging recheck passed offline dependency resolution, Flutter analysis (63.1 s) and the JavaScript release rebuild (10.4 s). Inter, Newsreader and both license text files match their source bytes in the web bundle and APK. A temporary `http://localhost:8041` preview served `main.dart.js` and all four files with HTTP 200 and matching bytes, then stopped. Existing journey-test results above were retained; the source API was not restarted for this packaging check. The final APK is 181,183,521 bytes; the full web bundle is 43,801,424 bytes.

The browser script's graph screenshot check now verifies that the heading and final source control fit inside the actual viewport. Its former fixed top-of-screen requirement failed at a 1900-pixel viewport where the whole graph was already visible. The test still checks real source controls and backend readback.

## Inspect manually

Follow [the setup/manual guide](MANUAL_TESTS.md), then open `http://localhost:8041`. Refresh to load the latest web bundle. Expect editorial headings, warm paper cards, jade actions and bronze accents in light mode; graphite content, jade mist actions and champagne accents in dark mode. The mobile dock scrolls to additional destinations and remains reachable with larger text. Use Appearance to select light/dark/system and Profile to enable reduced motion, reduced transparency or increased contrast.

Check Evidence → Review & edit, complete a challenge, inspect the source graph and create/revoke a sharing link. Saved work and score changes still come from the API. Restart the API from source before checking the redesigned PDF export and score badge. Open `http://localhost:8041/landing/index.html` for the new marketing page; every workspace call to action opens the real app.

Current screenshots are in `screenshots/refinement-2026-10-06/`. Files prefixed `browser-` show the real local application with a labelled synthetic QA account. Other workspace images are explicit widget-test fixtures; `marketing-*` are browser captures of the static public page. Historical release evidence remains separately dated.

[Current artifact fingerprints and verification metadata](visual-refinement-2026-10-06.json) describe this revised web bundle and Android APK; the earlier release record is historical.

Native device execution, iOS/macOS signing and live provider consent remain the existing manual gates. Web bundles use localhost; public hosting is still deferred.
