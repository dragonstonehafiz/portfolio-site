import 'package:flutter/material.dart';
import '../core/routes.dart';
import '../widgets/ui/custom_app_bar.dart';
import '../widgets/ui/custom_footer.dart';
import '../widgets/generic/search_bar.dart';
import '../widgets/generic/app_breadcrumb.dart';
import '../widgets/project/project_list_item.dart';
import '../data/projects/project_service.dart';
import '../data/projects/project_data.dart';
import '../core/responsive_web_utils.dart';
import '../core/theme.dart';

class ProjectsBasePage extends StatefulWidget {
  final String configKey;
  final String title;
  final String? description;
  final IconData emptyStateIcon;

  const ProjectsBasePage({
    super.key,
    required this.configKey,
    required this.title,
    this.description,
    this.emptyStateIcon = Icons.folder_outlined,
  });

  @override
  State<ProjectsBasePage> createState() => _ProjectsBasePageState();
}

class _ProjectsBasePageState extends State<ProjectsBasePage> {
  // Sort order: default to descending (newest first)
  bool _descending = true;
  // Tag filter
  String? _selectedTag;
  List<String> _availableTags = [];
  // Project type filter
  String? _selectedProjectType;
  List<String> _availableProjectTypes = [];
  // Tool filter
  String? _selectedTool;
  List<String> _availableTools = [];
  // Search query
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Load available tags for the dropdown, scoped to this page's projects
    final projectsForPage = ProjectService.getProjectsForPage(widget.configKey);
    final tags = <String>{};
    final projectTypes = <String>{};
    final tools = <String>{};
    for (final project in projectsForPage) {
      tags.addAll(project.tags);
      if (project.projectType.isNotEmpty) {
        projectTypes.add(project.projectType);
      }
      tools.addAll(project.tools);
    }
    setState(() {
      _availableTags = tags.toList()..sort();
      _availableProjectTypes = projectTypes.toList()..sort();
      _availableTools = tools.toList()..sort();
    });
  }

  Widget _buildTagDropdown({bool isExpanded = false}) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String?>(
        isExpanded: isExpanded,
        value: _selectedTag,
        hint: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text('All tags'),
        ),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text('All tags'),
            ),
          ),
          ..._availableTags.map(
            (t) => DropdownMenuItem<String?>(
              value: t,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Text(t),
              ),
            ),
          ),
        ],
        onChanged: (value) => setState(() => _selectedTag = value),
      ),
    );
  }

  Widget _buildProjectTypeDropdown({bool isExpanded = false}) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String?>(
        isExpanded: isExpanded,
        value: _selectedProjectType,
        hint: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text('All project types'),
        ),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text('All project types'),
            ),
          ),
          ..._availableProjectTypes.map(
            (type) => DropdownMenuItem<String?>(
              value: type,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Text(type),
              ),
            ),
          ),
        ],
        onChanged: (value) => setState(() => _selectedProjectType = value),
      ),
    );
  }

  Widget _buildToolDropdown({bool isExpanded = false}) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String?>(
        isExpanded: isExpanded,
        value: _selectedTool,
        hint: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text('All tools'),
        ),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text('All tools'),
            ),
          ),
          ..._availableTools.map(
            (tool) => DropdownMenuItem<String?>(
              value: tool,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Text(tool),
              ),
            ),
          ),
        ],
        onChanged: (value) => setState(() => _selectedTool = value),
      ),
    );
  }

  Widget _buildSortButton({required bool isMobile}) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      iconSize: isMobile ? 20 : 22,
      tooltip: _descending ? 'Sort: Newest first' : 'Sort: Oldest first',
      onPressed: () {
        setState(() {
          _descending = !_descending;
        });
      },
      icon: Icon(_descending ? Icons.arrow_downward : Icons.arrow_upward),
    );
  }

  // Build responsive layout for projects
  Widget _buildResponsiveLayout(
    BuildContext context,
    List<ProjectData> projects,
  ) {
    final padding = ResponsiveWebUtils.getResponsivePadding(context);
    final isMobile = ResponsiveWebUtils.isMobile(context);
    return SingleChildScrollView(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBreadcrumb(context),
            const SizedBox(height: 10),
            _buildHeader(context, isMobile),
            const SizedBox(height: 12),
            _buildSearchBar(context, isMobile),
            const SizedBox(height: 20),
            _buildProjectsPreview(context, projects),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context) {
    return AppBreadcrumb(
      items: [
        BreadcrumbItem(
          label: 'Projects',
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.projectSummaryPath,
              (r) => false,
            );
          },
        ),
        BreadcrumbItem(label: widget.title),
      ],
    );
  }

  // Header (title + filter + sort). On mobile the filter and sort stack below the title
  Widget _buildHeader(BuildContext context, bool isMobile) {
    // Controls row: will be shown below the title for all sizes. On mobile
    // we force the dropdowns to expand so the controls fit on two lines.
    Widget controlsRow;
    if (isMobile) {
      controlsRow = Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildProjectTypeDropdown(isExpanded: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildTagDropdown(isExpanded: true)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildToolDropdown(isExpanded: true)),
              const SizedBox(width: 8),
              _buildSortButton(isMobile: true),
            ],
          ),
        ],
      );
    } else {
      // On desktop/tablet spread the controls across the entire row.
      controlsRow = Row(
        children: [
          Expanded(child: _buildProjectTypeDropdown()),
          const SizedBox(width: 8),
          Expanded(child: _buildTagDropdown()),
          const SizedBox(width: 8),
          Expanded(child: _buildToolDropdown()),
          const SizedBox(width: 8),
          _buildSortButton(isMobile: false),
        ],
      );
    }

    return controlsRow;
  }

  Widget _buildSearchBar(BuildContext context, bool isMobile) {
    // Use the frosted glass search bar widget for a nicer look on web
    return SizedBox(
      width: double.infinity,
      child: SearchBarWidget(
        hintText: 'Search projects...',
        onChanged: (value) => setState(() => _searchQuery = value.trim()),
      ),
    );
  }

  // Projects preview section
  Widget _buildProjectsPreview(
    BuildContext context,
    List<ProjectData> projects,
  ) {
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.emptyStateIcon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No ${widget.title.toLowerCase()} found',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: projects
          .map(
            (project) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ProjectListItem(project: project),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Builder(
              builder: (context) {
                var projects = ProjectService.getProjectsForPage(
                  widget.configKey,
                  descending: _descending,
                );

                // Apply tag filter if selected
                if (_selectedTag != null && _selectedTag!.isNotEmpty) {
                  projects = projects
                      .where((p) => p.tags.contains(_selectedTag))
                      .toList();
                }
                // Apply project type filter if selected
                if (_selectedProjectType != null &&
                    _selectedProjectType!.isNotEmpty) {
                  projects = projects
                      .where((p) => p.projectType == _selectedProjectType)
                      .toList();
                }
                // Apply tool filter if selected
                if (_selectedTool != null && _selectedTool!.isNotEmpty) {
                  projects = projects
                      .where((p) => p.tools.contains(_selectedTool))
                      .toList();
                }
                // Apply search filter if query entered
                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  projects = projects.where((project) {
                    final titleMatch = project.title.toLowerCase().contains(
                      query,
                    );
                    final descriptionMatch =
                        project.description?.toLowerCase().contains(query) ??
                        false;
                    final tagMatch = project.tags.any(
                      (tag) => tag.toLowerCase().contains(query),
                    );
                    final toolMatch = project.tools.any(
                      (tool) => tool.toLowerCase().contains(query),
                    );
                    return titleMatch ||
                        descriptionMatch ||
                        tagMatch ||
                        toolMatch;
                  }).toList();
                }

                // Always render the responsive layout (header + description + content).
                // The layout will show an empty state where the projects grid would be
                // if `projects` is empty, so the filters and sorter remain visible.
                return _buildResponsiveLayout(context, projects);
              },
            ),
          ),
          const CustomFooter(),
        ],
      ),
    );
  }
}
