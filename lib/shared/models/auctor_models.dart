// Shared data models for Auctor
// All fromJson factories match the FastAPI response schemas exactly.

class ExtractedCvData {
  final List<String> skills;
  final List<Project> projects;
  final List<Experience> experience;

  const ExtractedCvData({
    required this.skills,
    required this.projects,
    required this.experience,
  });

  factory ExtractedCvData.empty() => const ExtractedCvData(
        skills: [],
        projects: [],
        experience: [],
      );

  factory ExtractedCvData.fromJson(Map<String, dynamic> json) {
    return ExtractedCvData(
      skills: List<String>.from(json['skills'] as List? ?? []),
      projects: (json['projects'] as List? ?? [])
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList(),
      experience: (json['experience'] as List? ?? [])
          .map((e) => Experience.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'skills': skills,
        'projects': projects.map((p) => p.toJson()).toList(),
        'experience': experience.map((e) => e.toJson()).toList(),
      };
}

class Project {
  final String name;
  final String description;
  final List<String> techStack;
  bool isVerified;

  Project({
    required this.name,
    required this.description,
    required this.techStack,
    this.isVerified = false,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        techStack: List<String>.from(json['tech_stack'] as List? ?? []),
        isVerified: json['is_verified'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'tech_stack': techStack,
        'is_verified': isVerified,
      };
}

class Experience {
  final String company;
  final String role;
  final String duration;
  bool isVerified;

  Experience({
    required this.company,
    required this.role,
    required this.duration,
    this.isVerified = false,
  });

  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
        company: json['company'] as String? ?? '',
        role: json['role'] as String? ?? '',
        duration: json['duration'] as String? ?? '',
        isVerified: json['is_verified'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'company': company,
        'role': role,
        'duration': duration,
        'is_verified': isVerified,
      };
}

class VerificationStatus {
  final String type; // github, leetcode, certificate, experience
  final String status; // verified, pending, failed, not_started
  final String? detail;

  const VerificationStatus({
    required this.type,
    required this.status,
    this.detail,
  });
}

class Badge {
  final String id;
  final String name;
  final String skill;
  final String status; // locked, suggested, in_progress, earned
  final int xpValue;
  final String icon;

  const Badge({
    required this.id,
    required this.name,
    required this.skill,
    required this.status,
    required this.xpValue,
    required this.icon,
  });
}

class AuctorScore {
  final double total;
  final double github;
  final double leetcode;
  final double badges;
  final double projects;
  final double experience;

  const AuctorScore({
    required this.total,
    required this.github,
    required this.leetcode,
    required this.badges,
    required this.projects,
    required this.experience,
  });

  factory AuctorScore.empty() => const AuctorScore(
        total: 0,
        github: 0,
        leetcode: 0,
        badges: 0,
        projects: 0,
        experience: 0,
      );

  factory AuctorScore.fromJson(Map<String, dynamic> json) => AuctorScore(
        total: (json['total'] as num?)?.toDouble() ?? 0.0,
        github: (json['github'] as num?)?.toDouble() ?? 0.0,
        leetcode: (json['leetcode'] as num?)?.toDouble() ?? 0.0,
        badges: (json['badges'] as num?)?.toDouble() ?? 0.0,
        projects: (json['projects'] as num?)?.toDouble() ?? 0.0,
        experience: (json['experience'] as num?)?.toDouble() ?? 0.0,
      );
}
