import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME / LANDING SCREEN
//
// No fabricated stats, no fake users, no made-up scores.
// Shows only what Auctor actually does and what a developer can expect.
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SingleChildScrollView(
        child: Column(
          children: const [
            _HeroSection(),
            _WhatItDoesSection(),
            _HowItWorksSection(),
            _ScoreExplainerSection(),
            _FeaturesSection(),
            _PricingSection(),
            _WhyItMattersSection(),
            _BottomCTA(),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// 1. HERO
// ═══════════════════════════════════════════════════════════════════

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.bgDark,
      child: Stack(
        children: [
          const Positioned.fill(child: _GridBackground()),
          Positioned(
            top: 60, left: 0, right: 0,
            child: Container(
              height: 340,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x12C9A84C), Colors.transparent],
                  radius: 0.7,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // Nav row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _LogoMark(),
                      _SmallOutlineButton(
                        label: 'Get Started',
                        onTap: () => context.goNamed('onboarding'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 56),

                  // Early access badge — honest, not "live"
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          color: AppTheme.accentGold.withValues(alpha: 0.2)),
                    ),
                    child: const Text(
                      'EARLY ACCESS  —  FREE TO TRY',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        letterSpacing: 2,
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms),

                  const SizedBox(height: 24),

                  // Headline
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(children: [
                      TextSpan(
                        text: 'Your skills,\nfinally ',
                        style: TextStyle(
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          height: 1.08,
                          letterSpacing: -1.5,
                        ),
                      ),
                      TextSpan(
                        text: 'verified.',
                        style: TextStyle(
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.accentGold,
                          height: 1.08,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ]),
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 500.ms)
                      .slideY(begin: 0.15, end: 0),

                  const SizedBox(height: 18),

                  const Text(
                    'Upload your CV. Auctor reads it with AI, cross-checks your GitHub, challenges your claimed skills, and produces a single honest score recruiters can trust — instead of a resume they can\'t.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      height: 1.65,
                      fontWeight: FontWeight.w300,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                  const SizedBox(height: 32),

                  Column(children: [
                    _FullGoldButton(
                      label: 'Upload your CV — free',
                      onTap: () => context.goNamed('cv-upload'),
                    ),
                    const SizedBox(height: 12),
                    _FullOutlineButton(
                      label: 'See how the score works',
                      onTap: () {},
                    ),
                  ]).animate().fadeIn(delay: 300.ms, duration: 500.ms),

                  const SizedBox(height: 40),

                  // Score mockup — explicitly labelled as example
                  const _ScoreMockup(),
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
  const _LogoMark();
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppTheme.accentGold,
          borderRadius: BorderRadius.circular(7),
        ),
        child: const Center(
            child: Text('A',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.bgDark))),
      ),
      const SizedBox(width: 8),
      const Text('Auctor',
          style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary)),
    ]);
  }
}

class _GridBackground extends StatelessWidget {
  const _GridBackground();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GridPainter());
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

