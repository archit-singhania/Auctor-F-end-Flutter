# Auctor Flutter App — Notes

## Backend API Contract

All network calls go through `lib/core/services/auctor_api_service.dart`.
Toggle `AppConstants.useMockData = false` to switch from mock to real backend.

### POST /api/cv/parse
- Multipart PDF upload (field name: `file`)
- Returns: `ExtractedCvData` JSON

### GET /api/verify/github
- Query: `username`, optional `cv_projects[]`
- Returns: `GitHubVerifyResponse` JSON

### GET /api/score
- Query: `github_verified`, `badges_earned`, `projects_verified`, `total_projects`, `experience_verified`
- Returns: `AuctorScoreResponse` JSON

### POST /api/badges/submit
- Body: `{ badge_id, correct_answers, total_questions }`
- Returns: `{ passed, badge_id, score_gained }`

---

## Running with backend

1. Start FastAPI: `cd auctor_app_fast_api && uvicorn app.main:app --reload --port 8000`
2. Set `useMockData = false` in `app_constants.dart`
3. Android emulator: API base is already `http://10.0.2.2:8000`
4. Physical device: change to your machine's LAN IP

## Running mock-only (no backend needed)

`useMockData = true` (default) — all API calls return hardcoded data after a
simulated 2-second delay. Use this during UI development.

---

## Commands

```bash
flutter pub get
flutter run
flutter analyze   # should be zero warnings after all fixes applied
```

## Android permissions

`android/app/src/main/AndroidManifest.xml` needs:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.INTERNET"/>
```
