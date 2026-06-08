import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';

/// Aggressively warms up the Railway backend before any UI interaction.
/// Railway free tier cold-starts take 5–15 s on first wake.
/// Strategy: fire 5 staggered pings covering the full cold-start window.
///   0 s  — immediate kick  (wakes the container)
///   1 s  — DB pool init typically takes ~1 s
///   3 s  — most cold-starts done by now
///   6 s  — covers slow cold-starts
///  12 s  — final safety net
void _warmUpBackend() {
  _doPing();
  Future.delayed(const Duration(seconds: 1), _doPing);
  Future.delayed(const Duration(seconds: 3), _doPing);
  Future.delayed(const Duration(seconds: 6), _doPing);
  Future.delayed(const Duration(seconds: 12), _doPing);
}

Future<void> _doPing() async {
  try {
    await http
        .get(Uri.parse('${AppConstants.apiBaseUrl}/ping'))
        .timeout(const Duration(seconds: 14));
  } catch (_) {
    // Silent — best-effort warm-up only
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Hash routing on web so Vercel always serves index.html for any deep-link
  configureUrlStrategy();

  // Start warming up the backend ASAP — before any UI is shown.
  // On web this fires immediately after the JS bundle executes.
  _warmUpBackend();

  // Lock portrait on mobile only
  if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  runApp(const ProviderScope(child: AuctorApp()));
}

class AuctorApp extends ConsumerWidget {
  const AuctorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router    = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark    = themeMode == ThemeMode.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:                Colors.transparent,
      statusBarIconBrightness:       isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor:      isDark ? AppTheme.bgDark : AppTheme.lBg,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return MaterialApp.router(
      title: 'Auctor',
      debugShowCheckedModeBanner: false,
      theme:      AppTheme.lightTheme,
      darkTheme:  AppTheme.darkTheme,
      themeMode:  themeMode,
      routerConfig: router,
    );
  }
}
