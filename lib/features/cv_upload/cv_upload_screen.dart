import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/theme_toggle_button.dart';
import '../../core/services/auctor_api_service.dart';
import '../../core/constants/app_constants.dart';
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
  String _analyzingStage = 'Reading your PDF\u2026';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _warmUpNow();
  }

  Future<void> _warmUpNow() async {
    try {
      await http
          .get(Uri.parse('${AppConstants.apiBaseUrl}/ping'))
          .timeout(const Duration(seconds: 12));
    } catch (_) {}
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
      _analyzingStage = 'Reading your PDF\u2026';
    });

    // Cycle through status messages during Railway cold-start wait
    final stages = [
      (1500, 'Extracting text\u2026'),
      (3500, 'Parsing skills & projects\u2026'),
      (6000, 'Detecting profile links\u2026'),
      (9000, 'Finalising your score data\u2026'),
    ];
    for (final s in stages) {
      Future.delayed(Duration(milliseconds: s.$1), () {
        if (mounted && _isAnalyzing) setState(() => _analyzingStage = s.$2);
      });
    }

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () =>
              context.canPop() ? context.pop() : context.goNamed('home'),
          tooltip: 'Back',
        ),
        title: const Row(children: [
          AuctorLogo(size: 26),
          SizedBox(width: 8),
          Text('Auctor', style: TextStyle(fontWeight: FontWeight.w700)),
        ]),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              _StepIndicator(currentStep: 0, isDark: isDark)
                  .animate()
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: 36),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                      color: AppTheme.accentGold.withValues(alpha: 0.22)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded,
                        size: 12, color: AppTheme.accentGold),
                    SizedBox(width: 5),
                    Text(
                      'STEP 1 OF 4 \u2014 UPLOAD',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        letterSpacing: 1.8,
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 80.ms, duration: 400.ms),

              const SizedBox(height: 16),

              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 34,
                        height: 1.15,
                        letterSpacing: -1.0,
                      ),
                  children: const [
                    TextSpan(text: 'Drop your CV.\nGet your '),
                    TextSpan(
                      text: 'verified score.',
                      style: TextStyle(color: AppTheme.accentGold),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 120.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 10),

              Text(
                'AI reads your PDF in seconds \u2014 extracts skills, projects, and all your profile links. No forms. No manual input.',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(height: 1.6, fontSize: 15),
              ).animate().fadeIn(delay: 180.ms, duration: 400.ms),

              const SizedBox(height: 32),

              _UploadDropzone(
                isDark: isDark,
                fileName: _selectedFileName,
                onTap: _pickFile,
                onClear: () => setState(() {
                  _selectedFileName = null;
                  _selectedFileBytes = null;
                }),
              ).animate().fadeIn(delay: 240.ms, duration: 500.ms),

              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _FeatureTag(
                      icon: Icons.bolt_rounded, label: '~10 sec analysis'),
                  _FeatureTag(
                      icon: Icons.lock_outline_rounded,
                      label: 'Secure & private'),
                  _FeatureTag(
                      icon: Icons.picture_as_pdf_rounded,
                      label: 'PDF \u00b7 max 10 MB'),
                  _FeatureTag(
                      icon: Icons.auto_awesome_rounded, label: 'AI-powered'),
                ],
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _ErrorBanner(message: _errorMessage!),
              ],

              const SizedBox(height: 32),

              _WhatWeExtractCard(isDark: isDark)
                  .animate()
                  .fadeIn(delay: 360.ms, duration: 400.ms),

              const SizedBox(height: 28),

              _AnalyzeButton(
                enabled: _selectedFileName != null && !_isAnalyzing,
                isAnalyzing: _isAnalyzing,
                analyzingStage: _analyzingStage,
                onPressed: _analyzeCV,
              ).animate().fadeIn(delay: 420.ms, duration: 400.ms),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  'We never store your CV permanently. Deleted after processing.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.textMuted : AppTheme.lTextMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ).animate().fadeIn(delay: 480.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final bool isDark;
  const _StepIndicator({required this.currentStep, required this.isDark});

  @override
  Widget build(BuildContext context) {
    const steps = ['Upload', 'Review', 'Connect', 'Score'];
    final inactiveColor = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;
    final inactiveText = isDark ? AppTheme.textMuted : AppTheme.lTextMuted;

    return Row(
      children: List.generate(steps.length, (i) {
        final isActive = i == currentStep;
        final isDone = i < currentStep;
        final color = (isActive || isDone) ? AppTheme.accentGold : inactiveColor;

        return Expanded(
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 3,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    steps[i],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      color: isActive ? AppTheme.accentGold : inactiveText,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            if (i < steps.length - 1) const SizedBox(width: 6),
          ]),
        );
      }),
    );
  }
}

