/// App-wide constants — single source of truth.
class AppConstants {
  AppConstants._();

  // ── Route names ───────────────────────────────────────────────────────────
  static const String routeSplash         = 'splash';
  static const String routeOnboarding     = 'onboarding';
  static const String routeCvUpload       = 'cv-upload';
  static const String routeCvReview       = 'cv-review';
  static const String routeDashboard      = 'dashboard';
  static const String routeVerifyGitHub   = 'verify-github';
  static const String routeBadgeChallenge = 'badge-challenge';
  static const String routeProfile        = 'profile';

  // ── Platform keys ─────────────────────────────────────────────────────────
  static const String platformGitHub   = 'github';
  static const String platformLeetCode = 'leetcode';

  // ── Badge pass threshold ──────────────────────────────────────────────────
  static const int badgePassThreshold = 3;

  // ── API base URL ──────────────────────────────────────────────────────────
  // ✅ PRODUCTION — Railway deployment URL.
  //    Update this to your actual Railway service URL from the Railway dashboard.
  //    Format: https://<your-service>.up.railway.app
  //
  // ⚠️  DO NOT use localhost here — this is compiled into the Vercel web build
  //     and must point to the publicly accessible Railway backend.
  //
  // Local dev overrides (uncomment as needed, comment out the production line):
  // static const String apiBaseUrl = 'http://10.0.2.2:8000'; // Android emulator
  // static const String apiBaseUrl = 'http://localhost:8000'; // Chrome/Web local
  static const String apiBaseUrl = 'https://auctorappfastapi-production.up.railway.app';

  // ── REAL DATA MODE ────────────────────────────────────────────────────────
  // false = all API calls hit the real FastAPI backend + PostgreSQL
  // true  = mock data, no backend needed (for UI-only dev)
  static const bool useMockData = false;

  // ── Demo user ID (matches seed row in DB) ────────────────────────────────
  static const int demoUserId = 1;
}
