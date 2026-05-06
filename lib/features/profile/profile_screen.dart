import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/theme_toggle_button.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/auctor_widgets.dart';
import '../cv_upload/cv_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cv = ref.watch(cvDataProvider);
    final scoreAsync = ref.watch(scoreProvider);
    final verifications = ref.watch(verificationProvider);
    final score = scoreAsync.valueOrNull;

    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bg = isDark ? AppTheme.bgDark : AppTheme.lBg;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.goNamed('dashboard'),
          tooltip: 'Back',
        ),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: 'https://auctor.dev/u/developer'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile link copied!'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              AuctorCard(
                glowColor: AppTheme.accentGold,
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: AppTheme.accentGold.withValues(alpha: 0.3), blurRadius: 20)
                        ],
                      ),
                      child: const Center(
                        child: Text('D',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.bgDark)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Developer', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text('@developer_handle',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.accentGold)),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        scoreAsync.when(
                          loading: () => const SizedBox(
                              width: 80, height: 80,
                              child: Center(child: CircularProgressIndicator(color: AppTheme.accentGold, strokeWidth: 2))),
                          error: (_, __) => const ScoreRing(score: 0, size: 80),
                          data: (s) => ScoreRing(score: s.total, size: 80),
                        ),
                        const SizedBox(width: 32),
                        Column(
                          children: [
                            _StatBox(label: 'Skills', value: cv.skills.length.toString()),
                            const SizedBox(height: 12),
                            _StatBox(
                              label: 'Badges',
                              value: verifications.values.where((v) => v).length.toString(),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Column(
                          children: [
                            _StatBox(label: 'Projects', value: cv.projects.length.toString()),
                            const SizedBox(height: 12),
                            _StatBox(
                              label: 'Verified',
                              value: score != null
                                  ? '${((score.github + score.badges + score.experience) * 10).toInt()}%'
                                  : '0%',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              const SectionHeader(title: '🏅 Earned Badges'),
              const SizedBox(height: 12),
              if (score != null && score.badges > 0) ...[
                AuctorCard(
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
                        ),
                        child: const Center(child: Text('🔐', style: TextStyle(fontSize: 22))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('JWT Auth', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text('+${(score.badges * 30).toStringAsFixed(0)} score pts',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      const StatusPill(label: 'Verified', type: StatusType.verified),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms),
              ] else ...[
                AuctorCard(
                  child: Row(
                    children: [
                      const Icon(Icons.lock_rounded, color: AppTheme.textSecondary, size: 20),
                      const SizedBox(width: 10),
                      Text('No badges yet — take a challenge to earn one',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms),
              ],

              const SizedBox(height: 24),

              SectionHeader(title: '🔧 Skills (${cv.skills.length})'),
              const SizedBox(height: 12),
              cv.skills.isEmpty
                  ? AuctorCard(
                      child: Text('Upload your CV to see skills',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                    )
                  : AuctorCard(
                      child: Wrap(
                        spacing: 8, runSpacing: 8,
                        children: cv.skills.map((s) => SkillChip(skill: s, verified: false)).toList(),
                      ),
                    ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 24),

              const SectionHeader(title: '✅ Verifications'),
              const SizedBox(height: 12),
              ...[
                ('🐙 GitHub', verifications['github'] == true ? 'Connected & verified' : 'Not yet connected',
                    verifications['github'] == true ? StatusType.verified : StatusType.pending),
                ('🏢 Work Experience', 'Upload proof to verify', StatusType.pending),
                ('📜 Certificates', 'None added yet', StatusType.locked),
              ].asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AuctorCard(
                        child: Row(
                          children: [
                            Text(e.value.$1.split(' ')[0], style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.value.$1.substring(3),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                                  Text(e.value.$2, style: Theme.of(context).textTheme.bodyMedium),
                                ],
                              ),
                            ),
                            StatusPill(label: e.value.$2.split(' ').first, type: e.value.$3),
                          ],
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 200 + e.key * 80)),
                    ),
                  ),

              const SizedBox(height: 24),

              AuctorCard(
                glowColor: AppTheme.accentBlue,
                child: Column(
                  children: [
                    Text('Share your Auctor Profile', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Send recruiters a verified link to your profile.',
                        style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.bgElevated : AppTheme.lBgElevated,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isDark ? AppTheme.borderColor : AppTheme.lBorderColor),
                            ),
                            child: const Text('https://auctor.dev/u/developer',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: 'https://auctor.dev/u/developer'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Link copied!'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                          child: const Text('Copy'),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) context.goNamed('dashboard');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface)),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
