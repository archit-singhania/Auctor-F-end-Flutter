import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auctor_api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_toggle_button.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/auctor_widgets.dart';

class BadgeChallengeScreen extends ConsumerStatefulWidget {
  final String badgeName;
  const BadgeChallengeScreen({super.key, required this.badgeName});

  @override
  ConsumerState<BadgeChallengeScreen> createState() => _BadgeChallengeScreenState();
}

class _BadgeChallengeScreenState extends ConsumerState<BadgeChallengeScreen> {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  int _correctCount = 0;
  bool _challengeComplete = false;
  bool _isSubmitting = false;
  BadgeSubmitResult? _submitResult;

  static const List<_Question> _questions = [
    _Question(
      text: 'What does JWT stand for?',
      options: ['Java Web Token', 'JSON Web Token', 'JavaScript Web Transfer', 'Java Web Transfer'],
      correct: 1,
    ),
    _Question(
      text: 'Which part of a JWT contains the user claims?',
      options: ['Header', 'Signature', 'Payload', 'Footer'],
      correct: 2,
    ),
    _Question(
      text: 'What algorithm is commonly used to sign JWTs?',
      options: ['MD5', 'SHA-1', 'HS256', 'AES-256'],
      correct: 2,
    ),
    _Question(
      text: 'Where should a JWT be stored on the client for best security?',
      options: ['localStorage', 'URL query params', 'HttpOnly cookie', 'sessionStorage'],
      correct: 2,
    ),
    _Question(
      text: 'What happens when a JWT expires?',
      options: ['It auto-refreshes', 'Server returns 401 Unauthorized', 'The header resets', "Nothing, it's still valid"],
      correct: 1,
    ),
  ];

  void _selectAnswer(int idx) {
    if (_selectedAnswer != null) return;
    setState(() => _selectedAnswer = idx);
    if (idx == _questions[_currentQuestion].correct) setState(() => _correctCount++);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_currentQuestion < _questions.length - 1) {
        setState(() { _currentQuestion++; _selectedAnswer = null; });
      } else {
        setState(() => _challengeComplete = true);
        _submitResult_();
      }
    });
  }

  Future<void> _submitResult_() async {
    setState(() => _isSubmitting = true);
    try {
      final result = await ref.read(apiServiceProvider).submitBadge(
            badgeId: 'jwt-auth',
            correctAnswers: _correctCount,
            totalQuestions: _questions.length,
          );
      setState(() => _submitResult = result);
      if (result.passed) await ref.read(scoreProvider.notifier).refresh();
    } catch (e) {
      debugPrint('[BadgeChallenge] submitBadge error: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  bool get _passed => _correctCount >= AppConstants.badgePassThreshold;

  @override
  Widget build(BuildContext context) {
    if (_challengeComplete) return _buildResult(context);

    final q = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barBg = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.badgeName} Badge'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.goNamed('dashboard'),
          tooltip: 'Back',
        ),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('Question ${_currentQuestion + 1}/${_questions.length}',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text('$_correctCount correct',
                  style: const TextStyle(color: AppTheme.accentGreen, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: barBg,
                valueColor: const AlwaysStoppedAnimation(AppTheme.accentGold),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 40),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('🔐', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(widget.badgeName,
                    style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w700, fontSize: 13)),
              ]),
            ),

            const SizedBox(height: 24),

            Text(q.text,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22, height: 1.4),
                key: ValueKey(_currentQuestion))
                .animate(key: ValueKey('q$_currentQuestion'))
                .fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 32),

            ...q.options.asMap().entries.map((entry) {
              final i   = entry.key;
              final opt = entry.value;
              Color borderC = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;
              Color bgC     = Theme.of(context).colorScheme.surface;
              Color textC   = Theme.of(context).colorScheme.onSurface;

              if (_selectedAnswer != null) {
                if (i == q.correct) {
                  borderC = AppTheme.accentGreen;
                  bgC     = AppTheme.accentGreen.withValues(alpha: 0.1);
                  textC   = AppTheme.accentGreen;
                } else if (i == _selectedAnswer) {
                  borderC = AppTheme.accentRed;
                  bgC     = AppTheme.accentRed.withValues(alpha: 0.1);
                  textC   = AppTheme.accentRed;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => _selectAnswer(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bgC,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderC, width: 1.5),
                    ),
                    child: Row(children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _selectedAnswer == null
                              ? (isDark ? AppTheme.bgElevated : AppTheme.lBgElevated)
                              : borderC.withValues(alpha: 0.2),
                          border: Border.all(color: borderC),
                        ),
                        child: Center(
                          child: Text(['A', 'B', 'C', 'D'][i],
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textC)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(opt, style: TextStyle(color: textC, fontSize: 15, fontWeight: FontWeight.w500))),
                      if (_selectedAnswer != null && i == q.correct)
                        const Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 18),
                      if (_selectedAnswer == i && i != q.correct)
                        const Icon(Icons.cancel_rounded, color: AppTheme.accentRed, size: 18),
                    ]),
                  ),
                ).animate(key: ValueKey('o${_currentQuestion}_$i'))
                    .fadeIn(delay: Duration(milliseconds: 50 * i), duration: 300.ms),
              );
            }),
          ]),
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.goNamed('dashboard'),
          tooltip: 'Back to Dashboard',
        ),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (_isSubmitting) ...[
              const SizedBox(width: 24, height: 24,
                  child: CircularProgressIndicator(color: AppTheme.accentGold, strokeWidth: 2)),
              const SizedBox(height: 12),
              Text('Saving result...', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 32),
            ],

            Text(_passed ? '🎉' : '😔', style: const TextStyle(fontSize: 72))
                .animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 24),

            Text(_passed ? 'Badge Earned!' : 'Not Quite Yet',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: _passed ? AppTheme.accentGold : null,
                    )).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 8),

            Text(
              _passed
                  ? 'You answered $_correctCount/${_questions.length} correctly.\nYour JWT Auth skill is now verified!'
                  : 'You answered $_correctCount/${_questions.length} correctly.\nYou need ${AppConstants.badgePassThreshold}+ to earn this badge.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
            ).animate().fadeIn(delay: 300.ms),

            if (_submitResult != null && _passed) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.3)),
                ),
                child: Text('+${(_submitResult!.scoreGained * 10).toStringAsFixed(1)} score points added',
                    style: const TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.w700, fontSize: 13)),
              ).animate().fadeIn(delay: 400.ms),
            ],

            const SizedBox(height: 40),

            if (_passed) ...[
              AuctorCard(
                glowColor: AppTheme.accentGold,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('🔐', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('JWT Auth', style: Theme.of(context).textTheme.titleLarge),
                    const StatusPill(label: 'Verified', type: StatusType.verified),
                  ]),
                ]),
              ).animate().scale(delay: 400.ms, duration: 400.ms),
              const SizedBox(height: 32),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () => context.goNamed('dashboard'), child: const Text('Back to Dashboard')),
            ),

            if (!_passed) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentQuestion = 0; _selectedAnswer = null;
                      _correctCount = 0; _challengeComplete = false; _submitResult = null;
                    });
                  },
                  child: const Text('Try Again'),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

class _Question {
  final String text;
  final List<String> options;
  final int correct;
  const _Question({required this.text, required this.options, required this.correct});
}
