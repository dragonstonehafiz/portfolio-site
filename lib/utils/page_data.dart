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

  Map<String, dynamic> toJson() => {
        'description': description,
        'projects': projects,
      };
}

/// A generic page that contains a title, description and a list of project ids.
class ProjectPageData {
  final String pageName;
  final String description;
  final List<String> projects;
  final bool defaultListView;

  ProjectPageData({
    required this.pageName,
    required this.description,
    required this.projects,
    this.defaultListView = false,
  });

  factory ProjectPageData.fromJson(Map<String, dynamic> json) {
    return ProjectPageData(
      pageName: json['page_name'] ?? '',
      description: json['description'] ?? '',
      projects: List<String>.from(json['projects'] ?? []),
      defaultListView: json['default_list_view'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'page_name': pageName,
        'description': description,
        'projects': projects,
        'default_list_view': defaultListView,
      };
}
