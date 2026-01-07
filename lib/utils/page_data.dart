/// A generic page that contains a title, description and a list of project ids.
class ProjectPageData {
  final String pageName;
  final String description;
  final bool defaultListView;
  final bool dropdown;

  ProjectPageData({
    required this.pageName,
    required this.description,
    this.defaultListView = false,
    this.dropdown = false,
  });

  factory ProjectPageData.fromJson(Map<String, dynamic> json) {
    return ProjectPageData(
      pageName: json['page_name'] ?? '',
      description: json['description'] ?? '',
      defaultListView: json['default_list_view'] ?? false,
      dropdown: json['dropdown'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'page_name': pageName,
        'description': description,
        'default_list_view': defaultListView,
        'dropdown': dropdown,
      };
}
