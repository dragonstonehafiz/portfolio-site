import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LandingPageData {
  final Intro intro;
  final List<WorkItem> experience;
  final List<EducationItem> education;
  final Skills skills;

  LandingPageData({
    required this.intro,
    required this.experience,
    required this.education,
    required this.skills,
  });

  factory LandingPageData.fromJson(Map<String, dynamic> json) {
    // Parse lists first so we can sort by start date (newest first)
    final intro = Intro.fromJson(Map<String, dynamic>.from(json['introduction'] ?? {}));
    final skills = Skills.fromJson(Map<String, dynamic>.from(json['skills'] ?? {}));

    final experience = (json['experience'] as List<dynamic>? ?? [])
        .map((e) => WorkItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    experience.sort((a, b) => _parseStartDate(b.start).compareTo(_parseStartDate(a.start)));

    final education = (json['education'] as List<dynamic>? ?? [])
        .map((e) => EducationItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    education.sort((a, b) => _parseStartDate(b.start).compareTo(_parseStartDate(a.start)));

    return LandingPageData(
      intro: intro,
      experience: experience,
      education: education,
      skills: skills,
    );
  }

  // Helper: parse a YYYY-MM or full ISO string; fallback to epoch if invalid.
  static DateTime _parseStartDate(String raw) {
    if (raw.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    try {
      // If only year-month provided, append day
      if (RegExp(r'^\d{4}-\d{2}$').hasMatch(raw)) {
        return DateTime.parse('$raw-01');
      }
      return DateTime.parse(raw);
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  static Future<LandingPageData> loadFromAssets([String path = 'assets/landing_page.json']) async {
    final raw = await rootBundle.loadString(path);
    final Map<String, dynamic> parsed = json.decode(raw) as Map<String, dynamic>;
    return LandingPageData.fromJson(parsed);
  }
}

class Intro {
  final String name;
  final String headline;
  final String summary;
  final List<DownloadItem> downloads;

  Intro({required this.name, required this.headline, required this.summary, required this.downloads});

  factory Intro.fromJson(Map<String, dynamic> json) {
    return Intro(
      name: json['name'] ?? '',
      headline: json['headline'] ?? '',
      summary: json['summary'] ?? '',
      downloads: (json['downloads'] as List<dynamic>? ?? [])
          .map((d) => DownloadItem.fromJson(Map<String, dynamic>.from(d)))
          .toList(),
    );
  }
}

class DownloadItem {
  final String label;
  final String url;
  final bool external;

  DownloadItem({required this.label, required this.url, required this.external});

  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      label: json['label'] ?? '',
      url: json['url'] ?? '',
      external: json['external'] == true,
    );
  }
}

class WorkItem {
  final String start;
  final String? end;
  final String title;
  final String company;
  final String? icon; // Path to company icon SVG
  final List<String> bullets;

  WorkItem({required this.start, this.end, required this.title, required this.company, this.icon, required this.bullets});

  factory WorkItem.fromJson(Map<String, dynamic> json) {
    return WorkItem(
      start: json['start'] ?? '',
      end: json['end'],
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      icon: json['icon'] as String?,
      bullets: List<String>.from(json['bullets'] ?? []),
    );
  }
}

class EducationItem {
  final String start;
  final String? end;
  final String school;
  final String course;
  final String? gpa; // Final GPA from JSON (final_gpa)
  final String? icon; // Path to school icon SVG
  final List<ModuleGroup> modules;

  EducationItem({required this.start, this.end, required this.school, required this.course, this.gpa, this.icon, required this.modules});

  factory EducationItem.fromJson(Map<String, dynamic> json) {
    return EducationItem(
      start: json['start'] ?? '',
      end: json['end'],
      school: json['school'] ?? '',
      course: json['course'] ?? '',
      // Always read final GPA from `final_gpa`
      gpa: json['final_gpa'] as String?,
      icon: json['icon'] as String?,
      modules: (json['modules'] as List<dynamic>? ?? [])
          .map((m) => ModuleGroup.fromJson(Map<String, dynamic>.from(m)))
          .toList(),
    );
  }
}

class ModuleGroup {
  final String name;
  final List<String> items;

  ModuleGroup({required this.name, required this.items});

  factory ModuleGroup.fromJson(Map<String, dynamic> json) {
    return ModuleGroup(
      name: json['name'] ?? '',
      items: List<String>.from(json['items'] ?? []),
    );
  }
}

class Skills {
  final Map<String, SkillCategory> categories;

  Skills({required this.categories});

  factory Skills.fromJson(Map<String, dynamic> json) {
    final categories = <String, SkillCategory>{};
    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        categories[key] = SkillCategory.fromJson(value);
      } else if (value is List) {
        // Backward compatibility: plain list -> items with empty description.
        try {
          categories[key] = SkillCategory(
            description: '',
            relatedProjects: const [],
            items: List<String>.from(value),
          );
        } catch (_) {
          // ignore
        }
      }
    });
    return Skills(categories: categories);
  }
}

class SkillCategory {
  final String description;
  final List<String> items;
  final List<String> relatedProjects;

  SkillCategory({
    required this.description,
    required this.items,
    required this.relatedProjects,
  });

  factory SkillCategory.fromJson(Map<String, dynamic> json) {
    return SkillCategory(
      description: json['description'] ?? '',
      items: List<String>.from(json['items'] ?? []),
      relatedProjects: List<String>.from(json['related_projects'] ?? []),
    );
  }
}
