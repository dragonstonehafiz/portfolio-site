import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'project_data.dart' show ProjectEntry;

class ProjectsCollection {
  final Map<String, ProjectEntry> projects;
  static ProjectsCollection? _instance;

  ProjectsCollection._({required this.projects});

  factory ProjectsCollection._fromJson(Map<String, dynamic> json) {
    final map = <String, ProjectEntry>{};
    for (final entry in json.entries) {
      final key = entry.key;
      final raw = Map<String, dynamic>.from(entry.value as Map);
      map[key] = ProjectEntry.fromJson(key, raw);
    }
    return ProjectsCollection._(projects: map);
  }

  static ProjectsCollection _fromRawJson(String str) => ProjectsCollection._fromJson(json.decode(str));

  static ProjectsCollection get instance {
    return _instance ??= ProjectsCollection._(projects: {});
  }

  /// Initialize the singleton with JSON data from assets.
  static Future<void> initializeFromAssets() async {
    if (_instance != null) return; // Already initialized
    
    try {
      final String projectsJson = await rootBundle.loadString('assets/projects.json');
      _instance = ProjectsCollection._fromRawJson(projectsJson);
    } catch (e) {
      // Fallback to empty collection if loading fails
      _instance = ProjectsCollection._(projects: {});
    }
  }

  /// Check if the singleton is initialized
  static bool get isInitialized => _instance != null;

  /// Reset singleton for testing purposes
  static void resetForTesting() {
    _instance = null;
  }
}
