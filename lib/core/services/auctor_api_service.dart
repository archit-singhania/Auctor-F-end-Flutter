import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../../shared/models/auctor_models.dart';

/// Production API service.
/// AppConstants.useMockData = false  →  hits real FastAPI + PostgreSQL
/// AppConstants.useMockData = true   →  returns hardcoded mock data (no backend needed)
class AuctorApiService {
  /// Returns the correct base URL depending on platform.
  /// Web runs on the same machine as the server → use localhost directly.
  String get _base {
    if (kIsWeb) return 'http://localhost:8000';
    return AppConstants.apiBaseUrl; // 10.0.2.2:8000 for Android emulator
  }

  int get _uid => AppConstants.demoUserId;

  // ── CV PARSING ────────────────────────────────────────────────────────────

  Future<ExtractedCvData> parseCv(Uint8List pdfBytes, String fileName) async {
    if (AppConstants.useMockData) return _mockCvData();

    final uri = Uri.parse('$_base/api/cv/parse').replace(
      queryParameters: {'user_id': '$_uid'},
    );
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        pdfBytes,
        filename: fileName,
      ));

    try {
      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final body = await http.Response.fromStream(streamed);
      if (body.statusCode == 200) {
        return ExtractedCvData.fromJson(
            jsonDecode(body.body) as Map<String, dynamic>);
      }
      throw ApiException('CV parse failed: ${body.statusCode}', body.statusCode);
    } catch (e) {
      if (kDebugMode) debugPrint('[AuctorApi] parseCv error: $e');
      rethrow;
    }
  }

  // ── GITHUB VERIFICATION ───────────────────────────────────────────────────

  Future<GitHubVerifyResult> verifyGitHub(String username) async {
    if (AppConstants.useMockData) return _mockGitHubResult(username);

    final uri = Uri.parse('$_base/api/verify/github').replace(
      queryParameters: {
        'username': username,
        'user_id': '$_uid',
      },
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        return GitHubVerifyResult.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw ApiException(
          'GitHub verify failed: ${response.statusCode}', response.statusCode);
    } catch (e) {
      if (kDebugMode) debugPrint('[AuctorApi] verifyGitHub error: $e');
      rethrow;
    }
  }

  // ── SCORE ─────────────────────────────────────────────────────────────────

  Future<AuctorScore> fetchScore() async {
    if (AppConstants.useMockData) return _mockScore();

    final uri = Uri.parse('$_base/api/score').replace(
      queryParameters: {'user_id': '$_uid'},
    );

    try {
      final response =
          await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return AuctorScore.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw ApiException(
          'Score fetch failed: ${response.statusCode}', response.statusCode);
    } catch (e) {
      if (kDebugMode) debugPrint('[AuctorApi] fetchScore error: $e');
      rethrow;
    }
  }

  // ── BADGE SUBMISSION ──────────────────────────────────────────────────────

  Future<BadgeSubmitResult> submitBadge({
    required String badgeId,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    if (AppConstants.useMockData) {
      return BadgeSubmitResult(
        passed: correctAnswers >= AppConstants.badgePassThreshold,
        badgeId: badgeId,
        scoreGained:
            correctAnswers >= AppConstants.badgePassThreshold ? 0.8 : 0.0,
      );
    }

    final uri = Uri.parse('$_base/api/badges/submit').replace(
      queryParameters: {'user_id': '$_uid'},
    );

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'badge_id': badgeId,
              'correct_answers': correctAnswers,
              'total_questions': totalQuestions,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return BadgeSubmitResult.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw ApiException(
          'Badge submit failed: ${response.statusCode}', response.statusCode);
    } catch (e) {
      if (kDebugMode) debugPrint('[AuctorApi] submitBadge error: $e');
      rethrow;
    }
  }

  // ── MOCK DATA ─────────────────────────────────────────────────────────────

  Future<ExtractedCvData> _mockCvData() async {
    await Future.delayed(const Duration(seconds: 2));
    return ExtractedCvData(
      skills: [
        'JWT Authentication', 'REST API', 'Docker', 'PostgreSQL',
        'Redis', 'Node.js', 'FastAPI', 'Microservices',
      ],
      projects: [
        Project(
          name: 'Auth Microservice',
          description: 'JWT-based auth service with refresh tokens',
          techStack: ['JWT', 'Node.js', 'Redis', 'Docker'],
        ),
        Project(
          name: 'E-Commerce API',
          description: 'REST API for product catalog and order management',
          techStack: ['FastAPI', 'PostgreSQL', 'Docker'],
        ),
      ],
      experience: [
        Experience(
          company: 'TechCorp Pvt. Ltd.',
          role: 'Backend Developer Intern',
          duration: 'Jun 2023 – Dec 2023',
        ),
      ],
    );
  }

  Future<GitHubVerifyResult> _mockGitHubResult(String username) async {
    await Future.delayed(const Duration(seconds: 2));
    return GitHubVerifyResult(
      verified: true,
      username: username,
      repos: 24,
      stars: 87,
      matchedProjects: ['Auth Microservice', 'E-Commerce API'],
      profileUrl: 'https://github.com/$username',
    );
  }

  Future<AuctorScore> _mockScore() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const AuctorScore(
      total: 4.2,
      github: 0.65,
      leetcode: 0.0,
      badges: 0.1,
      projects: 0.2,
      experience: 0.0,
    );
  }
}

// ── RESULT TYPES ──────────────────────────────────────────────────────────────

class GitHubVerifyResult {
  final bool verified;
  final String username;
  final int repos;
  final int stars;
  final List<String> matchedProjects;
  final String profileUrl;

  const GitHubVerifyResult({
    required this.verified,
    required this.username,
    required this.repos,
    required this.stars,
    required this.matchedProjects,
    required this.profileUrl,
  });

  factory GitHubVerifyResult.fromJson(Map<String, dynamic> json) {
    return GitHubVerifyResult(
      verified: json['verified'] as bool? ?? false,
      username: json['username'] as String? ?? '',
      repos: json['repos'] as int? ?? 0,
      stars: json['stars'] as int? ?? 0,
      matchedProjects:
          List<String>.from(json['matched_projects'] as List? ?? []),
      profileUrl: json['profile_url'] as String? ?? '',
    );
  }
}

class BadgeSubmitResult {
  final bool passed;
  final String badgeId;
  final double scoreGained;

  const BadgeSubmitResult({
    required this.passed,
    required this.badgeId,
    required this.scoreGained,
  });

  factory BadgeSubmitResult.fromJson(Map<String, dynamic> json) {
    return BadgeSubmitResult(
      passed: json['passed'] as bool? ?? false,
      badgeId: json['badge_id'] as String? ?? '',
      scoreGained: (json['score_gained'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// ── PROVIDER ──────────────────────────────────────────────────────────────────

final apiServiceProvider = Provider<AuctorApiService>((ref) {
  return AuctorApiService();
});
