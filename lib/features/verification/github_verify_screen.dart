import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_toggle_button.dart';
import '../../core/services/auctor_api_service.dart';
import '../../shared/widgets/auctor_widgets.dart';
import '../cv_upload/cv_state.dart';

class GithubVerifyScreen extends ConsumerStatefulWidget {
  const GithubVerifyScreen({super.key});

  @override
  ConsumerState<GithubVerifyScreen> createState() => _GithubVerifyScreenState();
}

class _GithubVerifyScreenState extends ConsumerState<GithubVerifyScreen> {
  final _usernameController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isVerifying = false;
  GitHubVerifyResult? _result;
  String? _errorMessage;
  bool _isFocused = false;
  bool _preFilledFromCv = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
    // Pre-fill GitHub username if extracted from CV
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cvData = ref.read(cvDataProvider);
      if (cvData.profiles.github.isNotEmpty) {
        _usernameController.text = cvData.profiles.github;
        setState(() => _preFilledFromCv = true);
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;
    _focusNode.unfocus();

    setState(() {
      _isVerifying = true;
      _result = null;
      _errorMessage = null;
    });

    try {
      final result = await ref.read(apiServiceProvider).verifyGitHub(username);
      if (result.verified) {
        ref.read(verificationProvider.notifier).markVerified('github');
      }
      setState(() => _result = result);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Verification failed: $e');
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.bgCard : AppTheme.lBgCard;
    final border = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.goNamed('cv-review'),
          tooltip: 'Back',
        ),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Platform header card ─────────────────────────────────
              _PlatformHeader(isDark: isDark)
                  .animate()
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 28),

              // ── Pre-fill hint ──────────────────────────────────────
              if (_preFilledFromCv)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.accentTeal.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          size: 13, color: AppTheme.accentTeal),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Username auto-filled from your CV — verify or edit it below.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.accentTeal,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 60.ms, duration: 300.ms),

              // ── Input section ──────────────────────────────────────
              Text(
                'Enter your GitHub username',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ).animate().fadeIn(delay: 80.ms),
              const SizedBox(height: 6),
              Text(
                'We\'ll cross-check your repos against your CV projects.',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 14),

              // Styled input + button row
              _UsernameInputRow(
                controller: _usernameController,
                focusNode: _focusNode,
                isFocused: _isFocused,
                isVerifying: _isVerifying,
                isDark: isDark,
                onVerify: _verify,
              ).animate().fadeIn(delay: 140.ms),

              // ── Error banner ──────────────────────────────────────
              if (_errorMessage != null) ...[const SizedBox(height: 14), _GithubErrorBanner(message: _errorMessage!)],

              // ── Result card ───────────────────────────────────────
              if (_result != null) ...[const SizedBox(height: 20), _ResultCard(result: _result!)],

              const SizedBox(height: 28),

              // ── What we verify list ─────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What we verify',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    ...[
                      _VerifyItem(
                        icon: Icons.account_circle_rounded,
                        label: 'Account existence',
                        desc: 'Confirms your GitHub profile is public & active',
                        available: true,
                        isDark: isDark,
                      ),
                      _VerifyItem(
                        icon: Icons.source_rounded,
                        label: 'Repo cross-match',
                        desc: 'Projects from your CV are found in public repos',
                        available: true,
                        isDark: isDark,
                      ),
                      _VerifyItem(
                        icon: Icons.star_rounded,
                        label: 'Stars & social proof',
                        desc: 'Total stars across all public repositories',
                        available: true,
                        isDark: isDark,
                      ),
                      _VerifyItem(
                        icon: Icons.timeline_rounded,
                        label: 'Commit activity',
                        desc: 'Contribution frequency — coming soon',
                        available: false,
                        isDark: isDark,
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 28),

              // ── CTA ────────────────────────────────────────────────
              if (_result != null && _result!.verified)
                _GoldButton(
                  label: 'Continue to Dashboard',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => context.goNamed('dashboard'),
                ).animate().fadeIn(delay: 100.ms)
              else
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

