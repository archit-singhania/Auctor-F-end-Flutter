# Auctor premium motion · October 6, 2026

Auctor now presents evidence with a short, measured settle. Destination content fades and moves ten pixels into place in 220 ms; newly mounted proof cards settle in 220–280 ms, compact server states crossfade in 180 ms, and claim, CV, assessment and reviewer sheets share a 220 ms entrance and exit. Public profile routes use the same restrained fade. The score digits show the API's exact value while the ring settles between server values. Assessment success appears only after grading and workspace readback; the actual score delta stays individually accessible.

The workspace mounts each destination on its first visit and retains its identity. Returning to Profile keeps an unsaved draft and that destination's scroll position. Theme/preference changes and failed refresh notices preserve the form and focus. Inactive destinations leave the keyboard traversal and animation tree. Dialog routes explicitly keep keyboard traversal inside the sheet and respect safe screen bounds. Stable evidence, activity, review and history keys keep existing records from becoming new records when lists update.

Profile → A considered experience now offers **Ivory & Jade**, **Linen & Ink**, and **Rose & Slate**. These curated accents share warm paper, graphite, champagne, bundled Inter body text and bundled Newsreader display text. They persist as `preferences.palette` through the existing profile endpoint; unknown values fall back to Ivory & Jade. Navigation, input focus, selected states and backgrounds use the selected semantic colors. The provenance mark, public landing and API PDF/SVG exports retain Auctor's canonical jade identity.

Reduce motion and the system's reduced-motion setting make route, card, sheet, score-ring and status transitions immediate. Reduced transparency uses opaque navigation/sheets; increased contrast strengthens borders and removes glass. The palette control fits 180% text on a 390-pixel screen. No ambient animation runs inside a loaded workspace. The public landing uses a one-time 240/280 ms hero settle and turns it off for system reduced motion.

## Verification

The [machine receipt](premium-motion-2026-10-06.json) records the final source/build fingerprints and exact check outcomes. [The browser receipt](premium-motion-browser-2026-10-06.json) records actual local Chrome checks with labelled synthetic accounts. Current browser screenshots live in `screenshots/motion-2026-10-06/`; historical refinement evidence remains separately documented.

Flutter regression checks cover reduced motion settling immediately, preserved profile draft/focus/scroll (including failed refresh notices), unknown palette fallback, persisted preferences, individually accessible server-grade results, all six developer destinations at 390/1440 pixels in light/dark, 180% text and opaque high contrast. Backend tests use an isolated PostgreSQL schema and temporary private-file directory; they cover real grading, reviewer decisions, preference readback, PDF/SVG endpoints and privacy rules. Browser checks exercise the real app and API, rather than presenting widget fixtures as a browser journey.

## Inspect manually

Use [the existing local setup](MANUAL_TESTS.md), start API 8011 and serve the current `build/web` on 8041. Refresh after rebuilding.

1. Open Profile, type an unsaved name, scroll down, visit Evidence and return. Expect the draft and Profile's scroll position to remain. Change the palette: field focus and text should remain; a browser reload restores the saved palette. Use the dropdown with pointer or Arrow Up/Down and Enter.
2. Open Evidence → Review & edit or Add evidence. Expect a short sheet settle with readable opaque content when comfort preferences are enabled. Tab stays inside the sheet; closing returns to the workspace.
3. Complete an assessment. Expect selected answers to remain stable during the countdown, then an exact server-confirmed result and score delta. No score change is announced before the server responds. Inspect Overview's exact score and Activity's persisted event.
4. As a separately authorized reviewer, record a reasoned decision on a labelled test submission. The pending source changes only after the API succeeds; recorded audit entries persist. Owners can refresh to inspect the new status and actual score.
5. At 390 pixels, reach every destination using the scrollable dock. Enable reduced motion, reduced transparency and high contrast, and check system reduced motion too. Expect immediate motion, opaque sheets and readable controls. Open `/landing/index.html`: its hero stays static with reduced motion and every workspace call to action opens the app.

Android debug packaging is checked separately from execution. Native emulator/device runs, iOS/macOS signing, live provider consent and public hosting remain manual gates. Local verification never contacts GitHub/OpenAI providers or deploys the app.
