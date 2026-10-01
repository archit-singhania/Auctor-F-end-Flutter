# Auctor connected workflow demonstration

[Watch the local browser recording](auctor-connected-workflow.webm).

Duration: 52.56 seconds. Format: WebM/VP8, 1440 × 1050, 25 fps. The mobile section changes the actual browser viewport and appears within the same recording canvas. Representative frames were extracted and visually checked after recording.

The recording uses a fresh isolated Chrome context connected to the actual local Flutter/FastAPI/PostgreSQL implementation. The account is labelled **QA Developer (test account)**. Its CV contains a disposable **QA Orders API** project and test skills; these are demonstration fixtures. The recorded assessment is answered by the software test using known question choices. The server genuinely grades the submission and persists the resulting **0.6** score.

The flow shows sign-in, the desktop workspace, a real CV edit adding Redis, saved revision readback, a timed Docker assessment, the server result, profile settings, private-link creation/revocation, persisted session reload, and responsive mobile light/dark views. The script also checks that the revoked link returns 404 and the shared payload omits the account email. Those HTTP assertions are validation alongside the visible actions.

GitHub OAuth, independent human review and native device execution have separate acceptance coverage and are not demonstrated in this video. This recording provides local functionality and visual evidence for a portfolio; it does not show adoption, deployment or a professional competency assessment.

To reproduce after starting the local API and web bundle, set `AUCTOR_RECORD_VIDEO=1` and run `node scripts/browser-qa.cjs` from the Flutter repository. Configure `AUCTOR_PLAYWRIGHT`, `AUCTOR_API_URL` and `AUCTOR_WEB_URL` for the local environment. The script creates labelled QA records and should be run against a local development instance. The original recording is generated under ignored `build/browser-qa/video`; the successful recording is exported here.
