import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_toggle_button.dart';
import '../../shared/widgets/auctor_widgets.dart';
import 'cv_state.dart';

class CvReviewScreen extends ConsumerWidget {
  const CvReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cv = ref.watch(cvDataProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Extracted Data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.goNamed('cv-upload'),
          tooltip: 'Back',
        ),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Header banner ──────────────────────────────────────────────
            _HeaderBanner(theme: theme),
            const SizedBox(height: 24),

            // ── Skills ────────────────────────────────────────────────────
            _SectionLabel(
              icon: Icons.build_rounded,
              label: 'Skills Detected',
              count: cv.skills.length,
              color: AppTheme.accentGold,
            ),
            const SizedBox(height: 10),
            cv.skills.isEmpty
                ? _EmptyState(
                    icon: Icons.build_outlined,
                    message: 'No skills detected. Your CV may be image-only or unsupported.',
                  )
                : AuctorCard(
                    child: Wrap(
                      spacing: 8, runSpacing: 8,
                      children: cv.skills.map((s) => SkillChip(skill: s)).toList(),
                    ),
                  ).animate().fadeIn(delay: 80.ms, duration: 400.ms),
            const SizedBox(height: 24),

            // ── Projects ──────────────────────────────────────────────────
            _SectionLabel(
              icon: Icons.rocket_launch_rounded,
              label: 'Projects Found',
              count: cv.projects.length,
              color: AppTheme.accentBlue,
            ),
            const SizedBox(height: 10),
            if (cv.projects.isEmpty)
              _EmptyState(
                icon: Icons.folder_open_outlined,
                message: 'No projects detected. Make sure your CV has a clearly labelled "Projects" section.',
              )
            else
              ...cv.projects.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProjectCard(
                  project: e.value,
                  index: e.key,
                  theme: theme,
                ).animate().fadeIn(
                  delay: Duration(milliseconds: 120 + e.key * 80),
                  duration: 400.ms,
                ),
              )),
            const SizedBox(height: 24),

            // ── Experience ────────────────────────────────────────────────
            _SectionLabel(
              icon: Icons.work_rounded,
              label: 'Experience',
              count: cv.experience.length,
              color: const Color(0xFF2DD4BF),
            ),
            const SizedBox(height: 10),
            if (cv.experience.isEmpty)
              _EmptyState(
                icon: Icons.work_outline_rounded,
                message: 'No experience detected. Make sure your CV has an "Experience" or "Work" section.',
              )
            else
              ...cv.experience.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ExperienceCard(
                  experience: e.value,
                  index: e.key,
                  theme: theme,
                ).animate().fadeIn(
                  delay: Duration(milliseconds: 160 + e.key * 80),
                  duration: 400.ms,
                ),
              )),

            const SizedBox(height: 32),

            // ── Actions ───────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.verified_user_rounded, size: 18),
                label: const Text('Connect GitHub to Verify'),
                onPressed: () => context.goNamed('verify-github'),
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
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }
}

// ── Header Banner ────────────────────────────────────────────────────────────

class _HeaderBanner extends StatelessWidget {
  final ThemeData theme;
  const _HeaderBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return AuctorCard(
      glowColor: AppTheme.accentGold,
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              color: AppTheme.accentGold, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Extraction Complete',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentGold,
                )),
            const SizedBox(height: 2),
            Text('Review your data below before connecting profiles.',
                style: theme.textTheme.bodySmall),
          ]),
        ),
      ]),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 8),
      Text(label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          )),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('$count',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
      ),
    ]);
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(children: [
        Icon(icon, size: 32, color: Theme.of(context).hintColor),
        const SizedBox(height: 8),
        Text(message,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).hintColor)),
      ]),
    );
  }
}

// ── Project Card ─────────────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final dynamic project;
  final int index;
  final ThemeData theme;
  const _ProjectCard(
      {required this.project, required this.index, required this.theme});

  @override
  Widget build(BuildContext context) {
    return AuctorCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(project.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
          ),
          const StatusPill(label: 'Unverified', type: StatusType.pending),
        ]),
        if (project.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(project.description, style: theme.textTheme.bodySmall),
        ],
        if (project.techStack.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6, runSpacing: 4,
            children: (project.techStack as List<String>)
                .map((t) => SkillChip(skill: t))
                .toList(),
          ),
        ],
      ]),
    );
  }
}

// ── Experience Card ───────────────────────────────────────────────────────────

class _ExperienceCard extends StatelessWidget {
  final dynamic experience;
  final int index;
  final ThemeData theme;
  const _ExperienceCard(
      {required this.experience, required this.index, required this.theme});

  @override
  Widget build(BuildContext context) {
    return AuctorCard(
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF2DD4BF).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.business_rounded,
              color: Color(0xFF2DD4BF), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(experience.role,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 2),
            Text(experience.company,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                )),
            if (experience.duration.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.schedule_rounded, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(experience.duration,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey,
                    )),
              ]),
            ],
          ]),
        ),
        const SizedBox(width: 8),
        const StatusPill(label: 'Unverified', type: StatusType.pending),
      ]),
    );
  }
}