/// Score mockup card — clearly labelled "example output"
class _ScoreMockup extends StatelessWidget {
  const _ScoreMockup();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // "Example output" label above the card
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 20, height: 1, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          const Text(
            'EXAMPLE OUTPUT — YOUR REAL DATA WILL APPEAR HERE',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 9,
              letterSpacing: 1.5,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 20, height: 1, color: AppTheme.textMuted),
        ]),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderColor),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.accentGold.withValues(alpha: 0.06),
                  blurRadius: 36),
            ],
          ),
          child: Column(children: [
            // Header row
            Row(children: [
              Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      borderRadius: BorderRadius.circular(5)),
                  child: const Center(
                      child: Text('A',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.bgDark)))),
              const SizedBox(width: 8),
              const Text('Your Auctor Dashboard',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              const Spacer(),
              // No "Live" badge — just a label
              const Text('after verification',
                  style: TextStyle(
                      fontSize: 9,
                      color: AppTheme.textMuted,
                      fontFamily: 'monospace')),
            ]),

            const SizedBox(height: 14),

            // Score row
            Row(children: [
              const _ExampleScoreRing(size: 72),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AUCTOR SCORE',
                        style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            color: AppTheme.textMuted,
                            letterSpacing: 1.5)),
                    const Text('Based on verified data',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 8),
                    // Score components — labelled as weights, not fake values
                    ...[
                      ('GitHub activity', '25% weight'),
                      ('Skill badges', '30% weight'),
                      ('Projects', '15% weight'),
                    ].map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(children: [
                            Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: const BoxDecoration(
                                    color: AppTheme.accentGold,
                                    shape: BoxShape.circle)),
                            Expanded(
                                child: Text(b.$1,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.textSecondary))),
                            Text(b.$2,
                                style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 9,
                                    color: AppTheme.textMuted)),
                          ]),
                        )),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 12),

            // Badge area — labelled as "skills you can verify"
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.bgElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Skills you can verify →',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textMuted,
                          fontFamily: 'monospace')),
                  const SizedBox(height: 8),
                  Wrap(spacing: 5, runSpacing: 5, children: const [
                    _ExampleBadge(label: 'JWT Auth'),
                    _ExampleBadge(label: 'REST APIs'),
                    _ExampleBadge(label: 'Docker'),
                    _ExampleBadge(label: 'PostgreSQL'),
                    _ExampleBadge(label: 'Redis'),
                  ]),
                ],
              ),
            ),
          ]),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 700.ms)
        .slideY(begin: 0.08, end: 0);
  }
}

/// Score ring shown in mockup — no fake number, shows "?" until real data
class _ExampleScoreRing extends StatelessWidget {
  final double size;
  const _ExampleScoreRing({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(alignment: Alignment.center, children: [
        CircularProgressIndicator(
          value: 0.0, // empty — no fake value
          strokeWidth: 5,
          backgroundColor: AppTheme.borderColor,
          valueColor: const AlwaysStoppedAnimation(AppTheme.accentGold),
          strokeCap: StrokeCap.round,
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('?',
              style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted)),
          Text('/10',
              style: TextStyle(
                  fontSize: size * 0.12, color: AppTheme.textMuted)),
        ]),
      ]),
    );
  }
}

/// Badge shown in mockup — pending state, not fake-verified
class _ExampleBadge extends StatelessWidget {
  final String label;
  const _ExampleBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.lock_outline_rounded,
            size: 9, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textMuted,
                fontFamily: 'monospace')),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// 2. WHAT IT DOES (replaces fake stats ticker)
// ═══════════════════════════════════════════════════════════════════

class _WhatItDoesSection extends StatelessWidget {
  const _WhatItDoesSection();

  // These are facts about the product itself — not made-up user counts
  static const _facts = [
    ('AI reads your PDF', 'No manual form filling'),
    ('GitHub cross-check', 'Repos vs CV claims'),
    ('MCQ skill challenges', 'Earn verified badges'),
    ('Weighted score', '5 components, 0–10'),
    ('Shareable link', 'One URL for recruiters'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor),
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _facts
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.check_rounded,
                          size: 13, color: AppTheme.accentTeal),
                      const SizedBox(width: 7),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.$1,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary)),
                          Text(item.$2,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textSecondary)),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                              color: AppTheme.borderBright,
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
// 3. HOW IT WORKS
// ═══════════════════════════════════════════════════════════════════

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  static const _steps = [
    ('01', '📄', 'Upload your CV',
        'Drop your PDF. The AI parser reads skills, projects, and experience out of it. Nothing to fill in manually.'),
    ('02', '🧠', 'Review the extraction',
        'You see what was pulled out — skills, project names, companies. Correct anything the AI missed.'),
    ('03', '🔗', 'Connect GitHub',
        'Enter your GitHub username. Auctor checks whether your repos actually match the projects you listed.'),
    ('04', '🏅', 'Take badge challenges',
        'For each skill Auctor detects in your CV, you get offered a short MCQ test. Pass it — the skill gets a verified badge.'),
    ('05', '📊', 'Score is calculated',
        'GitHub activity, badge results, project verification, and experience combine into one weighted 0–10 score.'),
    ('06', '🔗', 'Share your profile',
        'One link. Recruiters see your verified score, badges, and matched repos — not a PDF they have to read.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Eyebrow(label: 'THE PROCESS'),
        const SizedBox(height: 10),
        const Text('How it works',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.8,
                height: 1.12)),
        const SizedBox(height: 4),
        const Text('Six steps from PDF to verified score.',
            style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary)),
        const SizedBox(height: 20),
        ..._steps.asMap().entries.map((e) => _StepRow(
              num: e.value.$1,
              emoji: e.value.$2,
              title: e.value.$3,
              desc: e.value.$4,
              delay: e.key * 60,
            )),
      ]),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String num, emoji, title, desc;
  final int delay;

  const _StepRow(
      {required this.num,
      required this.emoji,
      required this.title,
      required this.desc,
      required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.all(18),
      color: AppTheme.bgCard,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(num,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.textMuted,
                height: 1)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emoji,
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.55)),
              ]),
        ),
      ]),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideX(begin: 0.04, end: 0);
  }
}

