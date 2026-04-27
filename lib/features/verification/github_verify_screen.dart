import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
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
  bool _isVerifying = false;
  GitHubVerifyResult? _result;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    setState(() {
      _isVerifying = true;
      _result = null;
      _errorMessage = null;
    });

    try {
      // GET /api/verify/github?username={username}
      // In mock mode, returns mock data. In production, calls real backend
      // which in turn calls GitHub API to verify repos vs. extracted CV projects.
      final result =
          await ref.read(apiServiceProvider).verifyGitHub(username);

      if (result.verified) {
        ref.read(verificationProvider.notifier).markVerified('github');
      }

      setState(() => _result = result);
    } catch (e) {
      setState(() => _errorMessage = 'Verification failed. Check username and try again.');
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('GitHub Verification'),
        leading: BackButton(onPressed: () => context.goNamed('cv-review')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GitHub brand card
              AuctorCard(
                glowColor: AppTheme.accentBlue,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.bgElevated,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.code_rounded,
                          color: AppTheme.accentBlue, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GitHub',
                            style: Theme.of(context).textTheme.titleLarge),
                        Text('Verify repos & project history',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 28),

              Text('Enter your GitHub username',
                      style: Theme.of(context).textTheme.titleMedium)
                  .animate()
                  .fadeIn(delay: 100.ms),
              const SizedBox(height: 12),

              // Username input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'e.g. torvalds',
                        prefixText: 'github.com/',
                        prefixStyle: TextStyle(color: AppTheme.textSecondary),
                      ),
                      onSubmitted: (_) => _verify(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isVerifying ? null : _verify,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.bgDark),
                          )
                        : const Text('Verify'),
                  ),
                ],
              ).animate().fadeIn(delay: 150.ms),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.accentRed.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppTheme.accentRed, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMessage!,
                            style: const TextStyle(
                                color: AppTheme.accentRed, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Result card
              if (_result != null) _buildResultCard(_result!),

              const SizedBox(height: 32),

              // What we check section
              const SectionHeader(title: 'What we verify'),
              const SizedBox(height: 12),
              ...[
                ('Repo existence', 'Projects from your CV are cross-checked', true),
                ('Activity signals', 'Commit frequency & contribution graph', true),
                ('Tech stack match', 'Languages & tools match your skills list', true),
                ('Stars & forks', 'Social proof of your work quality', false),
              ].map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AuctorCard(
                      child: Row(
                        children: [
                          Icon(
                            item.$3
                                ? Icons.check_circle_rounded
                                : Icons.timer_rounded,
                            size: 16,
                            color: item.$3
                                ? AppTheme.accentGreen
                                : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.$1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontSize: 14)),
                                Text(item.$2,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),

              const SizedBox(height: 32),

              if (_result != null && _result!.verified) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.goNamed('dashboard'),
                    child: const Text('Continue to Dashboard'),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.goNamed('dashboard'),
                    child: const Text('Skip for Now'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(GitHubVerifyResult result) {
    return AuctorCard(
      glowColor: result.verified ? AppTheme.accentGreen : AppTheme.accentRed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.bgElevated,
                child: Text(
                  result.username.isNotEmpty
                      ? result.username[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('@${result.username}',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('${result.repos} repos · ${result.stars} stars',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              StatusPill(
                label: result.verified ? 'Verified' : 'Failed',
                type:
                    result.verified ? StatusType.verified : StatusType.failed,
              ),
            ],
          ),
          if (result.matchedProjects.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text('Projects matched from your CV:',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
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
