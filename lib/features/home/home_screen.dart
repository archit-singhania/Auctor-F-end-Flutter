import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/theme_toggle_button.dart';
import '../../shared/widgets/auctor_logo.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME / LANDING SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bg = isDark ? AppTheme.bgDark : AppTheme.lBg;

    return Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        child: Column(
          children: const [
            _HeroSection(),
            _SocialProofBar(),
            _ProblemSection(),
            _HowItWorksSection(),
            _ScoreBreakdownSection(),
            _FeaturesSection(),
            _WhoItIsForSection(),
            _PricingSection(),
            _FinalCTASection(),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SHARED PRIMITIVES
// ═══════════════════════════════════════════════════════════════════

class _Eyebrow extends StatelessWidget {
  final String label;
  const _Eyebrow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 16, height: 1.5, color: AppTheme.accentGold),
      const SizedBox(width: 8),
      Text(label,
          style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              letterSpacing: 2.5,
              color: AppTheme.accentGold,
              fontWeight: FontWeight.w600)),
    ]);
  }
}

class _FullGoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  const _FullGoldButton(
      {required this.label, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppTheme.accentGold,
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentGold.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 17, color: AppTheme.bgDark),
                    const SizedBox(width: 8),
                  ],
                  Text(label,
                      style: const TextStyle(
                          color: AppTheme.bgDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FullOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FullOutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 17)),
        child: Text(label, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}

class _SmallOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SmallOutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(fontSize: 13)),
      child: Text(label),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// 1. HERO
// ═══════════════════════════════════════════════════════════════════

class _HeroSection extends ConsumerWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bg = isDark ? AppTheme.bgDark : AppTheme.lBg;

    return Container(
      width: double.infinity,
      color: bg,
      child: Stack(
        children: [
          const Positioned.fill(child: _GridBackground()),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentGold.withValues(alpha: isDark ? 0.1 : 0.07),
                    Colors.transparent
                  ],
                  radius: 0.65,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Nav
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _LogoMark(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const ThemeToggleButton(),
                          const SizedBox(width: 6),
                          _SmallOutlineButton(
                            label: 'Get started',
                            onTap: () => context.goNamed('onboarding'),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  // Early access chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          color:
                              AppTheme.accentGold.withValues(alpha: 0.22)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded,
                            size: 12, color: AppTheme.accentGold),
                        SizedBox(width: 5),
                        Text(
                          'EARLY ACCESS  ·  FREE TO TRY',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            letterSpacing: 2,
                            color: AppTheme.accentGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms),

                  const SizedBox(height: 28),

                  // Main headline — rewritten to sell
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'Stop telling recruiters\nwhat you know.\n',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color:
                              Theme.of(context).colorScheme.onSurface,
                          height: 1.1,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const TextSpan(
                        text: 'Prove it.',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.accentGold,
                          height: 1.1,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ]),
                  ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.12, end: 0),

                  const SizedBox(height: 20),

                  Text(
                    'Auctor scans your CV, cross-checks your GitHub, and challenges your claimed skills — then hands you a single verified score that speaks for itself.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      height: 1.7,
                      fontWeight: FontWeight.w300,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                  const SizedBox(height: 36),

                  Column(children: [
                    _FullGoldButton(
                      label: 'Upload your CV — it\'s free',
                      icon: Icons.upload_file_rounded,
                      onTap: () => context.goNamed('cv-upload'),
                    ),
                    const SizedBox(height: 12),
                    _FullOutlineButton(
                        label: 'See how the score works',
                        onTap: () {}),
                  ]).animate().fadeIn(delay: 300.ms, duration: 500.ms),

                  const SizedBox(height: 48),

                  const _HeroDashboardMockup(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const AuctorLogo(size: 30),
      const SizedBox(width: 8),
      Text('Auctor',
          style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface)),
    ]);
  }
}