// ═══════════════════════════════════════════════════════════════════
// 4. SCORE EXPLAINER  (replaces fake score card)
// ═══════════════════════════════════════════════════════════════════

class _ScoreExplainerSection extends StatelessWidget {
  const _ScoreExplainerSection();

  static const _components = [
    ('GitHub activity', '25%',
        'Repo count, commit frequency, stars. Pulled directly from the GitHub API.'),
    ('Skill badges', '30%',
        'Earned by passing MCQ challenges for each skill listed in your CV.'),
    ('Projects', '15%',
        'CV projects that can be matched to a real GitHub repository.'),
    ('LeetCode', '15%',
        'Problem-solving stats from your LeetCode profile (optional).'),
    ('Experience', '15%',
        'Verified work history — internship letters, offer letters.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bgCard,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Eyebrow(label: 'THE SCORE'),
        const SizedBox(height: 10),
        const Text('How your score\nis calculated',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.8,
                height: 1.12)),
        const SizedBox(height: 8),
        const Text(
            'Every point comes from something verifiable. '
            'Nothing is self-reported and taken at face value.',
            style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.6)),
        const SizedBox(height: 24),

        ..._components.asMap().entries.map((e) => Container(
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgElevated,
                border: Border(
                    bottom: BorderSide(
                        color: AppTheme.borderColor.withValues(alpha: 0.5))),
              ),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weight pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color:
                                AppTheme.accentGold.withValues(alpha: 0.25)),
                      ),
                      child: Text(e.value.$2,
                          style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.accentGold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.value.$1,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary)),
                            const SizedBox(height: 3),
                            Text(e.value.$3,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                    height: 1.5)),
                          ]),
                    ),
                  ]),
            ).animate().fadeIn(
                delay: Duration(milliseconds: e.key * 60), duration: 400.ms)),

        const SizedBox(height: 16),

        // Honest caveat
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.bgDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: AppTheme.textMuted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A score is only as good as what you verify. An empty profile scores 0. The more you connect and prove, the higher it goes.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        height: 1.6),
                  ),
                ),
              ]),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// 5. FEATURES
