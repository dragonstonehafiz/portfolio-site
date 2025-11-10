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
  final List<String> bullets;

  WorkItem({required this.start, this.end, required this.title, required this.company, required this.bullets});

  factory WorkItem.fromJson(Map<String, dynamic> json) {
    return WorkItem(
      start: json['start'] ?? '',
      end: json['end'],
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      bullets: List<String>.from(json['bullets'] ?? []),
    );
  }
}

class EducationItem {
  final String start;
  final String? end;
  final String school;
  final String course;
  final List<ModuleGroup> modules;

  EducationItem({required this.start, this.end, required this.school, required this.course, required this.modules});

  factory EducationItem.fromJson(Map<String, dynamic> json) {
    return EducationItem(
      start: json['start'] ?? '',
      end: json['end'],
      school: json['school'] ?? '',
      course: json['course'] ?? '',
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
  final Map<String, List<String>> dynamicSkills;

  Skills({required this.dynamicSkills,});

  factory Skills.fromJson(Map<String, dynamic> json) {
    // Extract dynamic skills (any string keys with List<String> values)
    final dynamicSkills = <String, List<String>>{};
    json.forEach((key, value) {
      // Handle dynamic skill categories
      if (value is List) {
        try {
          dynamicSkills[key] = List<String>.from(value);
        } catch (_) {
          // Skip if not a list of strings
        }
      }
    });
    
    return Skills(
      dynamicSkills: dynamicSkills,
    );
  }
}
