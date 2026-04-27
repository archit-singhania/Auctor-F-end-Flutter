import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) context.goNamed('onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.accentGold,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.4),
                    blurRadius: 40,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.bgDark,
                    height: 1,
                  ),
                ),
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            Text(
              'AUCTOR',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    letterSpacing: 8,
                    fontSize: 28,
                    color: AppTheme.textPrimary,
                  ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            Text(
              'Developer Trust Score',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    letterSpacing: 2,
                    fontSize: 13,
                    color: AppTheme.accentGold,
                  ),
            ).animate().fadeIn(delay: 700.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
