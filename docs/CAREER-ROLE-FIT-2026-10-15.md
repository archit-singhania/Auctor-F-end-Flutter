# Career story and role fit — October 15, 2026

These additions extend the existing Profile workspace, ivory/jade Liquid Glass surfaces and account accessibility preferences.

## Manual checks

1. Run the backend and Flutter client as described in their READMEs. The backend applies additive schema versions 3–4; existing CVs, scores and evidence remain in their original tables. Sign in and open **Profile**.
2. In **Your career, in context**, add a dated project, experience or outcome. Add a narrative, annotation and links to your own evidence. Milestones start private. Dates must be valid calendar dates.
3. Keep a milestone, reorder using the earlier/later buttons or **Order by date**, and explicitly **Save story**. Unsaved edits remain during navigation within the signed-in app; they are not a disk backup. Save before refreshing or signing out.
4. Reopen Profile and reload the application. Saved ordering, dates, annotations and evidence links must remain. Two clients saving the same revision produce a conflict instead of silently replacing one another. **Reload saved story** asks before replacing a draft.
5. Enable **Include in public story** on a milestone and save. Create a private sharing link in the existing sharing section. The public page labels the text as candidate-written narrative. It only lists linked evidence that is currently verified; private files and unverified evidence links are omitted. Revoke the share and it must return unavailable.
6. In **Role-fit atelier**, paste a job description. **Suggest known requirements** recognizes Docker, PostgreSQL, Redis, REST and JWT families locally. It is intentionally limited; manually add other requirements. Check every suggestion and importance. Required defaults to weight 2; preferred to 1; explicit weights must be greater than zero and at most 10. Replace a requirement by removing/re-adding it.
7. Review the requirements, check the confirmation and **Save requirements**, then **Run evidence match**. Editing clears confirmation and prevents matching until the reviewed draft is saved again.
8. Inspect each contribution/source. A passed implemented assessment or eligible verified source explicitly listing the skill can support it. Repository provenance alone is partial context. Declarations earn zero coverage; unavailable evidence is unknown, not inability. None of this changes the existing developer score.
9. Reopen a prior snapshot: it retains the reviewed inputs, evidence, formula/vocabulary versions and input hash. Matching unchanged inputs reproduces the hash and contributions. Updated evidence requires a new match; historical results remain snapshots.
10. Navigate away/back with edits, test failed requests, and reload a saved role while offline. Drafts remain usable and errors are visible. Another account must not see these stories, requirements or private runs.

## Contracts and validation

`GET/PUT /api/career-story`, `GET/PUT /api/role-fit`, `POST /api/role-fit/runs`. OpenAPI is available from the backend `/openapi.json` and `/docs`. Updates use revision checks; matching requires reviewed saved requirements. Career stories use their existing public-profile/share authorization; private role snapshots are not published.

Backend: 25 tests passed against an isolated local PostgreSQL schema, including weighted coverage, stale evidence exclusion, duplicate aliases, ownership, public redaction, reproducible hashes and unchanged score. Flutter: 26 regression tests passed; analysis clean. Subsequent focused checks cover JSONB key order and offline recovery. Real Chrome/API acceptance verifies editing, role review/matching, persisted reload and share revocation.

## Limits

This release stores one current target-role document with up to 20 displayed immutable match snapshots. Extraction is a deterministic five-family helper; it is not general semantic job parsing. Evidence coverage is not a hiring recommendation or competency guarantee. Draft retention is in memory until explicitly saved. Public evidence metadata links refer to the existing evidence summary; no private proof-file access is granted. Physical-device/iOS checks are unverified. Browser builds use JavaScript; the existing secure-storage dependency does not support Wasm builds.

The current web acceptance bundle targets `http://127.0.0.1:8106`; rebuild with your own `API_BASE_URL` for ordinary local use. The Android debug app uses the default backend `http://localhost:8000`; for a connected emulator/device use `adb reverse tcp:8000 tcp:8000` with the API running on the host, or build with the appropriate device-reachable URL. No public deployment is included.

Current web Release and Android debug builds passed. The final Chrome run also verified light/dark rendering and that matching unchanged saved requirements does not create a false unsaved state. Exact source/artifact hashes and results: [acceptance receipt](CAREER-ROLE-FIT-2026-10-15.json). Build tooling emitted existing Gradle/AGP/Kotlin, SDK XML and unused Cupertino-font warnings; they did not fail the builds.
