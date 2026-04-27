import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/auctor_widgets.dart';
import 'cv_state.dart';

class CvReviewScreen extends ConsumerWidget {
  const CvReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cv = ref.watch(cvDataProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Review Extracted Data'),
        leading: BackButton(onPressed: () => context.goNamed('cv-upload')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              AuctorCard(
                glowColor: AppTheme.accentGold,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: AppTheme.accentGold, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Extraction Complete',
                              style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            'Review and confirm your data before connecting profiles.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 28),

              // Skills Section
              const SectionHeader(title: '🔧 Skills Detected'),
              const SizedBox(height: 12),
              AuctorCard(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: cv.skills.map((s) => SkillChip(skill: s)).toList(),
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // Projects Section
              const SectionHeader(title: '🚀 Projects Found'),
              const SizedBox(height: 12),
              ...cv.projects.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AuctorCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.value.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                const StatusPill(
                                    label: 'Unverified',
                                    type: StatusType.pending),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(e.value.description,
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              children: e.value.techStack
                                  .map((t) => SkillChip(skill: t))
                                  .toList(),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(
                          delay: Duration(milliseconds: 150 + e.key * 80),
                          duration: 400.ms),
                    ),
                  ),

              const SizedBox(height: 24),

              // Experience Section
              const SectionHeader(title: '💼 Experience'),
              const SizedBox(height: 12),
              ...cv.experience.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AuctorCard(
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.bgElevated,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.business_rounded,
                                  color: AppTheme.accentBlue, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.value.role,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  Text(
                                    '${e.value.company} · ${e.value.duration}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            const StatusPill(
                                label: 'Unverified', type: StatusType.pending),
                          ],
                        ),
                      ).animate().fadeIn(
                          delay: Duration(milliseconds: 200 + e.key * 80),
                          duration: 400.ms),
                    ),
                  ),

              const SizedBox(height: 32),

              // CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.goNamed('verify-github'),
                  child: const Text('Connect GitHub to Verify'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.goNamed('dashboard'),
                  child: const Text('Skip for Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
