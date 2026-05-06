import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/theme_toggle_button.dart';
import '../../core/services/auctor_api_service.dart';
import '../../shared/widgets/auctor_logo.dart';
import 'cv_state.dart';

class CvUploadScreen extends ConsumerStatefulWidget {
  const CvUploadScreen({super.key});

  @override
  ConsumerState<CvUploadScreen> createState() => _CvUploadScreenState();
}

class _CvUploadScreenState extends ConsumerState<CvUploadScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;
  bool _isAnalyzing = false;
  String? _errorMessage;
  bool _isDragging = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _selectedFileName = file.name;
        _selectedFileBytes = file.bytes;
        _errorMessage = null;
      });
    }
  }

  Future<void> _analyzeCV() async {
    if (_selectedFileName == null || _selectedFileBytes == null) return;
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final extractedData =
          await apiService.parseCv(_selectedFileBytes!, _selectedFileName!);
      ref.read(cvDataProvider.notifier).setData(extractedData);
      if (mounted) context.goNamed('cv-review');
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Analysis failed: $e');
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bg = isDark ? AppTheme.bgDark : AppTheme.lBg;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () =>
              context.canPop() ? context.pop() : context.goNamed('home'),
          tooltip: 'Back',
        ),
        title: Row(children: [
          const AuctorLogo(size: 28),
          const SizedBox(width: 10),
          const Text('Auctor'),
        ]),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _StepIndicator(currentStep: 0),
              const SizedBox(height: 36),

              // ── Hero heading ────────────────────────────────────────
              RichText(
                text: TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontSize: 30, height: 1.2),
                  children: const [
                    TextSpan(text: 'Upload your '),
                    TextSpan(
                      text: 'CV',
                      style: TextStyle(color: AppTheme.accentGold),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15, end: 0),

              const SizedBox(height: 8),
              Text(
                'Our AI extracts skills, projects & experience automatically.',
                style: Theme.of(context).textTheme.bodyLarge,
              ).animate().fadeIn(delay: 80.ms, duration: 400.ms),

              const SizedBox(height: 32),

              // ── Upload dropzone ──────────────────────────────────────
              _UploadDropzone(
                isDark: isDark,
                fileName: _selectedFileName,
                isDragging: _isDragging,
                onTap: _pickFile,
                onClear: () => setState(() {
                  _selectedFileName = null;
                  _selectedFileBytes = null;
                }),
                pulseController: _pulseController,
              ).animate().fadeIn(delay: 160.ms, duration: 500.ms),

              const SizedBox(height: 20),

              // ── Feature chips ────────────────────────────────────────
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FeatureChip(
                    icon: Icons.auto_awesome_rounded,
                    label: 'AI-powered',
                    isDark: isDark,
                  ),
                  _FeatureChip(
                    icon: Icons.lock_outline_rounded,
                    label: 'Secure & private',
                    isDark: isDark,
                  ),
                  _FeatureChip(
                    icon: Icons.bolt_rounded,
                    label: '~10 seconds',
                    isDark: isDark,
                  ),
                  _FeatureChip(
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'PDF only · max 10 MB',
                    isDark: isDark,
                  ),
                ],
              ).animate().fadeIn(delay: 220.ms, duration: 400.ms),

              // ── Error banner ─────────────────────────────────────────
              if (_errorMessage != null) ...[const SizedBox(height: 16), _ErrorBanner(message: _errorMessage!)],

              const SizedBox(height: 32),

              // ── What we extract preview ──────────────────────────────
              _ExtractPreviewCard(isDark: isDark)
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 32),

              // ── CTA button ───────────────────────────────────────────
              _AnalyzeButton(
                enabled: _selectedFileName != null && !_isAnalyzing,
                isAnalyzing: _isAnalyzing,
                onPressed: _analyzeCV,
              ).animate().fadeIn(delay: 360.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Upload dropzone
// ─────────────────────────────────────────────────────────────────────────────
class _UploadDropzone extends StatelessWidget {
  final bool isDark;
  final String? fileName;
  final bool isDragging;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final AnimationController pulseController;

  const _UploadDropzone({
    required this.isDark,
    required this.fileName,
    required this.isDragging,
    required this.onTap,
    required this.onClear,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppTheme.bgCard : AppTheme.lBgCard;
    final border = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;
    final hasFile = fileName != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: hasFile
              ? AppTheme.accentGold.withValues(alpha: 0.06)
              : isDragging
                  ? AppTheme.accentGold.withValues(alpha: 0.08)
                  : cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: hasFile
                ? AppTheme.accentGold.withValues(alpha: 0.55)
                : isDragging
                    ? AppTheme.accentGold.withValues(alpha: 0.4)
                    : border,
            width: hasFile ? 1.5 : 1,
          ),
          boxShadow: hasFile
              ? [
                  BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.08),
                    blurRadius: 24,
                    spreadRadius: 0,
                  )
                ]
              : null,
        ),
        child: hasFile ? _FileSelected(fileName: fileName!, onClear: onClear) : _FileEmpty(isDark: isDark),
      ),
    );
  }
}