// ── Upload drop zone ──────────────────────────────────────────────────────────
class _UploadDropzone extends StatefulWidget {
  final bool isDark;
  final String? fileName;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _UploadDropzone({
    required this.isDark,
    required this.fileName,
    required this.onTap,
    required this.onClear,
  });

  @override
  State<_UploadDropzone> createState() => _UploadDropzoneState();
}

class _UploadDropzoneState extends State<_UploadDropzone>
    with SingleTickerProviderStateMixin {
  bool _hovering = false;
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDark ? AppTheme.bgCard : AppTheme.lBgCard;
    final hasFile = widget.fileName != null;

    final activeBorder = hasFile || _hovering
        ? AppTheme.accentGold.withValues(alpha: 0.55)
        : (widget.isDark ? AppTheme.borderColor : AppTheme.lBorderColor);
    final activeBg = hasFile
        ? AppTheme.accentGold.withValues(alpha: 0.05)
        : _hovering
            ? AppTheme.accentGold.withValues(alpha: 0.04)
            : cardBg;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 192),
          decoration: BoxDecoration(
            color: activeBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: activeBorder, width: hasFile ? 1.5 : 1.0),
            boxShadow: hasFile
                ? [
                    BoxShadow(
                      color: AppTheme.accentGold.withValues(alpha: 0.1),
                      blurRadius: 28,
                    )
                  ]
                : null,
          ),
          child: hasFile
              ? _FileConfirmed(
                  fileName: widget.fileName!,
                  onClear: widget.onClear,
                  elevBg: widget.isDark ? AppTheme.bgElevated : AppTheme.lBgElevated,
                )
              : _FilePrompt(isDark: widget.isDark, hovering: _hovering),
        ),
      ),
    );
  }
}

class _FilePrompt extends StatelessWidget {
  final bool isDark;
  final bool hovering;
  const _FilePrompt({required this.isDark, required this.hovering});

  @override
  Widget build(BuildContext context) {
    final elevBg = isDark ? AppTheme.bgElevated : AppTheme.lBgElevated;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: hovering ? AppTheme.accentGold.withValues(alpha: 0.15) : elevBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppTheme.accentGold
                      .withValues(alpha: hovering ? 0.4 : 0.18)),
            ),
            child: Icon(
              Icons.upload_file_rounded,
              color: AppTheme.accentGold.withValues(alpha: hovering ? 1.0 : 0.8),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap to select your PDF',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'or drag and drop here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 14),
          const _GoldPill(label: 'PDF format \u00b7 max 10 MB'),
        ],
      ),
    );
  }
}

