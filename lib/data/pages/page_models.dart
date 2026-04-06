/// A page that contains a title, description, and display options.
class ProjectPageData {
  final String pageName;
  final String description;
  final bool allProjects;

  ProjectPageData({
    required this.pageName,
    required this.description,
    this.allProjects = false,
  });

  factory ProjectPageData.fromJson(Map<String, dynamic> json) {
    return ProjectPageData(
      pageName: json['page_name'] ?? '',
      description: json['description'] ?? '',
      allProjects: json['all_projects'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'page_name': pageName,
    'description': description,
    'all_projects': allProjects,
  };
}