class _FileEmpty extends StatelessWidget {
  final bool isDark;
  const _FileEmpty({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final elevBg = isDark ? AppTheme.bgElevated : AppTheme.lBgElevated;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: elevBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.accentGold.withValues(alpha: 0.2),
            ),
          ),
          child: const Icon(
            Icons.upload_file_rounded,
            color: AppTheme.accentGold,
            size: 30,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Tap to upload PDF',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'or drag and drop here',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.accentGold.withValues(alpha: 0.25),
            ),
          ),
          child: const Text(
            'PDF up to 10 MB',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.accentGold,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _FileSelected extends StatelessWidget {
  final String fileName;
  final VoidCallback onClear;
  const _FileSelected({required this.fileName, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AppTheme.accentGold,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.accentGold,
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Ready to analyze',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SmallPill(
                icon: Icons.check_circle_rounded,
                label: 'PDF verified',
                color: AppTheme.accentGreen,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClear,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppTheme.accentRed.withValues(alpha: 0.25)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close_rounded,
                          size: 12, color: AppTheme.accentRed),
                      SizedBox(width: 4),
                      Text(
                        'Remove',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.accentRed,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SmallPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feature chips
// ─────────────────────────────────────────────────────────────────────────────
class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _FeatureChip(
      {required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgElevated : AppTheme.lBgElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isDark ? AppTheme.borderColor : AppTheme.lBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.textSecondary),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error banner
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accentRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppTheme.accentRed.withValues(alpha: 0.3)),
      ),
      child: Row(
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
                  color: AppTheme.accentRed,
                  fontSize: 13,
                  height: 1.4),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Extraction preview card
// ─────────────────────────────────────────────────────────────────────────────
class _ExtractPreviewCard extends StatelessWidget {
  final bool isDark;
  const _ExtractPreviewCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppTheme.bgCard : AppTheme.lBgCard;
    final border = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;

    const items = [
      _ExtractItem(
        icon: Icons.psychology_rounded,
        color: AppTheme.accentGold,
        title: 'Skills',
        subtitle: 'Languages, frameworks & tools',
      ),
      _ExtractItem(
        icon: Icons.rocket_launch_rounded,
        color: AppTheme.accentBlue,
        title: 'Projects',
        subtitle: 'Names, descriptions, tech stack',
      ),
      _ExtractItem(
        icon: Icons.work_history_rounded,
        color: AppTheme.accentGreen,
        title: 'Experience',
        subtitle: 'Companies, roles & duration',
      ),
    ];

    return Container(
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
            'What we extract',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    )),
                        Text(item.subtitle,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: item.color.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtractItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _ExtractItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Analyze CTA button
// ─────────────────────────────────────────────────────────────────────────────
class _AnalyzeButton extends StatelessWidget {
  final bool enabled;
  final bool isAnalyzing;
  final VoidCallback onPressed;
  const _AnalyzeButton(
      {required this.enabled,
      required this.isAnalyzing,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: enabled ? AppTheme.accentGold : AppTheme.accentGold.withValues(alpha: 0.35),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? onPressed : null,
            child: Center(
              child: isAnalyzing
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: AppTheme.bgDark,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Analyzing CV\u2026',
                          style: TextStyle(
                            color: AppTheme.bgDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: AppTheme.bgDark, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          enabled ? 'Analyze My CV' : 'Select a PDF first',
                          style: const TextStyle(
                            color: AppTheme.bgDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step indicator
// ─────────────────────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const steps = ['Upload', 'Review', 'Connect', 'Verify'];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveBorder =
        isDark ? AppTheme.borderColor : AppTheme.lBorderColor;

    return Row(
      children: List.generate(steps.length, (i) {
        final isActive = i == currentStep;
        final isDone = i < currentStep;
        return Expanded(
          child: Row(children: [
            Expanded(
              child: Column(children: [
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: isDone || isActive
                        ? AppTheme.accentGold
                        : inactiveBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                Text(steps[i],
                    style: TextStyle(
                        fontSize: 10,
                        color: isActive
                            ? AppTheme.accentGold
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w400)),
              ]),
            ),
            if (i < steps.length - 1) const SizedBox(width: 4),
          ]),
        );
      }),
    );
  }
}