class _GridBackground extends StatelessWidget {
  const _GridBackground();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GridPainter());
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x0CC9A84C)
      ..strokeWidth = 1;
    const step = 56.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _HeroDashboardMockup extends StatelessWidget {
  const _HeroDashboardMockup();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.bgCard : AppTheme.lBgCard;
    final elevated = isDark ? AppTheme.bgElevated : AppTheme.lBgElevated;
    final border = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;
    final textPrim = Theme.of(context).colorScheme.onSurface;
    final textMut = isDark ? AppTheme.textMuted : AppTheme.lTextMuted;

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 16, height: 1, color: textMut),
        const SizedBox(width: 8),
        Text('EXAMPLE OUTPUT — YOUR REAL DATA WILL APPEAR HERE',
            style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 9,
                letterSpacing: 1.5,
                color: textMut)),
        const SizedBox(width: 8),
        Container(width: 16, height: 1, color: textMut),
      ]),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
                color: AppTheme.accentGold.withValues(alpha: 0.07),
                blurRadius: 40)
          ],
        ),
        child: Column(children: [
          // Header
          Row(children: [
            const AuctorLogo(size: 20),
            const SizedBox(width: 8),
            Text('Your Auctor Dashboard',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textPrim)),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Verified',
                  style: TextStyle(
                      fontSize: 9,
                      color: AppTheme.accentTeal,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 16),
          // Score ring + breakdown
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const _ScoreRing(size: 80),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AUCTOR SCORE',
                        style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            color: textMut,
                            letterSpacing: 1.5)),
                    Text('Verified credibility',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textPrim)),
                    const SizedBox(height: 10),
                    ...const [
                      ('GitHub activity', '25%'),
                      ('Skill badges', '30%'),
                      ('Projects', '15%'),
                      ('LeetCode', '15%'),
                      ('Experience', '15%'),
                    ].map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(children: [
                            Container(
                                width: 4,
                                height: 4,
                                margin:
                                    const EdgeInsets.only(right: 6),
                                decoration: const BoxDecoration(
                                    color: AppTheme.accentGold,
                                    shape: BoxShape.circle)),
                            Expanded(
                                child: Text(b.$1,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: textPrim))),
                            Text(b.$2,
                                style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 9,
                                    color: textMut)),
                          ]),
                        )),
                  ]),
            ),
          ]),
          const SizedBox(height: 14),
          // Verified badges
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: elevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verified skills →',
                      style: TextStyle(
                          fontSize: 10,
                          color: textMut,
                          fontFamily: 'monospace')),
                  const SizedBox(height: 8),
                  const Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        _VerifiedBadge(label: 'React'),
                        _VerifiedBadge(label: 'Node.js'),
                        _VerifiedBadge(label: 'PostgreSQL'),
                        _VerifiedBadge(label: 'Docker'),
                        _MockBadge(label: 'Redis'),
                      ]),
                ]),
          ),
        ]),
      ),
    ]).animate().fadeIn(delay: 400.ms, duration: 700.ms).slideY(begin: 0.08, end: 0);
  }
}

class _ScoreRing extends StatelessWidget {
  final double size;
  const _ScoreRing({required this.size});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMut = isDark ? AppTheme.textMuted : AppTheme.lTextMuted;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(alignment: Alignment.center, children: [
        CircularProgressIndicator(
          value: 0.0,
          strokeWidth: 5,
          backgroundColor:
              isDark ? AppTheme.borderColor : AppTheme.lBorderColor,
          valueColor:
              const AlwaysStoppedAnimation(AppTheme.accentGold),
          strokeCap: StrokeCap.round,
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('?',
              style: TextStyle(
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.w800,
                  color: textMut)),
          Text('/10',
              style: TextStyle(fontSize: size * 0.13, color: textMut)),
        ]),
      ]),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  final String label;
  const _VerifiedBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border:
            Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.verified_rounded,
            size: 10, color: AppTheme.accentTeal),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: AppTheme.accentTeal,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _MockBadge extends StatelessWidget {
  final String label;
  const _MockBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.bgDark : AppTheme.lBg;
    final border = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;
    final textMut = isDark ? AppTheme.textMuted : AppTheme.lTextMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.lock_outline_rounded, size: 10, color: textMut),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: textMut,
                fontFamily: 'monospace')),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// 2. SOCIAL PROOF BAR
// ═══════════════════════════════════════════════════════════════════

class _SocialProofBar extends StatelessWidget {
  const _SocialProofBar();

