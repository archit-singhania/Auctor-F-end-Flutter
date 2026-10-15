# Evidence comparison and interview practice — October 15, 2026

Open **Profile → Evidence & interview atelier**. The workspace uses the existing account palette, glass surfaces, large-text support and motion/transparency controls. Text stays on readable surfaces; changed lines use the semantic highlight color. On desktop the comparison panes sit side by side; on a narrow screen they stack.

## Evidence comparison

1. Save two CV revisions in Evidence, or choose existing evidence records. For PDF comparisons upload and parse the PDFs first. GitHub repository choices require an existing ownership connection and use its cached metadata.
2. Choose **Snapshot CV revision**, **Snapshot evidence record** or **Snapshot cached repository**. Extraction runs in a durable worker. Watch queued/running/ready; failed or cancelled snapshots offer Retry. Cancelled work cannot later overwrite the cancelled state. Retrying uses the frozen source metadata.
3. Select ready **Before snapshot** and **After snapshot**, then **Compare saved snapshots**. Inspect both text panes and highlighted changes. The comparison retains source IDs, claim revision references and hashes. It does not automatically verify a claim.
4. For PDF-backed revisions use **Download authorized original PDF** to inspect the actual document in a PDF viewer. Only the owning account can download it. The comparison itself covers extracted text, not layout/pixel authenticity. A document without extractable text fails explicitly.
5. **Add line annotation**, choose a side/line and enter the observation. Keep it, then **Save annotations**. Notes survive reload. Concurrent stale writes fail and retain the unsaved draft. Reopen a saved comparison from the selector.
6. Another account must not access snapshots, comparisons or source files. Cached repository snapshots describe observed metadata, not source-code analysis, complete contribution history or runtime dependencies.

Cancellation prevents saved completion; an already running PDF extraction thread may finish in the background. Snapshot text is bounded to 2,000 lines / 100,000 characters and explicitly labels truncation. Existing snapshots stay immutable when the current CV, review status or repository cache changes. Archived selected comparisons load their owned snapshots even when outside the recent list.

## Interview practice

1. Review and save role requirements in **Role-fit atelier**, then choose **Interview practice** and **Refresh workbench**.
2. Select requirements, optional owned evidence and a duration. Choose **Start practice session**. If the role changed since selection, refresh instead of silently practising a different requirement.
3. Answer the curated prompts. The countdown uses the stored server deadline and continues across navigation/relaunch. Selected evidence/status is retained as session context, not newly verified proof.
4. Mark the situation/tradeoff/outcome/evidence self-review items and **Save practice answers**. The deterministic review lists word counts, numeric-detail presence and a reusable checklist. It is not an AI grade or a competency judgment.
5. Navigate away/back: unsaved drafts remain within the signed-in app. Explicitly save before refresh/sign-out; this is memory retention, not disk backup. Saved answers and checklist selections survive application restart.
6. **Complete practice** freezes the session. Reopen it using the saved-session selector. A stale write or another account must be rejected. Practice never issues badges or changes the developer score.
7. After time elapses, the UI labels it clearly and permits reflection/editing until completion. This is timed practice guidance, not a certified timed assessment. Optional AI feedback is not included in this release.

## Verification and local setup

Backend: 30 isolated PostgreSQL tests passed, including real PDF extraction/download authorization, comparison changes and line bounds, annotation conflicts, cancellation/retry, frozen repository snapshots, practice ownership, stale-role checks, completion and unchanged scoring. Flutter: 28 regression tests passed; focused workbench checks repeat phone/desktop drafting and timer states. Analysis clean. Current build/browser results and hashes are recorded in the accompanying JSON receipt.

The acceptance web bundle targets `http://127.0.0.1:8106`. For normal use build with your API URL as in the README. Android debug defaults to the backend on `http://localhost:8000`; use `adb reverse tcp:8000 tcp:8000` or build with a reachable URL. These changes add schema version 5 and a snapshot worker; they do not replace existing data. Physical Android/iOS and provider-based feedback checks are unverified.

Final web Release and Android debug builds passed. Actual Chrome acceptance passed comparison creation, annotation persistence, saved/completed practice, both-theme/phone captures and reload with no page errors. [Source/artifact hashes and results](WORKBENCH-2026-10-15.json). Existing Gradle/AGP/Kotlin and unused Cupertino-font warnings remain.
