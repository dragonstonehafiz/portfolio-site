/// A page that contains a title, description, and display options.
class ProjectPageData {
  final String pageName;
  final String description;
  final bool defaultListView;
  final bool dropdown;
  final bool allProjects;

  ProjectPageData({
    required this.pageName,
    required this.description,
    this.defaultListView = false,
    this.dropdown = false,
    this.allProjects = false,
  });

  factory ProjectPageData.fromJson(Map<String, dynamic> json) {
    return ProjectPageData(
      pageName: json['page_name'] ?? '',
      description: json['description'] ?? '',
      defaultListView: json['default_list_view'] ?? false,
      dropdown: json['dropdown'] ?? false,
      allProjects: json['all_projects'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'page_name': pageName,
    'description': description,
    'default_list_view': defaultListView,
    'dropdown': dropdown,
    'all_projects': allProjects,
  };
}