  static const _items = [
    ('🛠️', 'Built for developers'),
    ('🔍', 'GitHub verification'),
    ('🏅', 'Skill badge challenges'),
    ('📊', 'Weighted trust score'),
    ('🔗', 'One shareable link'),
    ('🚀', 'Free to start'),
    ('🧠', 'AI-powered parsing'),
    ('🔐', 'You control sharing'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.bgCard : AppTheme.lBgCard;
    final border = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;
    final textPrim = Theme.of(context).colorScheme.onSurface;
    final textMut = isDark ? AppTheme.textMuted : AppTheme.lTextMuted;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: bg,
        border: Border(
            top: BorderSide(color: border),
            bottom: BorderSide(color: border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _items
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item.$1,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 7),
                          Text(item.$2,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textPrim)),
                          const SizedBox(width: 18),
                          Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                  color: textMut,
                                  shape: BoxShape.circle)),
                        ]),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// 3. THE PROBLEM
// ═══════════════════════════════════════════════════════════════════

class _ProblemSection extends StatelessWidget {
  const _ProblemSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrim = Theme.of(context).colorScheme.onSurface;
    final textSec = Theme.of(context).textTheme.bodyMedium?.color ??
        AppTheme.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Eyebrow(label: 'THE PROBLEM'),
        const SizedBox(height: 12),
        Text(
          'Resumes are\na guessing game.',
          style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: textPrim,
              height: 1.15,
              letterSpacing: -1.0),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 16),
        _ProblemPoint(
          isDark: isDark,
          headline: 'Anyone can write "5 years of React"',
          body:
              'There\'s nothing stopping a candidate from claiming any skill on a PDF. Recruiters have no way to verify it.',
          accent: AppTheme.accentRed,
        ),
        const SizedBox(height: 10),
        _ProblemPoint(
          isDark: isDark,
          headline: 'Strong developers lose to polished CVs',
          body:
              'If you\'re self-taught, bootcamp-trained, or from a non-target college — your real ability gets buried under formatting.',
          accent: AppTheme.accentRed,
        ),
        const SizedBox(height: 10),
        _ProblemPoint(
          isDark: isDark,
          headline: 'Hiring is slow because trust is expensive',
          body:
              'Without a way to quickly verify claims, companies spend hours on calls that could have been decided in minutes.',
          accent: AppTheme.accentRed,
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text('Auctor fixes this.',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentGold)),
            const SizedBox(height: 8),
            Text(
              'We replace the unverifiable PDF with a live, data-backed credibility score. Every point in your score comes from something we can actually check.',
              style: TextStyle(fontSize: 14, color: textSec, height: 1.65),
            ),
          ]),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
      ]),
    );
  }
}

class _ProblemPoint extends StatelessWidget {
  final bool isDark;
  final String headline;
  final String body;
  final Color accent;
  const _ProblemPoint({
    required this.isDark,
    required this.headline,
    required this.body,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppTheme.bgCard : AppTheme.lBgCard;
    final border = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;
    final textPrim = Theme.of(context).colorScheme.onSurface;
    final textSec =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 3,
          height: 44,
          decoration: BoxDecoration(
              color: accent, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(headline,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrim)),
            const SizedBox(height: 5),
            Text(body,
                style: TextStyle(
                    fontSize: 13, color: textSec, height: 1.55)),
          ]),
        ),
      ]),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.03, end: 0);
  }
}

