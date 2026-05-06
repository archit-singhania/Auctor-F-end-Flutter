import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to home landing screen after 2.8s
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) context.goNamed('home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bg       = isDark ? AppTheme.bgDark : AppTheme.lBg;
    final textPrim = isDark ? AppTheme.textPrimary : AppTheme.lTextPrimary;
    final gold     = AppTheme.accentGold;
    final goldDim  = isDark ? AppTheme.accentGoldDim : AppTheme.accentGoldDim;
    final logoText = isDark ? AppTheme.bgDark : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          const Positioned.fill(child: _SplashGrid()),
          Center(
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [AppTheme.accentGold.withValues(alpha: isDark ? 0.12 : 0.08), Colors.transparent],
                  radius: 0.8,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: gold.withValues(alpha: 0.4), blurRadius: 40),
                    ],
                  ),
                  child: Center(
                    child: Text('A',
                      style: TextStyle(
                        fontSize: 40, fontWeight: FontWeight.w900,
                        color: logoText, height: 1,
                      )),
                  ),
                )
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                Text(
                  'AUCTOR',
                  style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800,
                    color: textPrim, letterSpacing: 8,
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 8),

                Text(
                  'Developer Trust Score',
                  style: TextStyle(
                    fontSize: 13, color: gold,
                    letterSpacing: 2, fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 600.ms),

                const SizedBox(height: 48),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      color: goldDim, shape: BoxShape.circle),
                  ).animate(delay: Duration(milliseconds: 800 + i * 150))
                    .fadeIn(duration: 300.ms)
                    .then()
                    .shimmer(duration: 1200.ms, color: gold)
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashGrid extends StatelessWidget {
  const _SplashGrid();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GridP());
}

class _GridP extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x07C9A84C)..strokeWidth = 1;
    const s = 60.0;
    for (double x = 0; x < size.width; x += s) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += s) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }
  @override bool shouldRepaint(_) => false;
}
