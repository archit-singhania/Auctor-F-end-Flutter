import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/cv_upload/cv_upload_screen.dart';
import '../../features/cv_upload/cv_review_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/verification/github_verify_screen.dart';
import '../../features/badges/badge_challenge_screen.dart';
import '../../features/profile/profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // Start with splash → auto-navigates to home after 2.8s
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/cv-upload',
        name: 'cv-upload',
        builder: (context, state) => const CvUploadScreen(),
      ),
      GoRoute(
        path: '/cv-review',
        name: 'cv-review',
        builder: (context, state) => const CvReviewScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/verify/github',
        name: 'verify-github',
        builder: (context, state) => const GithubVerifyScreen(),
      ),
      GoRoute(
        path: '/badge/challenge',
        name: 'badge-challenge',
        builder: (context, state) {
          final badge = state.extra as String? ?? 'JWT Auth';
          return BadgeChallengeScreen(badgeName: badge);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