// ═══════════════════════════════════════════════════════════════════
// 4. HOW IT WORKS
// ═══════════════════════════════════════════════════════════════════

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  static const _steps = [
    ('01', '📄', 'Upload your PDF resume',
        'Drop any PDF. Auctor\'s AI reads it instantly — no forms to fill, no manual input. Skills, projects, and experience extracted in seconds.'),
    ('02', '🔍', 'Review what we extracted',
        'You see exactly what the AI found. Confirm, edit, or add anything. You\'re always in control of your data.'),
    ('03', '🔗', 'Connect GitHub',
        'Enter your GitHub username. We cross-check your claimed projects against your real repositories. No repos? That\'s fine — it just affects the score.'),
    ('04', '🏅', 'Take skill challenges',
        'For each skill on your CV, you get 5 targeted questions. Pass them and the skill gets a verified badge. Badges are worth 30% of your score.'),
    ('05', '📊', 'Get your Auctor Score',
        'A single number from 0–10. Built from five weighted data sources — all of them verifiable. This is your proof.'),
    ('06', '🔗', 'Share it with one link',
        'One URL. Recruiters see your score, verified badges, and matched repos — without asking for your CV.'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.bgCard : AppTheme.lBgCard;

    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Eyebrow(label: 'THE PROCESS'),
        const SizedBox(height: 12),
        Text('From PDF\nto verified — in minutes.',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.15,
                letterSpacing: -1.0)),
        const SizedBox(height: 8),
        Text('No waiting. No back-and-forth. Just upload and get scored.',
            style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.6)),
        const SizedBox(height: 28),
        ..._steps.asMap().entries.map((e) => _StepRow(
              num: e.value.$1,
              emoji: e.value.$2,
              title: e.value.$3,
              desc: e.value.$4,
              delay: e.key * 60,
              isDark: isDark,
            )),
      ]),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String num, emoji, title, desc;
  final int delay;
  final bool isDark;

  const _StepRow(
      {required this.num,
      required this.emoji,
      required this.title,
      required this.desc,
      required this.delay,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppTheme.bgElevated : AppTheme.lBgElevated;
    final border = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;
    final textMut = isDark ? AppTheme.textMuted : AppTheme.lTextMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: bg,
          border: Border(bottom: BorderSide(color: border))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(num,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: textMut,
                fontFamily: 'monospace',
                height: 1)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 5),
            Text(title,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 5),
            Text(desc,
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.6)),
          ]),
        ),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms).slideX(begin: 0.03, end: 0);
  }
}

// ═══════════════════════════════════════════════════════════════════
// 5. SCORE BREAKDOWN
// ═══════════════════════════════════════════════════════════════════

class _ScoreBreakdownSection extends StatelessWidget {
  const _ScoreBreakdownSection();

