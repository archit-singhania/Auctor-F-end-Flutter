# Recruiter presentation and verification release

Implemented October 15, 2026: recruiter presentation mode, signed verification receipts, evidence expiration/re-verification, assessment integrity review and consent-based recruiter integrations. These complete the ten Auctor additions across its two repositories.

## Manual acceptance

1. Sign in, open Profile, and find Recruiter presentation. Select public story milestones, projects and evidence; add a title/introduction. Private notes remain owner-only. Save, reload, then review the walkthrough. Arrow keys/Home/End navigate its sections. The phone layout stacks content; desktop uses spacious readable cards beneath the existing glass controls.
2. Publish only after reviewing the snapshot and confirming public access. Choose expiration. Open the resulting presentation URL in a signed-out browser, inspect evidence metadata and download the interview-brief PDF. The link contains a frozen approved snapshot, excludes private notes/contact/source files, and does not grant access to the ordinary full-profile sharing endpoint. Revoke in sharing controls; the public page and PDF must then fail.
3. In Verification center, inspect evidence and its eligibility/review date. Currently eligible verified evidence can issue an Ed25519 receipt. Verify it and inspect signature validity, current eligibility, snapshot freshness and revocation separately. A valid signature proves the service signed a snapshot; it does not prove the underlying claim. Alter a payload/signature: verification must reject it.
4. Request re-verification. A different authenticated reviewer can approve/reject with a recorded note and review date. Candidates cannot review their own evidence. Due evidence becomes stale through the durable polling worker, with deduplicated review requests/activity. Existing evidence receives no invented expiry date. Stale/revoked evidence stops contributing to eligible evidence calculations; score weights stay unchanged.
5. Review assessment integrity signals as a reviewer. Timing/replay patterns are explainable review prompts. Record a disposition and inspect the audit trail. Signals never automatically fail a candidate or change grading. No device fingerprint is collected.
6. In Recruiter integrations, select explicit read scopes and expiry and confirm consent. Save the credential and optional webhook secret when shown once. A scoped credential reads only permitted profile/verification metadata. Revoke it: further reads must return unauthorized and queued deliveries must cancel. Inspect delivery attempts/status. No integration reveals private proof files or contact fields.

## Verification evidence

- Backend: 48 isolated PostgreSQL tests passed, including rotation/tamper detection, lifecycle deduplication, reviewer isolation, unchanged grading, consent withdrawal, DNS/private-address restrictions, pinned IP with TLS SNI, redirect refusal, and an actual local signed webhook retry (503 then 204) retaining its event ID.
- Flutter: all 33 tests passed; clean analysis. Editor publication cancellation, public keyboard walkthrough, small/large layouts and consent cancellation are covered.
- Web Release and Android debug builds passed. Real Chrome acceptance downloaded the PDF, inspected a signed receipt, approved re-verification, revoked delegated access and public sharing, and reloaded saved configuration with zero page errors.
- Browser record/screenshots: `trust-presentation-2026-10-15/acceptance.json`. The actual downloaded PDF is `output/pdf/auctor-interview-brief.pdf`; its rendered page was visually inspected.

## Operations and limits

Backend migrations are additive (schema 8). Store the signing-key and webhook-encryption directory on the configured private persistent storage volume, outside Git. Back up that volume with the database; losing encryption keys prevents webhook-secret recovery. Restrict Windows ACLs to the service identity; POSIX mode 0600 alone does not establish Windows ACL policy. Rotate signing keys with `python -m app.verification_keys rotate`; retain old public keys for old receipts.

Production webhooks require HTTPS/public destinations; development loopback HTTP is opt-in and unavailable in production. No public external receiver was contacted during acceptance. Tests exercise the checked-IP/TLS transport and a real explicit-development local receiver. An already-transmitted HTTP request cannot be recalled after consent withdrawal; queued/retried requests recheck consent. Physical Android/iOS execution, signing, public hosting and complex-script PDF typography remain unverified.

Default Android builds target the existing API configuration. Use `adb reverse tcp:8000 tcp:8000` with a locally running API, or rebuild with the intended `API_BASE_URL`. The isolated browser fixture API used port 8106 and its own PostgreSQL schema/private storage; it does not certify a hosted deployment.
