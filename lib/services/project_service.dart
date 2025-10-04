import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../utils/projects.dart';

class ProjectService {
  static Map<String, Project>? _allProjects;
  static Map<String, dynamic>? _pageConfig;

  // Initialize the service by loading JSON files
  static Future<void> initialize() async {
    if (_allProjects == null || _pageConfig == null) {
      await Future.wait([
        _loadProjects(),
        _loadPageConfig(),
      ]);
    }
  }

  // Load all projects from projects.json
  static Future<void> _loadProjects() async {
    try {
      final String projectsJson = await rootBundle.loadString('assets/projects.json');
      final Map<String, dynamic> projectsData = json.decode(projectsJson);
      
      _allProjects = {};
      for (final entry in projectsData.entries) {
        _allProjects![entry.key] = Project.fromJson(entry.key, entry.value);
      }
    } catch (e) {
      debugPrint('Error loading projects.json: $e');
      _allProjects = {};
    }
  }

  // Load page configuration from page_config.json
  static Future<void> _loadPageConfig() async {
    try {
      final String configJson = await rootBundle.loadString('assets/page_config.json');
      _pageConfig = json.decode(configJson);
    } catch (e) {
      debugPrint('Error loading page_config.json: $e');
      _pageConfig = {'page_configurations': {}};
    }
  }

  // Get projects for a specific page
  static Future<List<Project>> getProjectsForPage(String pageName) async {
    await initialize();
    
    final pageConfigs = _pageConfig?['page_configurations'] as Map<String, dynamic>?;
    if (pageConfigs == null) {
      return [];
    }
    
    final pageConfig = pageConfigs[pageName] as Map<String, dynamic>?;
    if (pageConfig == null) {
      debugPrint('Page configuration not found for: $pageName');
      return [];
    }
    
    final projectIds = List<String>.from(pageConfig['projects'] ?? []);
    final projects = <Project>[];
    
    for (final id in projectIds) {
      final project = _allProjects?[id];
      if (project != null) {
        projects.add(project);
      } else {
        debugPrint('Project not found: $id');
      }
    }
    
    return projects;
  }

  // Get a specific project by ID
  static Future<Project?> getProjectById(String projectId) async {
    await initialize();
    return _allProjects?[projectId];
  }

  // Get all projects
  static Future<List<Project>> getAllProjects() async {
    await initialize();
    return _allProjects?.values.toList() ?? [];
  }

  // Get projects by category
  static Future<List<Project>> getProjectsByCategory(String category) async {
    await initialize();
    return _allProjects?.values
        .where((project) => project.category == category)
        .toList() ?? [];
  }

  // Get projects by tag
  static Future<List<Project>> getProjectsByTag(String tag) async {
    await initialize();
    return _allProjects?.values
        .where((project) => project.tags.contains(tag))
        .toList() ?? [];
  }

  // Get all available tags
  static Future<Set<String>> getAllTags() async {
    await initialize();
    final allTags = <String>{};
    final projects = _allProjects?.values ?? <Project>[];
    for (final project in projects) {
      allTags.addAll(project.tags);
    }
    return allTags;
  }

  // Get all available categories
  static Future<Set<String>> getAllCategories() async {
    await initialize();
    final categories = <String>{};
    final projects = _allProjects?.values ?? <Project>[];
    for (final project in projects) {
      categories.add(project.category);
    }
    return categories;
  }

  // Search projects by title or description
  static Future<List<Project>> searchProjects(String query) async {
    await initialize();
    if (query.isEmpty) {
      return getAllProjects();
    }
    
    final lowercaseQuery = query.toLowerCase();
    return _allProjects?.values
        .where((project) => 
            project.title.toLowerCase().contains(lowercaseQuery) ||
            (project.description?.toLowerCase().contains(lowercaseQuery) ?? false)
        )
        .toList() ?? [];
  }

  // Get available page configurations
  static Future<Map<String, String>> getAvailablePages() async {
    await initialize();
    
    final pageConfigs = _pageConfig?['page_configurations'] as Map<String, dynamic>?;
    if (pageConfigs == null) {
      return {};
    }
    
    final pages = <String, String>{};
    for (final entry in pageConfigs.entries) {
      final config = entry.value as Map<String, dynamic>;
      pages[entry.key] = config['description'] ?? entry.key;
    }
    
    return pages;
  }
}