  static const _components = [
    (
      '🏅',
      'Skill badges',
      '30%',
      AppTheme.accentGold,
      'Pass 5 questions on a claimed skill and it\'s verified. The most impactful component — because it\'s the hardest to fake.'
    ),
    (
      '🔬',
      'GitHub activity',
      '25%',
      AppTheme.accentBlue,
      'Commit frequency, repo count, star count. Pulled directly from the GitHub API — not self-reported.'
    ),
    (
      '📁',
      'Projects',
      '15%',
      AppTheme.accentTeal,
      'CV projects matched against real GitHub repositories. Did you actually build what you say you built?'
    ),
    (
      '💡',
      'LeetCode',
      '15%',
      Color(0xFFB87AFF),
      'Problem count, contest rating, difficulty breakdown. Optional — but it adds weight for algorithmic roles.'
    ),
    (
      '💼',
      'Experience',
      '15%',
      Color(0xFFFF9A3C),
      'Verified work history via offer letters or internship certificates. Upload docs and the component gets unlocked.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrim = Theme.of(context).colorScheme.onSurface;
    final textSec = Theme.of(context).textTheme.bodyMedium?.color ??
        AppTheme.textSecondary;
    final textMut = isDark ? AppTheme.textMuted : AppTheme.lTextMuted;
    final border = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Eyebrow(label: 'THE SCORE'),
        const SizedBox(height: 12),
        Text('Every point is\nearned, not claimed.',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: textPrim,
                height: 1.15,
                letterSpacing: -1.0)),
        const SizedBox(height: 8),
        Text(
          'Zero assumptions. Zero self-reporting. The score is entirely built from data we verify independently.',
          style: TextStyle(fontSize: 14, color: textSec, height: 1.65),
        ),
        const SizedBox(height: 28),
        ..._components.asMap().entries.map((e) => Container(
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: border))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.value.$1,
                    style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Expanded(
                        child: Text(e.value.$2,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: textPrim)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: e.value.$4.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: e.value.$4.withValues(alpha: 0.25)),
                        ),
                        child: Text(e.value.$3,
                            style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: e.value.$4)),
                      ),
                    ]),
                    const SizedBox(height: 5),
                    Text(e.value.$5,
                        style: TextStyle(
                            fontSize: 13, color: textSec, height: 1.55)),
                  ]),
                ),
              ]),
            ).animate().fadeIn(
                delay: Duration(milliseconds: e.key * 60),
                duration: 400.ms)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.bgCard : AppTheme.lBgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Row(children: [
            Icon(Icons.info_outline_rounded, size: 14, color: textMut),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'An empty profile scores 0. The more you connect and prove, the higher it goes. There\'s no shortcut.',
                style: TextStyle(fontSize: 12, color: textMut, height: 1.6),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// 6. FEATURES
// ═══════════════════════════════════════════════════════════════════

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  static const _features = [
    ('📄', AppTheme.accentGold, 'AI CV Parser',
        'Drop your PDF and walk away. Our parser reads structured and unstructured CVs, extracts skills, projects, and job history — no templates, no formatting rules.'),
    ('🔗', AppTheme.accentBlue, 'GitHub Cross-Check',
        'We pull your public repos from the GitHub API and match them against what you\'ve claimed. Real commits. Real repos. No more "built a fintech app" with no proof.'),
    ('🏅', AppTheme.accentTeal, 'Skill Badge Challenges',
        'Short, sharp, targeted. Five questions per skill. You either know it or you don\'t. Verified badges are permanent and public on your profile.'),
    ('📊', Color(0xFFB87AFF), 'Auctor Trust Score',
        'A single number from 0–10. Weighted across five verifiable data sources. Recruiters see it instantly — no decoding needed.'),
    ('🔐', AppTheme.accentGold, 'Privacy-first sharing',
        'Nothing is public by default. Generate a link when you\'re ready. Revoke it anytime. You decide who sees what.'),
    ('🔗', AppTheme.accentTeal, 'One recruiter-ready URL',
        'No PDF attachments. No back-and-forth. Send one link — they see your score, your verified badges, and your matched GitHub projects.'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.bgCard : AppTheme.lBgCard;
    final border = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;

    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Eyebrow(label: 'FEATURES'),
        const SizedBox(height: 12),
        Text('Everything you\nneed to stand out.',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.15,
                letterSpacing: -1.0)),
        const SizedBox(height: 28),
        ..._features.asMap().entries.map((e) => Container(
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: border))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: e.value.$2.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                        color: e.value.$2.withValues(alpha: 0.2)),
                  ),
                  child: Center(
                      child: Text(e.value.$1,
                          style: const TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(e.value.$3,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color:
                                Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 5),
                    Text(e.value.$4,
                        style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color,
                            height: 1.6)),
                  ]),
                ),
              ]),
            ).animate().fadeIn(
                delay: Duration(milliseconds: e.key * 50),
                duration: 400.ms)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// 7. WHO IT'S FOR
// ═══════════════════════════════════════════════════════════════════

class _WhoItIsForSection extends StatelessWidget {
  const _WhoItIsForSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrim = Theme.of(context).colorScheme.onSurface;
    final textSec = Theme.of(context).textTheme.bodyMedium?.color ??
        AppTheme.textSecondary;

    const personas = [
      (
        '🎓',
        'Fresh graduates',
        'No work experience? Prove your skills through what you\'ve built. GitHub, badges, and projects carry more weight than an empty job history.'
      ),
      (
        '⚡',
        'Self-taught developers',
        'No degree, no problem. If you can pass the badge challenges and have the repos to back it up, Auctor gives you a number that speaks for itself.'
      ),
      (
        '🔄',
        'Career switchers',
        'Pivoting from another field? Your CV screams "junior" even when your skills don\'t. Auctor measures what you know, not where you came from.'
      ),
      (
        '💪',
        'Strong devs with weak CVs',
        'You know your stuff but your resume doesn\'t sell it. Get a verified score and let your actual abilities do the talking.'
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Eyebrow(label: 'WHO THIS IS FOR'),
        const SizedBox(height: 12),
        Text('Built for developers\nwho hate selling themselves.',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: textPrim,
                height: 1.15,
                letterSpacing: -1.0)),
        const SizedBox(height: 28),
        ...personas.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PersonaCard(
                emoji: e.value.$1,
                title: e.value.$2,
                body: e.value.$3,
                delay: e.key * 70,
                isDark: isDark,
              ),
            )),
      ]),
    );
  }
}

