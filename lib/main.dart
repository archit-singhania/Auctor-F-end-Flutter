import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';

/// Pings the Railway backend silently on app start.
/// This warms up the container so it’s ready when the user hits upload.
void _warmUpBackend() {
  Future.delayed(const Duration(milliseconds: 500), () async {
    try {
      await http
          .get(Uri.parse('${AppConstants.apiBaseUrl}/ping'))
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // Ignore — this is best-effort warm-up only
    }
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Use hash routing on web so Vercel always serves index.html
  // regardless of which route is in the URL (/#/cv-upload, /#/dashboard, etc.)
  configureUrlStrategy();
  // Warm up the Railway backend immediately so it's ready when the user hits upload
  _warmUpBackend();
  // Only lock orientation on mobile — web ignores this
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

    // Update system UI chrome to match current theme
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
