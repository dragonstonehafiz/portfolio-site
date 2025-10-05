import 'package:flutter/rendering.dart';
import '../utils/project_data.dart';
import '../utils/page_collection.dart';
import '../utils/project_collection.dart';

class ProjectService {
  static List<ProjectData> getProjectsForPage(String pageName, {bool descending = true}) {

    final projectsList = <String>[];
    final pageCollection = PageCollection.instance;

    if (pageName == 'featured_projects') {
      projectsList.addAll(pageCollection.featuredPage.projects);
    } else {
      final page = pageCollection.findGenericPageByName(pageName);
      if (page != null) projectsList.addAll(page.projects);
    }

    final projectIds = projectsList;
    final projects = <ProjectData>[];
    final projectsCollection = ProjectsCollection.instance;

    for (final id in projectIds) {
      final project = projectsCollection.projects[id];
      if (project != null) {
        projects.add(project);
      } else {
        debugPrint('Project not found: $id');
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
    return ProjectsCollection.instance.projects[projectId];
  }

  // Get a specific project by slug (title-based). This iterates the loaded
  // projects and returns the first match for the slug.
  static ProjectData? getProjectBySlug(String slug) {
    final projectsCollection = ProjectsCollection.instance;
    for (final project in projectsCollection.projects.values) {
      if (project.slug == slug) return project;
    }
    return null;
  }

  static List<ProjectData> getAllProjects() {
    return ProjectsCollection.instance.projects.values.toList();
  }

  // Get projects by category
  static List<ProjectData> getProjectsByCategory(String category) {
    return ProjectsCollection.instance.projects.values
      .where((project) => project.category == category)
      .toList();
  }

  // Get projects by tag
  static List<ProjectData> getProjectsByTag(String tag) {
    return ProjectsCollection.instance.projects.values
      .where((project) => project.tags.contains(tag))
      .toList();
  }

  // Get all available tags
  static Set<String> getAllTags() {
    final allTags = <String>{};
    final projects = ProjectsCollection.instance.projects.values;
    for (final project in projects) {
      allTags.addAll(project.tags);
    }
    return allTags;
  }

  // Get all available categories
  static Set<String> getAllCategories() {
    final categories = <String>{};
    final projects = ProjectsCollection.instance.projects.values;
    for (final project in projects) {
      categories.add(project.category);
    }
    return categories;
  }

  // Search projects by title or description
  static List<ProjectData> searchProjects(String query) {
    if (query.isEmpty) {
      return getAllProjects();
    }
    
    final lowercaseQuery = query.toLowerCase();
    return ProjectsCollection.instance.projects.values
      .where((project) =>
        project.title.toLowerCase().contains(lowercaseQuery) ||
        (project.description?.toLowerCase().contains(lowercaseQuery) ?? false))
      .toList();
  }

  // Get available page configurations
  static Map<String, String> getAvailablePages() {
    final pageCollection = PageCollection.instance;

    final pages = <String, String>{};
    // Featured block is a special key
    pages['featured_projects'] = pageCollection.featuredPage.description;
    for (final p in pageCollection.genericPages) {
      pages[p.pageName] = p.description;
    }
    return pages;
  }
}