// Re-exports all global providers so feature screens import one path.
// Usage: import 'package:auctor_app/shared/providers/providers.dart';
export 'package:auctor_app/features/cv_upload/cv_state.dart'
    show cvDataProvider, CvDataNotifier, verificationProvider, VerificationNotifier;
export 'score_provider.dart' show scoreProvider, ScoreNotifier;
