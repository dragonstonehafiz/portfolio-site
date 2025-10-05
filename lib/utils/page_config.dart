/// Represents the featured projects block from `page_config.json`.
class FeaturedProjectsData {
  final String description;
  final List<String> projects;

  FeaturedProjectsData({required this.description, required this.projects});

  factory FeaturedProjectsData.fromJson(Map<String, dynamic> json) {
    return FeaturedProjectsData(
      description: json['description'] ?? '',
      projects: List<String>.from(json['projects'] ?? []),
    );
  }
}

/// A generic page that contains a title, description and a list of project ids.
class ProjectPageData {
  final String pageName;
  final String description;
  final List<String> projects;

  ProjectPageData({required this.pageName, required this.description, required this.projects});

  factory ProjectPageData.fromJson(Map<String, dynamic> json) {
    return ProjectPageData(
      pageName: json['page_name'] ?? '',
      description: json['description'] ?? '',
      projects: List<String>.from(json['projects'] ?? []),
    );
  }
}

/// PageCollection is a single container representing both the featured
/// projects block and the other project pages. The `featured_projects` block
/// is exposed as a `ProjectPage` via `featuredAsPage` so callers can treat all
/// pages uniformly.
class PageCollection {
  final FeaturedProjectsData featuredProjects;
  final List<ProjectPageData> projectPages;

  PageCollection({required this.featuredProjects, required this.projectPages});

  factory PageCollection.fromJson(Map<String, dynamic> json) {
    final featured = FeaturedProjectsData.fromJson(json['featured_projects'] ?? {});

    final pagesRaw = json['project_pages'] as List<dynamic>? ?? [];
    final pages = pagesRaw.map((e) => ProjectPageData.fromJson(Map<String, dynamic>.from(e))).toList();

    return PageCollection(featuredProjects: featured, projectPages: pages);
  }

  /// Access the featured projects block. This is a distinct structure from the
  /// generic project pages and should be handled separately by the UI.
  FeaturedProjectsData get featuredPage => featuredProjects;

  /// Access the list of generic project pages (does not include the featured
  /// projects block).
  List<ProjectPageData> get genericPages => projectPages;

  /// Find a generic page by its `page_name` (case-insensitive). This searches
  /// only `genericPages` and does not consider the featured projects block.
  ProjectPageData? findGenericPageByName(String name) {
    final lname = name.toLowerCase();
    for (final p in genericPages) {
      if (p.pageName.toLowerCase() == lname) return p;
    }
    return null;
  }
}