class _FileConfirmed extends StatelessWidget {
  final String fileName;
  final VoidCallback onClear;
  final Color elevBg;
  const _FileConfirmed({
    required this.fileName,
    required this.onClear,
    required this.elevBg,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded,
                    color: AppTheme.accentGold, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    const Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 12, color: AppTheme.accentTeal),
                        SizedBox(width: 4),
                        Text(
                          'Ready to analyze',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.accentTeal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const _GoldPill(label: 'PDF verified'),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClear,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppTheme.accentRed.withValues(alpha: 0.25)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close_rounded, size: 12, color: AppTheme.accentRed),
                      SizedBox(width: 4),
                      Text(
                        'Remove',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.accentRed,
                          fontWeight: FontWeight.w600,
                        ),
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

class _GoldPill extends StatelessWidget {
  final String label;
  const _GoldPill({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.accentGold,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── Feature tags ──────────────────────────────────────────────────────────────
class _FeatureTag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          Icon(icon,
              size: 12,
              color: isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.textSecondary : AppTheme.lTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────
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
        border: Border.all(color: AppTheme.accentRed.withValues(alpha: 0.3)),
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
                  color: AppTheme.accentRed, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }
}

// ── What we extract card ──────────────────────────────────────────────────────
class _WhatWeExtractCard extends StatelessWidget {
  final bool isDark;
  const _WhatWeExtractCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppTheme.bgCard : AppTheme.lBgCard;
    final border = isDark ? AppTheme.borderColor : AppTheme.lBorderColor;
    final textMut = isDark ? AppTheme.textMuted : AppTheme.lTextMuted;

    const items = [
      _ExtractItem(
        icon: Icons.psychology_rounded,
        color: AppTheme.accentGold,
        title: 'Skills & Technologies',
        subtitle: 'Languages, frameworks, databases, tools',
      ),
      _ExtractItem(
        icon: Icons.rocket_launch_rounded,
        color: AppTheme.accentBlue,
        title: 'Projects',
        subtitle: 'Names, descriptions, tech stack used',
      ),
      _ExtractItem(
        icon: Icons.work_history_rounded,
        color: AppTheme.accentTeal,
        title: 'Work Experience',
        subtitle: 'Companies, roles & duration',
      ),
      _ExtractItem(
        icon: Icons.code_rounded,
        color: Color(0xFF94A3B8),
        title: 'GitHub Username',
        subtitle: 'Auto-detected from links in your CV',
      ),
      _ExtractItem(
        icon: Icons.business_center_rounded,
        color: Color(0xFF0A66C2),
        title: 'LinkedIn Profile',
        subtitle: 'Extracted from your CV link or label',
      ),
      _ExtractItem(
        icon: Icons.terminal_rounded,
        color: Color(0xFFF59E0B),
        title: 'LeetCode & GeeksForGeeks',
        subtitle: 'Competitive programming profiles',
      ),
      _ExtractItem(
        icon: Icons.email_rounded,
        color: Color(0xFFEC4899),
        title: 'Email & Phone',
        subtitle: 'Contact info directly from the PDF',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Row(
              children: [
                Text(
                  'What gets extracted',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Automatic',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.accentTeal,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ...items.asMap().entries.map((e) => Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: border.withValues(alpha: 0.5)),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: e.value.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(e.value.icon, color: e.value.color, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.value.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            e.value.subtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: e.value.color.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              )),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 12, color: textMut),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "You review and confirm everything before it's saved.",
                    style: TextStyle(
                        fontSize: 11, color: textMut, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
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

// ── Analyze CTA button ────────────────────────────────────────────────────────
class _AnalyzeButton extends StatelessWidget {
  final bool enabled;
  final bool isAnalyzing;
  final String analyzingStage;
  final VoidCallback onPressed;
  const _AnalyzeButton({
    required this.enabled,
    required this.isAnalyzing,
    required this.analyzingStage,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: enabled
              ? AppTheme.accentGold
              : AppTheme.accentGold.withValues(alpha: 0.3),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: enabled ? onPressed : null,
            child: Center(
              child: isAnalyzing
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: AppTheme.bgDark,
                            strokeWidth: 2.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          analyzingStage,
                          style: const TextStyle(
                            color: AppTheme.bgDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          enabled
                              ? Icons.auto_awesome_rounded
                              : Icons.upload_file_outlined,
                          color: AppTheme.bgDark,
                          size: 18,
                        ),
                        const SizedBox(width: 9),
                        Text(
                          enabled ? 'Analyze My CV' : 'Select a PDF first',
                          style: const TextStyle(
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
    );
  }
}
