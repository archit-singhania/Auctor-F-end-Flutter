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
  // Production → https://api.auctor.dev  (custom domain on Railway)
  // Android emulator dev → http://10.0.2.2:8000
  // Physical device dev  → http://YOUR_LAN_IP:8000
  // Web (Chrome) dev     → http://localhost:8000
  //
  // Switch between prod and dev by toggling useMockData or changing this value.
  static const String apiBaseUrl = 'https://api.auctor.dev';

  // ── Dev override (uncomment when testing locally) ─────────────────────────
  // static const String apiBaseUrl = 'http://10.0.2.2:8000'; // Android emulator
  // static const String apiBaseUrl = 'http://localhost:8000'; // Chrome/Web

  // ── REAL DATA MODE ────────────────────────────────────────────────────────
  // false = all API calls hit the real FastAPI backend + PostgreSQL
  // true  = mock data, no backend needed (for UI-only dev)
  static const bool useMockData = false;

  // ── Demo user ID (matches seed row in DB) ────────────────────────────────
  static const int demoUserId = 1;
}
