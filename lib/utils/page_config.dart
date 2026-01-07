/// A generic page that contains a title, description and a list of project ids.
class ProjectPageData {
  final String pageName;
  final String description;
  final bool dropdown;

  ProjectPageData({
    required this.pageName,
    required this.description,
    this.dropdown = false,
  });

  factory ProjectPageData.fromJson(Map<String, dynamic> json) {
    return ProjectPageData(
      pageName: json['page_name'] ?? '',
      description: json['description'] ?? '',
      dropdown: json['dropdown'] ?? false,
    );
  }
}

/// PageCollection is a single container representing both the featured
/// project pages.
class PageCollection {
  final List<ProjectPageData> projectPages;

  PageCollection({required this.projectPages});

  factory PageCollection.fromJson(Map<String, dynamic> json) {
    final pagesRaw = json['project_pages'] as List<dynamic>? ?? [];
    final pages = pagesRaw.map((e) => ProjectPageData.fromJson(Map<String, dynamic>.from(e))).toList();

    return PageCollection(projectPages: pages);
  }

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
