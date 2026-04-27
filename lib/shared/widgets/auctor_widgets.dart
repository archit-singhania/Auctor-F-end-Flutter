import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Glowing card with optional border accent
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: glowColor?.withValues(alpha: 0.4) ?? AppTheme.borderColor,
            width: 1,
          ),
          boxShadow: glowColor != null
              ? [
                  BoxShadow(
                    color: glowColor!.withValues(alpha: 0.08),
                    blurRadius: 20,
                    spreadRadius: 0,
                  )
                ]
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

  @override
  Widget build(BuildContext context) {
    final colors = {
      StatusType.verified: AppTheme.accentGreen,
      StatusType.pending: AppTheme.accentGold,
      StatusType.failed: AppTheme.accentRed,
      StatusType.locked: AppTheme.textSecondary,
    };

    final icons = {
      StatusType.verified: Icons.check_circle_rounded,
      StatusType.pending: Icons.pending_rounded,
      StatusType.failed: Icons.cancel_rounded,
      StatusType.locked: Icons.lock_rounded,
    };

    final c = colors[type]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icons[type], size: 12, color: c),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

enum StatusType { verified, pending, failed, locked }

/// Gradient score ring
class ScoreRing extends StatelessWidget {
  final double score; // 0–10
  final double size;

  const ScoreRing({super.key, required this.score, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 10,
            strokeWidth: 8,
            backgroundColor: AppTheme.borderColor,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
            strokeCap: StrokeCap.round,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '/10',
                style: TextStyle(
                  fontSize: size * 0.12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Section header with optional action
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

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
              foregroundColor: AppTheme.accentGold,
              padding: EdgeInsets.zero,
            ),
            child: Text(
              actionLabel!,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

/// Skill tag chip
class SkillChip extends StatelessWidget {
  final String skill;
  final bool verified;

  const SkillChip({super.key, required this.skill, this.verified = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: verified
            ? AppTheme.accentGreen.withValues(alpha: 0.1)
            : AppTheme.bgElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: verified
              ? AppTheme.accentGreen.withValues(alpha: 0.3)
              : AppTheme.borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (verified) ...[
            const Icon(Icons.verified_rounded,
                size: 12, color: AppTheme.accentGreen),
            const SizedBox(width: 4),
          ],
          Text(
            skill,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color:
                  verified ? AppTheme.accentGreen : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