// ═══════════════════════════════════════════════════════════════════

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  static const _f = [
    ('📄', 'CV Intelligence',
        'AI reads your PDF and extracts structured data — skills, project names, companies, dates. You review it before anything gets verified.'),
    ('🔍', 'GitHub Verification',
        'Connects to the GitHub API. Checks if repos matching your CV projects actually exist under your account.'),
    ('🏅', 'Skill Badges',
        'Each skill Auctor detects from your CV gets a challenge. Answer 5 questions correctly and the skill becomes a verified badge.'),
    ('⚡', 'Trust Score',
        'A single weighted number from 0 to 10. Built from real API data, not from what you wrote on a resume.'),
    ('🔐', 'You control sharing',
        'Nothing is public by default. You choose what to show and who to share your profile link with.'),
    ('📊', 'Recruiter view',
        'A clean verified profile page — score, badges, matched repos. No PDF. No guessing.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Eyebrow(label: 'WHAT AUCTOR DOES'),
        const SizedBox(height: 10),
        const Text('What gets built\nwhen you sign up',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.8,
                height: 1.12)),
        const SizedBox(height: 20),
        ..._f.asMap().entries.map((e) => Container(
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                  color: AppTheme.bgCard,
                  border: Border(
                      bottom: BorderSide(color: AppTheme.borderColor))),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                            color: AppTheme.accentGold.withValues(alpha: 0.18)),
                      ),
                      child: Center(
                          child: Text(e.value.$1,
                              style: const TextStyle(fontSize: 19))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.value.$2,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary)),
                            const SizedBox(height: 4),
                            Text(e.value.$3,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                    height: 1.5)),
                          ]),
                    ),
                  ]),
            ).animate().fadeIn(
                delay: Duration(milliseconds: e.key * 50), duration: 400.ms)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// 6. PRICING
// ═══════════════════════════════════════════════════════════════════

class _PricingSection extends StatelessWidget {
  const _PricingSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bgCard,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Eyebrow(label: 'PRICING'),
        const SizedBox(height: 10),
        const Text('Start free.\nPay when it\nactually helps you.',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.8,
                height: 1.12)),
        const SizedBox(height: 6),
        const Text(
            'We\'re in early access. Pricing may change.\nEverything listed here is what we\'re building toward.',
            style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
                height: 1.5)),
        const SizedBox(height: 24),

        _PriceCard(
          plan: 'Developer — Free',
          amount: '₹0',
          period: 'no credit card needed',
          features: [
            'CV upload and AI extraction',
            'GitHub verification',
            'One skill badge challenge',
            'Auctor Score (based on what you verify)',
            'Shareable profile link',
          ],
          ctaLabel: 'Try it free',
          featured: false,
          note: null,
          onTap: () => context.goNamed('cv-upload'),
        ),

        const SizedBox(height: 12),

        _PriceCard(
          plan: 'Developer — Pro',
          amount: '₹499',
          period: 'per month',
          features: [
            'Everything in Free',
            'Unlimited badge challenges',
            'LeetCode profile verification',
            'Certificate upload and validation',
            'Work experience verification pack',
            'Score breakdown analytics',
          ],
          ctaLabel: 'Coming soon',
          featured: true,
          note: 'Not yet available — join the waitlist',
          onTap: () {},
        ),

        const SizedBox(height: 12),

        _PriceCard(
          plan: 'Recruiter Access',
          amount: '₹10k',
          period: 'per month, per seat',
          features: [
            'Searchable verified candidate database',
            'Filter by score, skills, verified badges',
            'Team seat management',
            'API access for ATS integration',
          ],
          ctaLabel: 'Contact us',
          featured: false,
          note: 'In development — reach out to discuss',
          onTap: () {},
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

  const _PriceCard({
    required this.plan,
    required this.amount,
    required this.period,
    required this.features,
    required this.ctaLabel,
    required this.featured,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: featured
            ? AppTheme.accentGold.withValues(alpha: 0.04)
            : AppTheme.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: featured ? AppTheme.borderBright : AppTheme.borderColor,
          width: featured ? 1.5 : 1,
        ),
      ),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(plan,
            style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: AppTheme.textMuted,
                letterSpacing: 1.5)),
        const SizedBox(height: 6),
        Text(amount,
            style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -1)),
        Text(period,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textMuted)),
        const Divider(height: 20, color: AppTheme.borderColor),
        ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                const Icon(Icons.check_rounded,
                    size: 14, color: AppTheme.accentTeal),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(f,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary))),
              ]),
            )),
        if (note != null) ...[
          const SizedBox(height: 4),
          Text(note!,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  fontStyle: FontStyle.italic)),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: featured
              ? OutlinedButton(
                  onPressed: onTap, child: Text(ctaLabel))
              : ElevatedButton(
                  onPressed: onTap, child: Text(ctaLabel)),
        ),
      ]),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ═══════════════════════════════════════════════════════════════════
