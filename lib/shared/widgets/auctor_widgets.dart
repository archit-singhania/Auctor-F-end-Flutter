import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Glowing card — uses theme surface color so it adapts to dark/light mode.
class AuctorCard extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const AuctorCard({
    super.key,
    required this.child,
    this.glowColor,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final borderC = glowColor?.withValues(alpha: 0.4) ??
        (isDark ? AppTheme.borderColor : AppTheme.lBorderColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderC, width: 1),
          boxShadow: glowColor != null
              ? [BoxShadow(color: glowColor!.withValues(alpha: 0.08), blurRadius: 20)]
              : null,
        ),
        child: child,
      ),
    );
  }
}

/// Pill-shaped status badge
class StatusPill extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusPill({super.key, required this.label, required this.type});

  static const _colors = {
    StatusType.verified: AppTheme.accentGreen,
    StatusType.pending:  AppTheme.accentGold,
    StatusType.failed:   AppTheme.accentRed,
    StatusType.locked:   AppTheme.textSecondary,
  };

  static const _icons = {
    StatusType.verified: Icons.check_circle_rounded,
    StatusType.pending:  Icons.pending_rounded,
    StatusType.failed:   Icons.cancel_rounded,
    StatusType.locked:   Icons.lock_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final c = _colors[type]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_icons[type], size: 12, color: c),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: c, letterSpacing: 0.3)),
      ]),
    );
  }
}

enum StatusType { verified, pending, failed, locked }

/// Score ring — adapts text color to theme
class ScoreRing extends StatelessWidget {
  final double score; // 0–10
  final double size;

  const ScoreRing({super.key, required this.score, this.size = 120});

  @override
  Widget build(BuildContext context) {
    final textPrim = Theme.of(context).colorScheme.onSurface;
    final textSec  = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.textSecondary;
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bgColor  = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;

    return SizedBox(
      width: size, height: size,
      child: Stack(alignment: Alignment.center, children: [
        CircularProgressIndicator(
          value: score / 10,
          strokeWidth: 8,
          backgroundColor: bgColor,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
          strokeCap: StrokeCap.round,
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text(score.toStringAsFixed(1),
              style: TextStyle(
                  fontSize: size * 0.22, fontWeight: FontWeight.w800, color: textPrim)),
          Text('/10',
              style: TextStyle(
                  fontSize: size * 0.12, color: textSec, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }
}

/// Section header with optional action label
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
                foregroundColor: AppTheme.accentGold, padding: EdgeInsets.zero),
            child: Text(actionLabel!,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

/// Skill chip — uses elevated background from theme
class SkillChip extends StatelessWidget {
  final String skill;
  final bool verified;

  const SkillChip({super.key, required this.skill, this.verified = false});

  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final bgUnverified = isDark ? AppTheme.bgElevated : AppTheme.lBgElevated;
    final borderC      = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: verified ? AppTheme.accentGreen.withValues(alpha: 0.1) : bgUnverified,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: verified ? AppTheme.accentGreen.withValues(alpha: 0.3) : borderC),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (verified) ...[
          const Icon(Icons.verified_rounded, size: 12, color: AppTheme.accentGreen),
          const SizedBox(width: 4),
        ],
        Text(skill,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: verified ? AppTheme.accentGreen : AppTheme.textSecondary)),
      ]),
    );
  }
}
