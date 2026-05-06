import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/theme_toggle_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardPage> _pages = const [
    _OnboardPage(
      emoji: '📄',
      title: 'Upload Your CV',
      subtitle:
          'Drop your PDF resume. Auctor\'s AI engine extracts your skills, projects, and experience in seconds.',
    ),
    _OnboardPage(
      emoji: '🔍',
      title: 'Verify Everything',
      subtitle:
          'Connect GitHub, upload certificates. We cross-check your CV claims against real data.',
    ),
    _OnboardPage(
      emoji: '🏅',
      title: 'Earn Skill Badges',
      subtitle:
          'Take short challenges to prove what\'s on your resume. Verified badges carry real weight.',
    ),
    _OnboardPage(
      emoji: '🧠',
      title: 'Your Auctor Score',
      subtitle:
          'A single credibility number recruiters trust. No more fake resumes.',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(duration: 300.ms, curve: Curves.easeInOut);
    } else {
      context.goNamed('cv-upload');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bg = isDark ? AppTheme.bgDark : AppTheme.lBg;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.goNamed('home'),
          tooltip: 'Back',
        ),
        actions: [
          const ThemeToggleButton(),
          TextButton(
            onPressed: () => context.goNamed('cv-upload'),
            child: Text('Skip',
                style: TextStyle(
                    color: isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => _buildPage(_pages[i]),
              ),
            ),
            // Dots + CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                    _pages.length,
                    (i) => AnimatedContainer(
                    duration: 250.ms,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _currentPage ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                    color: i == _currentPage
                    ? AppTheme.accentGold
                    : (isDark ? AppTheme.borderColor : AppTheme.lBorderColor),
                    borderRadius: BorderRadius.circular(100),
                    ),
                    ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      child: Text(_currentPage < _pages.length - 1
                          ? 'Continue'
                          : 'Get Started'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardPage page) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textPrim = isDark ? AppTheme.textPrimary : AppTheme.lTextPrimary;
    final textSec  = isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(page.emoji, style: const TextStyle(fontSize: 72))
              .animate(key: ValueKey(page.emoji))
              .scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 40),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 30,
                  color: textPrim,
                ),
          )
              .animate(key: ValueKey('t${page.title}'))
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  height: 1.6,
                  color: textSec,
                ),
          )
              .animate(key: ValueKey('s${page.subtitle}'))
              .fadeIn(delay: 100.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

class _OnboardPage {
  final String emoji;
  final String title;
  final String subtitle;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}
