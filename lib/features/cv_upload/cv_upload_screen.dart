import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auctor_api_service.dart';
import 'cv_state.dart';

class CvUploadScreen extends ConsumerStatefulWidget {
  const CvUploadScreen({super.key});

  @override
  ConsumerState<CvUploadScreen> createState() => _CvUploadScreenState();
}

class _CvUploadScreenState extends ConsumerState<CvUploadScreen> {
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;
  bool _isAnalyzing = false;
  String? _errorMessage;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // needed to read bytes on all platforms
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
      // POST /api/cv/parse — sends raw PDF bytes as multipart.
      // In mock mode (AppConstants.useMockData = true) this returns fake data.
      final extractedData = await apiService.parseCv(
        _selectedFileBytes!,
        _selectedFileName!,
      );
      ref.read(cvDataProvider.notifier).setData(extractedData);

      if (mounted) {
        context.goNamed('cv-review');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Analysis failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.accentGold,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text('A',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: AppTheme.bgDark)),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Auctor'),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _StepIndicator(currentStep: 0),
              const SizedBox(height: 32),
              Text(
                'Upload your CV',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontSize: 32),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'Our AI extracts your skills, projects, and experience automatically.',
                style: Theme.of(context).textTheme.bodyLarge,
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 40),

              // Drop zone
              GestureDetector(
                onTap: _pickFile,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: _selectedFileName != null
                        ? AppTheme.accentGold.withValues(alpha: 0.05)
                        : AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedFileName != null
                          ? AppTheme.accentGold.withValues(alpha: 0.5)
                          : AppTheme.borderColor,
                      width: 1.5,
                    ),
                  ),
                  child: _selectedFileName == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppTheme.bgElevated,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.upload_file_rounded,
                                  color: AppTheme.accentGold, size: 28),
                            ),
                            const SizedBox(height: 16),
                            Text('Tap to upload PDF',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: AppTheme.textPrimary)),
                            const SizedBox(height: 4),
                            Text('PDF up to 10MB',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.picture_as_pdf_rounded,
                                color: AppTheme.accentGold, size: 40),
                            const SizedBox(height: 12),
                            Text(
                              _selectedFileName!,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: AppTheme.accentGold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _pickFile,
                              child: const Text('Change file'),
                            ),
                          ],
                        ),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 16),

              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                      icon: Icons.flash_on_rounded,
                      label: 'AI-powered extraction'),
                  _InfoChip(
                      icon: Icons.lock_rounded, label: 'Secure & private'),
                  _InfoChip(icon: Icons.timer_rounded, label: '~10 seconds'),
                ],
              ),

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
                      Text(_errorMessage!,
                          style: const TextStyle(
                              color: AppTheme.accentRed, fontSize: 13)),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: _isAnalyzing
                    ? Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: AppTheme.bgDark, strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Analyzing CV...',
                                style: TextStyle(
                                    color: AppTheme.bgDark,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                          ],
                        ),
                      )
                    : ElevatedButton(
                        onPressed:
                            _selectedFileName != null ? _analyzeCV : null,
                        child: const Text('Analyze My CV'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.bgElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
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

class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const steps = ['Upload', 'Review', 'Connect', 'Verify'];
    return Row(
      children: List.generate(steps.length, (i) {
        final isActive = i == currentStep;
        final isDone = i < currentStep;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: isDone || isActive
                            ? AppTheme.accentGold
                            : AppTheme.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      steps[i],
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive
                            ? AppTheme.accentGold
                            : AppTheme.textSecondary,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < steps.length - 1) const SizedBox(width: 4),
            ],
          ),
        );
      }),
    );
  }
}