// ─────────────────────────────────────────────────────────────────────────────
class _PlatformHeader extends StatelessWidget {
  final bool isDark;
  const _PlatformHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgCard : AppTheme.lBgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentBlue.withValues(alpha: 0.06),
            blurRadius: 20,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.accentBlue.withValues(alpha: 0.25)),
            ),
            child: const Icon(Icons.code_rounded,
                color: AppTheme.accentBlue, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GitHub',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  'Verify repos & cross-match CV projects',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppTheme.accentBlue.withValues(alpha: 0.25)),
            ),
            child: const Text(
              'Free',
              style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.accentBlue,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _UsernameInputRow extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final bool isVerifying;
  final bool isDark;
  final VoidCallback onVerify;

  const _UsernameInputRow({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.isVerifying,
    required this.isDark,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = isDark ? AppTheme.bgElevated : AppTheme.lBgElevated;
    final borderCol = isFocused
        ? AppTheme.accentBlue
        : isDark
            ? AppTheme.borderColor
            : AppTheme.lBorderColor;

    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderCol,
                width: isFocused ? 1.5 : 1,
              ),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: AppTheme.accentBlue.withValues(alpha: 0.1),
                        blurRadius: 12,
                      )
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 4),
                  child: Text(
                    'github.com/',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppTheme.textSecondary
                          : AppTheme.lTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onSubmitted: (_) => onVerify(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.textPrimary
                          : AppTheme.lTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'torvalds',
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppTheme.textSecondary
                            : AppTheme.lTextSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _VerifyButton(isVerifying: isVerifying, onVerify: onVerify),
      ],
    );
  }
}

class _VerifyButton extends StatelessWidget {
  final bool isVerifying;
  final VoidCallback onVerify;
  const _VerifyButton({required this.isVerifying, required this.onVerify});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 50,
      decoration: BoxDecoration(
        color: isVerifying
            ? AppTheme.accentBlue.withValues(alpha: 0.6)
            : AppTheme.accentBlue,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isVerifying
            ? null
            : [
                BoxShadow(
                  color: AppTheme.accentBlue.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isVerifying ? null : onVerify,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Center(
              child: isVerifying
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Verify',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _GithubErrorBanner extends StatelessWidget {
  final String message;
  const _GithubErrorBanner({required this.message});

  bool get _isTokenError =>
      message.toLowerCase().contains('401') ||
      message.toLowerCase().contains('token') ||
      message.toLowerCase().contains('unauthorized');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accentRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentRed.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(Icons.error_outline_rounded,
                    color: AppTheme.accentRed, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                      color: AppTheme.accentRed, fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
          if (_isTokenError) ...[const SizedBox(height: 10), const _TokenFixHint()],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }
}

class _TokenFixHint extends StatelessWidget {
  const _TokenFixHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates_rounded,
                  size: 13, color: AppTheme.accentGold),
              SizedBox(width: 6),
              Text(
                'How to fix this',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentGold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ..._steps.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('\u2022 ',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.accentGold)),
                    Expanded(
                        child: Text(s,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.accentGold,
                                height: 1.4))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  static const _steps = [
    'Go to github.com/settings/tokens',
    'Create a classic token with public_repo scope',
    'Add it as GITHUB_TOKEN in your Railway env vars',
    'Redeploy the Railway service',
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
class _ResultCard extends StatelessWidget {
  final GitHubVerifyResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor =
        result.verified ? AppTheme.accentGreen : AppTheme.accentRed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgCard : AppTheme.lBgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 20,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    result.username.isNotEmpty
                        ? result.username[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${result.username}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${result.repos} repos',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: result.verified ? 'Verified' : 'Failed',
                type: result.verified ? StatusType.verified : StatusType.failed,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _StatBubble(
                icon: Icons.folder_rounded,
                value: '${result.repos}',
                label: 'repos',
                color: AppTheme.accentBlue,
              ),
              const SizedBox(width: 8),
              _StatBubble(
                icon: Icons.star_rounded,
                value: '${result.stars}',
                label: 'stars',
                color: AppTheme.accentGold,
              ),
              const SizedBox(width: 8),
              _StatBubble(
                icon: Icons.check_circle_rounded,
                value: '${result.matchedProjects.length}',
                label: 'matched',
                color: AppTheme.accentGreen,
              ),
            ],
          ),

          if (result.matchedProjects.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Projects matched from your CV',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: result.matchedProjects
                  .map((p) => SkillChip(skill: p, verified: true))
                  .toList(),
            ),
          ],
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn();
  }
}

class _StatBubble extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatBubble(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _VerifyItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final bool available;
  final bool isDark;
  const _VerifyItem({
    required this.icon,
    required this.label,
    required this.desc,
    required this.available,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = available ? AppTheme.accentGreen : AppTheme.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        )),
                Text(desc, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Icon(
            available ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 15,
            color: color,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _GoldButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const _GoldButton(
      {required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.accentGold,
          borderRadius: BorderRadius.circular(14),
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
            onTap: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.bgDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: AppTheme.bgDark, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