class _PersonaCard extends StatelessWidget {
  final String emoji, title, body;
  final int delay;
  final bool isDark;
  const _PersonaCard(
      {required this.emoji,
      required this.title,
      required this.body,
      required this.delay,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppTheme.bgCard : AppTheme.lBgCard;
    final border = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;
    final textPrim = Theme.of(context).colorScheme.onSurface;
    final textSec =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 30)),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textPrim)),
            const SizedBox(height: 6),
            Text(body,
                style:
                    TextStyle(fontSize: 13, color: textSec, height: 1.6)),
          ]),
        ),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms);
  }
}

// ═══════════════════════════════════════════════════════════════════
// 8. PRICING
// ═══════════════════════════════════════════════════════════════════

class _PricingSection extends StatelessWidget {
  const _PricingSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.bgCard : AppTheme.lBgCard;

    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Eyebrow(label: 'PRICING'),
        const SizedBox(height: 12),
        Text('Honest pricing.\nNo tricks.',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.15,
                letterSpacing: -1.0)),
        const SizedBox(height: 8),
        Text(
          'Start for free. Pay only when you want the full verification stack.',
          style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.6),
        ),
        const SizedBox(height: 28),

        _PriceCard(
          plan: 'DEVELOPER FREE',
          amount: '₹0',
          period: 'No credit card. No expiry.',
          features: const [
            'CV upload & AI extraction',
            'GitHub verification',
            'One skill badge challenge',
            'Your Auctor Score',
            'Shareable profile link',
          ],
          ctaLabel: 'Get started — it\'s free',
          featured: true,
          note: null,
          onTap: () => context.goNamed('cv-upload'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _PriceCard(
          plan: 'DEVELOPER PRO',
          amount: '₹499',
          period: 'per month',
          features: const [
            'Everything in Free',
            'Unlimited badge challenges',
            'LeetCode profile verification',
            'Certificate & document upload',
            'Work experience verification',
          ],
          ctaLabel: 'Join the waitlist',
          featured: false,
          note: 'Coming soon — not yet available',
          onTap: () {},
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _PriceCard(
          plan: 'RECRUITER ACCESS',
          amount: '₹10k',
          period: 'per month, per seat',
          features: const [
            'Searchable verified candidate pool',
            'Filter by score, skills & badges',
            'ATS API integration',
            'Team seat management',
            'Bulk export & reporting',
          ],
          ctaLabel: 'Get in touch',
          featured: false,
          note: 'In development — contact us',
          onTap: () {},
          isDark: isDark,
        ),
      ]),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String plan, amount, period, ctaLabel;
  final List<String> features;
  final bool featured;
  final String? note;
  final VoidCallback onTap;
  final bool isDark;

  const _PriceCard({
    required this.plan,
    required this.amount,
    required this.period,
    required this.features,
    required this.ctaLabel,
    required this.featured,
    required this.note,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final elevated = isDark ? AppTheme.bgElevated : AppTheme.lBgElevated;
    final border = featured
        ? AppTheme.accentGold.withValues(alpha: 0.5)
        : (isDark ? AppTheme.borderColor : AppTheme.lBorderColor);
    final textPrim = Theme.of(context).colorScheme.onSurface;
    final textSec = Theme.of(context).textTheme.bodyMedium?.color ??
        AppTheme.textSecondary;
    final textMut = isDark ? AppTheme.textMuted : AppTheme.lTextMuted;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: featured
            ? AppTheme.accentGold.withValues(alpha: 0.05)
            : elevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: featured ? 1.5 : 1),
        boxShadow: featured
            ? [
                BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.08),
                    blurRadius: 32)
              ]
            : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(plan,
              style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: featured ? AppTheme.accentGold : textMut,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600)),
          if (featured) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text('MOST POPULAR',
                  style: TextStyle(
                      fontSize: 8,
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
            )
          ]
        ]),
        const SizedBox(height: 8),
        Text(amount,
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: textPrim,
                letterSpacing: -1.5)),
        Text(period,
            style: TextStyle(fontSize: 12, color: textMut)),
        const SizedBox(height: 16),
        Divider(
            height: 1,
            color: isDark ? AppTheme.borderColor : AppTheme.lBorderColor),
        const SizedBox(height: 14),
        ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(children: [
                const Icon(Icons.check_rounded,
                    size: 14, color: AppTheme.accentTeal),
                const SizedBox(width: 9),
                Expanded(
                    child: Text(f,
                        style: TextStyle(fontSize: 13, color: textSec))),
              ]),
            )),
        if (note != null) ...[
          const SizedBox(height: 4),
          Text(note!,
              style: TextStyle(
                  fontSize: 11,
                  color: textMut,
                  fontStyle: FontStyle.italic)),
        ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: featured
              ? _FullGoldButton(label: ctaLabel, onTap: onTap)
              : OutlinedButton(onPressed: onTap, child: Text(ctaLabel)),
        ),
      ]),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ═══════════════════════════════════════════════════════════════════
