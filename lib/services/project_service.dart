import 'package:flutter/rendering.dart';
import '../utils/project_data.dart';
import '../utils/page_collection.dart';
import '../utils/project_collection.dart';

class ProjectService {
  static List<ProjectData> getProjectsForPage(String pageName, {bool descending = true}) {
    final projects = <ProjectData>[];
    final projectsCollection = ProjectsCollection.instance;
    for (final entry in projectsCollection.projects.values) {
      if (entry.pageList.contains(pageName)) {
        projects.add(entry.defaultVersion);
      }
    }
    
    // Sort projects by lastUpdate (or created date) with the requested order.
    projects.sort((a, b) {
      final da = _parseProjectDate(a.lastUpdate ?? a.date);
      final db = _parseProjectDate(b.lastUpdate ?? b.date);
      final cmp = db.compareTo(da); // cmp > 0 when b is newer than a
      return descending ? cmp : -cmp;
    });

    return projects;
  }

  // Helper: parse project date string robustly. Accepts ISO-like strings or
  // year-only values. If parsing fails, returns epoch (1970) to push unknown
  // dates to the end when sorting descending.
  static DateTime _parseProjectDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final trimmed = dateStr.trim();

    // Try standard ISO parse first
    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) return parsed;

  // Try year-only (e.g., "2024")
  final yearOnly = RegExp(r'^\d{4}\$');
    if (yearOnly.hasMatch(trimmed)) {
      try {
        final y = int.parse(trimmed);
        return DateTime(y);
      } catch (_) {
        // fall through
      }
    }

    // Try common "YYYY-MM" or other loose formats by adding day if missing
    final yearMonth = RegExp(r'^(\d{4})-(\d{1,2})\b');
    final m = yearMonth.firstMatch(trimmed);
    if (m != null) {
      try {
        final y = int.parse(m.group(1)!);
        final mo = int.parse(m.group(2)!);
        return DateTime(y, mo);
      } catch (_) {}
    }

    // As a last resort, return epoch so unknown dates sort last
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static ProjectData? getProjectById(String projectId) {
    return ProjectsCollection.instance.projects[projectId]?.defaultVersion;
  }

  // Get a specific project by slug (title-based). This iterates the loaded
  // projects and returns the first match for the slug.
  static ProjectData? getProjectBySlug(String slug) {
    return getProjectEntryBySlug(slug)?.defaultVersion;
  }

  static ProjectEntry? getProjectEntryById(String projectId) {
    return ProjectsCollection.instance.projects[projectId];
  }

  static ProjectEntry? getProjectEntryBySlug(String slug) {
    final projectsCollection = ProjectsCollection.instance;
    for (final project in projectsCollection.projects.values) {
      for (final version in project.versions) {
        if (version.slug == slug) return project;
      }
    }
    return null;
  }

  static List<ProjectData> getAllProjects() {
    return ProjectsCollection.instance.projects.values
        .map((entry) => entry.defaultVersion)
        .toList();
  }

  // Get projects by tag
  static List<ProjectData> getProjectsByTag(String tag) {
    return ProjectsCollection.instance.projects.values
      .map((entry) => entry.defaultVersion)
      .where((project) => project.tags.contains(tag))
      .toList();
  }

  // Get all available tags
  static Set<String> getAllTags() {
    final allTags = <String>{};
    final projects = ProjectsCollection.instance.projects.values
        .map((entry) => entry.defaultVersion);
    for (final project in projects) {
      allTags.addAll(project.tags);
    }
    return allTags;
  }

  // Search projects by title or description
  static List<ProjectData> searchProjects(String query) {
    if (query.isEmpty) {
      return getAllProjects();
    }
    
    final lowercaseQuery = query.toLowerCase();
    return ProjectsCollection.instance.projects.values
      .map((entry) => entry.defaultVersion)
      .where((project) =>
        project.title.toLowerCase().contains(lowercaseQuery) ||
        (project.description?.toLowerCase().contains(lowercaseQuery) ?? false))
      .toList();
  }

  // Get available page configurations
  static Map<String, String> getAvailablePages() {
    final pageCollection = PageCollection.instance;

    final pages = <String, String>{};
    for (final p in pageCollection.genericPages) {
      pages[p.pageName] = p.description;
    }
    return pages;
  }
}
