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
  // Android emulator → host machine localhost via 10.0.2.2
  // Physical device  → your machine's LAN IP, e.g. http://192.168.1.10:8000
  // Web (Chrome)     → http://localhost:8000
  static const String apiBaseUrl = 'http://10.0.2.2:8000';

  // ── REAL DATA MODE ────────────────────────────────────────────────────────
  // false = all API calls hit the real FastAPI backend + PostgreSQL
  // true  = mock data, no backend needed (for UI-only dev)
  static const bool useMockData = false;

  // ── Demo user ID (matches seed row in DB) ────────────────────────────────
  static const int demoUserId = 1;
}
