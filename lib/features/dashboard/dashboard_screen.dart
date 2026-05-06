import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/theme_toggle_button.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/auctor_widgets.dart';
import '../cv_upload/cv_state.dart';
import '../../shared/models/auctor_models.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cv = ref.watch(cvDataProvider);
    final scoreAsync = ref.watch(scoreProvider);
    final githubVerified = ref.watch(verificationProvider)['github'] ?? false;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bg = isDark ? AppTheme.bgDark : AppTheme.lBg;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: AppTheme.accentGold, borderRadius: BorderRadius.circular(6)),
            child: const Center(
                child: Text('A', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.bgDark))),
          ),
          const SizedBox(width: 10),
          const Text('Dashboard'),
        ]),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.goNamed('home'),
          tooltip: 'Back',
        ),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            onPressed: () => ref.read(scoreProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh score',
          ),
          IconButton(
            onPressed: () => context.goNamed('profile'),
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: isDark ? AppTheme.bgElevated : AppTheme.lBgElevated,
              child: const Icon(Icons.person_rounded, size: 18),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: scoreAsync.when(
          loading: () => const Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircularProgressIndicator(color: AppTheme.accentGold),
              SizedBox(height: 16),
              Text('Loading your score...', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            ]),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.wifi_off_rounded, color: AppTheme.accentRed, size: 48),
                const SizedBox(height: 16),
                Text('Could not reach backend.\n$err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 24),
                ElevatedButton(
                    onPressed: () => ref.read(scoreProvider.notifier).refresh(),
                    child: const Text('Retry')),
              ]),
            ),
          ),
          data: (score) => _DashboardBody(score: score, cv: cv, githubVerified: githubVerified),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) { if (i == 1) context.goNamed('profile'); },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  final AuctorScore score;
  final ExtractedCvData cv;
  final bool githubVerified;

  const _DashboardBody({required this.score, required this.cv, required this.githubVerified});

  String _scoreLabel(double total) {
    if (total == 0) return 'Not started';
    if (total < 3) return 'Building...';
    if (total < 6) return 'Getting there';
    if (total < 8) return 'Strong profile';
    return 'Expert';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AuctorCard(
          glowColor: AppTheme.accentGold,
          child: Row(children: [
            ScoreRing(score: score.total, size: 100),
            const SizedBox(width: 24),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Auctor Score',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.accentGold)),
                Text(_scoreLabel(score.total), style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  score.total == 0 ? 'Upload your CV to get started' : 'Verify more to increase your score',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ]),
            ),
          ]),
        ).animate().fadeIn(duration: 400.ms),

        const SizedBox(height: 24),

        const SectionHeader(title: 'Score Breakdown'),
        const SizedBox(height: 12),
        AuctorCard(
          child: Column(children: [
            _ScoreRow(label: 'GitHub',     weight: '25%', value: score.github,     done: score.github >= 1.0),
            const SizedBox(height: 12),
            _ScoreRow(label: 'Badges',     weight: '30%', value: score.badges,     done: score.badges >= 1.0),
            const SizedBox(height: 12),
            _ScoreRow(label: 'Projects',   weight: '15%', value: score.projects,   done: score.projects >= 1.0),
            const SizedBox(height: 12),
            _ScoreRow(label: 'LeetCode',   weight: '15%', value: score.leetcode,   done: false),
            const SizedBox(height: 12),
            _ScoreRow(label: 'Experience', weight: '15%', value: score.experience, done: score.experience >= 1.0),
          ]),
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

        const SizedBox(height: 28),

        SectionHeader(title: 'Next Steps', actionLabel: 'See all', onAction: () {}),
        const SizedBox(height: 12),
        ...[
          _ActionItem(
            emoji: '🏅', title: 'JWT Auth badge detected',
            subtitle: 'Your CV mentions JWT — take a 5-min challenge to verify.',
            ctaLabel: 'Take Challenge', glowColor: AppTheme.accentGold,
            onTap: () => context.goNamed('badge-challenge', extra: 'JWT Auth'),
          ),
          if (!githubVerified)
            _ActionItem(
              emoji: '🔗', title: 'Connect GitHub',
              subtitle: 'Verify your repos and project history.',
              ctaLabel: 'Connect', glowColor: AppTheme.accentBlue,
              onTap: () => context.goNamed('verify-github'),
            ),
          _ActionItem(
            emoji: '📄', title: 'Upload Experience Proof',
            subtitle: 'Upload offer letter to verify work experience.',
            ctaLabel: 'Upload', glowColor: AppTheme.accentBlue,
            onTap: () {},
          ),
        ].asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: e.value
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 150 + e.key * 80), duration: 400.ms)
                  .slideX(begin: 0.05, end: 0),
            )),

        const SizedBox(height: 28),

        SectionHeader(title: 'Skills from your CV (${cv.skills.length})'),
        const SizedBox(height: 12),
        cv.skills.isEmpty
            ? AuctorCard(
                child: Row(children: [
                  const Icon(Icons.upload_file_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text('Upload your CV to extract skills',
                      style: Theme.of(context).textTheme.bodyMedium),
                ]),
              )
            : AuctorCard(
                child: Wrap(
                  spacing: 8, runSpacing: 8,
                  children: cv.skills.map((s) => SkillChip(skill: s, verified: false)).toList(),
                ),
              ).animate().fadeIn(delay: 300.ms),
      ]),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label, weight;
  final double value;
  final bool done;

  const _ScoreRow({required this.label, required this.weight, required this.value, required this.done});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(children: [
      SizedBox(
        width: 80,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          Text(weight, style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color)),
        ]),
      ),
      Expanded(
        child: LinearPercentIndicator(
          percent: value.clamp(0, 1),
          lineHeight: 6,
          backgroundColor: isDark ? AppTheme.borderColor : AppTheme.lBorderColor,
          progressColor: done ? AppTheme.accentGreen : AppTheme.accentGold,
          barRadius: const Radius.circular(4),
          padding: EdgeInsets.zero,
        ),
      ),
      const SizedBox(width: 12),
      Text(
        '${(value * 100).toInt()}%',
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: done ? AppTheme.accentGreen : Theme.of(context).textTheme.bodyMedium?.color),
      ),
    ]);
  }
}

class _ActionItem extends StatelessWidget {
  final String emoji, title, subtitle, ctaLabel;
  final Color glowColor;
  final VoidCallback onTap;

  const _ActionItem({
    required this.emoji, required this.title, required this.subtitle,
    required this.ctaLabel, required this.glowColor, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AuctorCard(
      glowColor: glowColor,
      onTap: onTap,
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: glowColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: glowColor.withValues(alpha: 0.3)),
          ),
          child: Text(ctaLabel,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: glowColor)),
        ),
      ]),
    );
  }
}
