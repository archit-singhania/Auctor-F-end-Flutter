import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/theme_toggle_button.dart';
import '../../shared/models/auctor_models.dart';
import '../../shared/widgets/auctor_widgets.dart';
import 'cv_state.dart';

class CvReviewScreen extends ConsumerWidget {
  const CvReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cv = ref.watch(cvDataProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'STEP 2 OF 4',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 9,
                letterSpacing: 1.4,
                color: AppTheme.accentTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text('Review Extraction'),
        ]),
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

            // ── Success banner ─────────────────────────────────────────────
            _SuccessBanner(theme: theme)
                .animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 20),

            // ── Extracted Profiles / Contact ───────────────────────────────
            if (cv.profiles.hasAny) ...[
              _SectionLabel(
                icon: Icons.person_pin_rounded,
                label: 'Detected Profiles',
                count: _countProfiles(cv.profiles),
                color: AppTheme.accentGold,
              ),
              const SizedBox(height: 10),
              _ProfilesCard(profiles: cv.profiles, isDark: isDark)
                  .animate().fadeIn(delay: 80.ms, duration: 400.ms),
              const SizedBox(height: 24),
            ],

            // ── Skills ────────────────────────────────────────────────────
            _SectionLabel(
              icon: Icons.build_rounded,
              label: 'Skills Detected',
              count: cv.skills.length,
              color: AppTheme.accentBlue,
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
                  ).animate().fadeIn(delay: 120.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // ── Projects ──────────────────────────────────────────────────
            _SectionLabel(
              icon: Icons.rocket_launch_rounded,
              label: 'Projects Found',
              count: cv.projects.length,
              color: const Color(0xFF60A5FA),
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
                  delay: Duration(milliseconds: 160 + e.key * 80),
                  duration: 400.ms,
                ),
              )),

            const SizedBox(height: 24),

            // ── Experience ────────────────────────────────────────────────
            _SectionLabel(
              icon: Icons.work_rounded,
              label: 'Work Experience',
              count: cv.experience.length,
              color: AppTheme.accentTeal,
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
                  delay: Duration(milliseconds: 200 + e.key * 80),
                  duration: 400.ms,
                ),
              )),

            const SizedBox(height: 32),

            // ── Actions ───────────────────────────────────────────────────
            _ActionsSection(profiles: cv.profiles)
                .animate().fadeIn(delay: 300.ms, duration: 400.ms),

            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  int _countProfiles(ExtractedProfiles p) {
    int c = 0;
    if (p.email.isNotEmpty) c++;
    if (p.phone.isNotEmpty) c++;
    if (p.github.isNotEmpty) c++;
    if (p.linkedin.isNotEmpty) c++;
    if (p.leetcode.isNotEmpty) c++;
    if (p.geeksforgeeks.isNotEmpty) c++;
    if (p.portfolio.isNotEmpty) c++;
    if (p.twitter.isNotEmpty) c++;
    return c;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profiles card — shows all detected links with copy buttons
// ─────────────────────────────────────────────────────────────────────────────
class _ProfilesCard extends StatelessWidget {
  final ExtractedProfiles profiles;
  final bool isDark;
  const _ProfilesCard({required this.profiles, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final items = <_ProfileItem>[];

    if (profiles.email.isNotEmpty) {
      items.add(_ProfileItem(
        icon: Icons.email_rounded,
        color: AppTheme.accentGold,
        label: 'Email',
        value: profiles.email,
        url: 'mailto:${profiles.email}',
      ));
    }
    if (profiles.phone.isNotEmpty) {
      items.add(_ProfileItem(
        icon: Icons.phone_rounded,
        color: AppTheme.accentTeal,
        label: 'Phone',
        value: profiles.phone,
        url: 'tel:${profiles.phone}',
      ));
    }
    if (profiles.github.isNotEmpty) {
      items.add(_ProfileItem(
        icon: Icons.code_rounded,
        color: const Color(0xFF94A3B8),
        label: 'GitHub',
        value: profiles.github,
        url: 'https://github.com/${profiles.github}',
        isVerifiable: true,
        verifyLabel: 'Auto-verified ✓',
        verifyColor: AppTheme.accentTeal,
      ));
    }
    if (profiles.linkedin.isNotEmpty) {
      items.add(_ProfileItem(
        icon: Icons.business_center_rounded,
        color: const Color(0xFF0A66C2),
        label: 'LinkedIn',
        value: profiles.linkedin,
        url: 'https://linkedin.com/in/${profiles.linkedin}',
      ));
    }
    if (profiles.leetcode.isNotEmpty) {
      items.add(_ProfileItem(
        icon: Icons.terminal_rounded,
        color: const Color(0xFFF59E0B),
        label: 'LeetCode',
        value: profiles.leetcode,
        url: 'https://leetcode.com/${profiles.leetcode}',
        isVerifiable: true,
        verifyLabel: 'Verify (coming soon)',
        verifyColor: const Color(0xFFF59E0B),
      ));
    }
    if (profiles.geeksforgeeks.isNotEmpty) {
      items.add(_ProfileItem(
        icon: Icons.laptop_chromebook_rounded,
        color: const Color(0xFF22C55E),
        label: 'GeeksForGeeks',
        value: profiles.geeksforgeeks,
        url: 'https://geeksforgeeks.org/user/${profiles.geeksforgeeks}',
      ));
    }
    if (profiles.portfolio.isNotEmpty) {
      items.add(_ProfileItem(
        icon: Icons.language_rounded,
        color: AppTheme.accentBlue,
        label: 'Portfolio',
        value: profiles.portfolio,
        url: profiles.portfolio,
      ));
    }
    if (profiles.twitter.isNotEmpty) {
      items.add(_ProfileItem(
        icon: Icons.tag_rounded,
        color: const Color(0xFF1DA1F2),
        label: 'Twitter / X',
        value: '@${profiles.twitter}',
        url: 'https://x.com/${profiles.twitter}',
      ));
    }

    final cardBg = isDark ? AppTheme.bgCard : AppTheme.lBgCard;
    final border = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withValues(alpha: 0.05),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(Icons.auto_fix_high_rounded,
                    size: 13, color: AppTheme.accentGold),
                const SizedBox(width: 6),
                Text(
                  'Auto-extracted from your CV — review before continuing',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.textMuted : AppTheme.lTextMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...items.asMap().entries.map((e) => _ProfileRow(
                item: e.value,
                isDark: isDark,
                showDivider: e.key < items.length - 1,
              )),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _ProfileItem {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String url;
  final bool isVerifiable;
  final String? verifyLabel;
  final Color? verifyColor;

  const _ProfileItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.url,
    this.isVerifiable = false,
    this.verifyLabel,
    this.verifyColor,
  });
}

class _ProfileRow extends StatelessWidget {
  final _ProfileItem item;
  final bool isDark;
  final bool showDivider;
  const _ProfileRow({
    required this.item,
    required this.isDark,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;
    final textMut = isDark ? AppTheme.textMuted : AppTheme.lTextMuted;
    final badgeColor = item.verifyColor ?? item.color;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        color: textMut,
                        fontFamily: 'monospace',
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item.value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: item.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Copy button
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: item.value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.label} copied'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.bgElevated : AppTheme.lBgElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: border),
                  ),
                  child: Icon(Icons.copy_rounded,
                      size: 13,
                      color: isDark
                          ? AppTheme.textSecondary
                          : AppTheme.lTextSecondary),
                ),
              ),
              if (item.isVerifiable && item.verifyLabel != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    item.verifyLabel!,
                    style: TextStyle(
                        fontSize: 9,
                        color: badgeColor,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: border.withValues(alpha: 0.5)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Actions section — everything auto-extracted; go straight to dashboard
// ─────────────────────────────────────────────────────────────────────────────
class _ActionsSection extends ConsumerWidget {
  final ExtractedProfiles profiles;
  const _ActionsSection({required this.profiles});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary chip showing what was auto-wired
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.accentTeal.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 14, color: AppTheme.accentTeal),
                  SizedBox(width: 8),
                  Text(
                    'Everything extracted automatically',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentTeal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Your GitHub${profiles.github.isNotEmpty ? ' (@${profiles.github})' : ''}, '
                'LinkedIn${profiles.linkedin.isNotEmpty ? ' (${profiles.linkedin})' : ''}, '
                'LeetCode, and contact info are all pre-filled from your CV. '
                'Continue to the dashboard to see your verification steps.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Primary CTA — go to dashboard
        SizedBox(
          width: double.infinity,
          height: 52,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppTheme.accentGold,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGold.withValues(alpha: 0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.goNamed('dashboard'),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.dashboard_rounded,
                          size: 17, color: AppTheme.bgDark),
                      SizedBox(width: 8),
                      Text(
                        'Continue to Dashboard',
                        style: TextStyle(
                          color: AppTheme.bgDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
        Center(
          child: Text(
            'You can verify GitHub and badges from the dashboard.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppTheme.textMuted : AppTheme.lTextMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Success Banner
// ─────────────────────────────────────────────────────────────────────────────
class _SuccessBanner extends StatelessWidget {
  final ThemeData theme;
  const _SuccessBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return AuctorCard(
      glowColor: AppTheme.accentTeal,
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.accentTeal.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.check_circle_rounded,
              color: AppTheme.accentTeal, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Extraction Complete',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentTeal,
                )),
            const SizedBox(height: 2),
            Text(
              'Review everything below — confirm, edit, or add anything before continuing.',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable section label
// ─────────────────────────────────────────────────────────────────────────────
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
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w700)),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// Project Card
// ─────────────────────────────────────────────────────────────────────────────
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
            width: 36,
            height: 36,
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
            spacing: 6,
            runSpacing: 4,
            children: (project.techStack as List<String>)
                .map((t) => SkillChip(skill: t))
                .toList(),
          ),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Experience Card
// ─────────────────────────────────────────────────────────────────────────────
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.accentTeal.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.business_rounded,
              color: AppTheme.accentTeal, size: 22),
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