// 7. WHY IT MATTERS  (replaces fake testimonials)
// ═══════════════════════════════════════════════════════════════════

class _WhyItMattersSection extends StatelessWidget {
  const _WhyItMattersSection();

  static const _points = [
    ('The resume problem',
        'A resume is a list of things you say about yourself. '
            'Nothing on it is verified. Recruiters know this, and either waste time testing '
            'everyone or take a gamble. Auctor fixes the information gap.'),
    ('What verification actually means',
        'It means your GitHub account confirms the repos you listed. '
            'It means you answered 5 domain-specific questions correctly, not that you typed a skill '
            'into a text box. Verification is binary: you either proved it or you didn\'t.'),
    ('Who this is for',
        'Developers who are strong but struggle to prove it on paper. '
            'Fresh graduates without corporate logos. Self-taught engineers. '
            'Anyone whose real ability doesn\'t fit neatly onto a CV.'),
    ('What we\'re building',
        'Right now: CV parsing, GitHub verification, skill challenges, and a score. '
            'Next: LeetCode, certificate verification, work experience proof, and recruiter-side tooling. '
            'We\'re a small team shipping in public.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Eyebrow(label: 'WHY THIS EXISTS'),
        const SizedBox(height: 10),
        const Text('The problem\nwe\'re solving',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.8,
                height: 1.12)),
        const SizedBox(height: 20),
        ..._points.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.value.$1,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      Text(e.value.$2,
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              height: 1.65)),
                    ]),
              ).animate().fadeIn(
                  delay: Duration(milliseconds: e.key * 80),
                  duration: 400.ms),
            )),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// 8. BOTTOM CTA
// ═══════════════════════════════════════════════════════════════════

class _BottomCTA extends StatelessWidget {
  const _BottomCTA();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(children: [
        const Text('Your CV is not\nyour proof.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -1,
                height: 1.1)),

        const SizedBox(height: 10),

        const Text(
            'Connect your GitHub. Pass a challenge. Let the number speak.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.6)),

        const SizedBox(height: 24),

        _FullGoldButton(
          label: 'Upload your CV — it\'s free',
          onTap: () => context.goNamed('cv-upload'),
        ),

        const SizedBox(height: 18),

        // Terminal line — honest command, no fake domain
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.bgDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: const Row(children: [
            Text('\$ ',
                style: TextStyle(
                    color: AppTheme.accentGold,
                    fontFamily: 'monospace',
                    fontSize: 12)),
            Expanded(
              child: Text('auctor verify --cv ./resume.pdf --github @you',
                  style: TextStyle(
                      color: AppTheme.accentTeal,
                      fontFamily: 'monospace',
                      fontSize: 11),
                  overflow: TextOverflow.ellipsis),
            ),
            _BlinkCursor(),
          ]),
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.borderColor))),
      child: Column(children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Auctor',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary)),
              Text('© 2026 Auctor. Early access.',
                  style: TextStyle(
                      fontSize: 11, color: AppTheme.textMuted)),
            ]),
        const SizedBox(height: 12),
        const Text(
          'Building in public. No fake numbers. No paid testimonials.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
              fontStyle: FontStyle.italic),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════

class _Eyebrow extends StatelessWidget {
  final String label;

  const _Eyebrow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 18, height: 1, color: AppTheme.accentGold),
      const SizedBox(width: 8),
      Text(label,
          style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              letterSpacing: 2,
              color: AppTheme.accentGold,
              fontWeight: FontWeight.w500)),
    ]);
  }
}

class _FullGoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FullGoldButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 17)),
        child: Text(label, style: const TextStyle(fontSize: 15)),
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
        textStyle: const TextStyle(fontSize: 13),
      ),
      child: Text(label),
    );
  }
}
