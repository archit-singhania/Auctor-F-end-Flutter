import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/auctor_models.dart';

// ────────────────────────────────────────────────────────────────────────────
// CV DATA STATE
// ────────────────────────────────────────────────────────────────────────────

/// Holds the structured data extracted from the uploaded CV.
/// Populated by CvUploadScreen after calling AuctorApiService.parseCv().
class CvDataNotifier extends StateNotifier<ExtractedCvData> {
  CvDataNotifier() : super(ExtractedCvData.empty());

  /// Called with real data from the API response.
  void setData(ExtractedCvData data) => state = data;

  /// Mark a specific skill as verified (after badge challenge pass).
  void markSkillVerified(String skill) {
    final updatedProjects = state.projects.map((p) {
      if (p.techStack.contains(skill)) {
        return Project(
          name: p.name,
          description: p.description,
          techStack: p.techStack,
          isVerified: true,
        );
      }
      return p;
    }).toList();

    state = ExtractedCvData(
      skills: state.skills,
      projects: updatedProjects,
      experience: state.experience,
    );
  }
}

final cvDataProvider =
    StateNotifierProvider<CvDataNotifier, ExtractedCvData>((ref) {
  return CvDataNotifier();
});

// ────────────────────────────────────────────────────────────────────────────
// VERIFICATION STATE
// ────────────────────────────────────────────────────────────────────────────

/// Tracks which external platforms have been verified in the current session.
/// Key: platform name ('github', 'leetcode'), Value: verified flag.
class VerificationNotifier extends StateNotifier<Map<String, bool>> {
  VerificationNotifier() : super({});

  void markVerified(String platform) {
    state = {...state, platform: true};
  }

  bool isVerified(String platform) => state[platform] ?? false;
}

final verificationProvider =
    StateNotifierProvider<VerificationNotifier, Map<String, bool>>((ref) {
  return VerificationNotifier();
});