// 9. FINAL CTA
// ═══════════════════════════════════════════════════════════════════

class _FinalCTASection extends StatelessWidget {
  const _FinalCTASection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.bgCard : AppTheme.lBgCard;
    final termBg = isDark ? AppTheme.bgElevated : AppTheme.lBgElevated;
    final border = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;
    final textPrim = Theme.of(context).colorScheme.onSurface;
    final textSec = Theme.of(context).textTheme.bodyMedium?.color ??
        AppTheme.textSecondary;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
              color: AppTheme.accentGold.withValues(alpha: 0.05),
              blurRadius: 48)
        ],
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.2)),
          ),
          child: const Text(
            'YOUR CV IS NOT YOUR PROOF',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 9,
              letterSpacing: 2,
              color: AppTheme.accentGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Your score\nwill speak\nfor you.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: textPrim,
              height: 1.1,
              letterSpacing: -1.2),
        ),
        const SizedBox(height: 12),
        Text(
          'Upload your CV. Connect GitHub. Pass a challenge.\nLet the number do the talking.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: textSec, height: 1.65),
        ),
        const SizedBox(height: 28),
        _FullGoldButton(
          label: 'Build your verified profile',
          icon: Icons.auto_awesome_rounded,
          onTap: () => context.goNamed('cv-upload'),
        ),
        const SizedBox(height: 10),
        _FullOutlineButton(
            label: 'Learn how the score works', onTap: () {}),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: termBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border),
          ),
          child: const Row(children: [
            Text('\$ ',
                style: TextStyle(
                    color: AppTheme.accentGold,
                    fontFamily: 'monospace',
                    fontSize: 12)),
            Expanded(
              child: Text(
                'auctor verify --cv ./resume.pdf --github @you',
                style: TextStyle(
                    color: AppTheme.accentTeal,
                    fontFamily: 'monospace',
                    fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _BlinkCursor(),
          ]),
        ),
        const SizedBox(height: 16),
        Text(
          'No credit card. No lock-in. Start in 60 seconds.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.textMuted : AppTheme.lTextMuted,
              fontStyle: FontStyle.italic),
        ),
      ]),
    ).animate().fadeIn(duration: 500.ms);
  }
}

class _BlinkCursor extends StatefulWidget {
  const _BlinkCursor();
  @override
  State<_BlinkCursor> createState() => _BlinkCursorState();
}

class _BlinkCursorState extends State<_BlinkCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Opacity(
        opacity: _c.value > 0.5 ? 1.0 : 0.0,
        child: Container(width: 7, height: 12, color: AppTheme.textMuted),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// FOOTER
// ═══════════════════════════════════════════════════════════════════

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;
    final textSec = Theme.of(context).textTheme.bodyMedium?.color ??
        AppTheme.textSecondary;
    final textMut = isDark ? AppTheme.textMuted : AppTheme.lTextMuted;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: border))),
      child: Column(children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AuctorLogo(size: 22),
              Text('© 2026 Auctor',
                  style: TextStyle(fontSize: 11, color: textMut)),
            ]),
        const SizedBox(height: 10),
        Text('Building in public · No fake numbers · No paid testimonials',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11,
                color: textMut,
                fontStyle: FontStyle.italic)),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          children: [
            Text('Early Access', style: TextStyle(fontSize: 11, color: textSec)),
            Text('Privacy', style: TextStyle(fontSize: 11, color: textSec)),
            Text('Contact', style: TextStyle(fontSize: 11, color: textSec)),
          ],
        )
      ]),
    );
  }
}
