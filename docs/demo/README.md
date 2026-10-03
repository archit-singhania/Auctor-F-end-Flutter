# Auctor connected workflow demonstration

[Watch the local browser recording](auctor-connected-workflow.webm).

Duration: 74.96 seconds. Format: WebM/VP8, 1440 × 1050, 25 fps. Final local recording: 2026-10-03. The mobile section changes the actual browser viewport and appears within the same recording canvas. Actual same-run badge/graph screenshots were visually checked; artifact size/hash/date appear in the release record.

The recording uses a fresh isolated Chrome context connected to the actual local Flutter/FastAPI/PostgreSQL implementation. The account is labelled **QA Developer (test account)**. Its CV contains a disposable **QA Orders API** project and test skills; these are demonstration fixtures. The recorded assessment is answered by the software test using known question choices. The server genuinely grades the submission and persists the resulting **0.6** score.

The flow shows sign-in, workspace, CV edit adding Redis, saved revision readback, timed Docker grading, owned badge details, actual evidence-linked skills graph, profile, link creation/revocation, restored session and mobile themes. Alongside visible actions, HTTP assertions verify graph/roadmap state, owned badge result, revoked 404 and omitted contact email.

GitHub OAuth, independent human review and native device execution have separate acceptance coverage and are not demonstrated in this video. This recording provides local functionality and visual evidence for a portfolio; it does not show adoption, deployment or a professional competency assessment.

To reproduce after starting the local API and web bundle, set `AUCTOR_RECORD_VIDEO=1` and run `node scripts/browser-qa.cjs` from the Flutter repository. Configure `AUCTOR_PLAYWRIGHT`, `AUCTOR_API_URL` and `AUCTOR_WEB_URL` for the local environment. The script creates labelled QA records and should be run against a local development instance. The original recording is generated under ignored `build/browser-qa/video`; the successful recording is exported here.
