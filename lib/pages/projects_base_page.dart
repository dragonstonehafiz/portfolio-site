import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_footer.dart';
import '../widgets/search_bar_widget.dart';
import '../services/project_service.dart';
import '../utils/project_data.dart';
import '../utils/responsive_web_utils.dart';
import '../utils/theme.dart';

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
  // Search query
  String _searchQuery = '';
  // Layout toggle
  bool _showListView = false;

  @override
  void initState() {
    super.initState();
    // Load available tags for the dropdown, scoped to this page's projects
    final projectsForPage = ProjectService.getProjectsForPage(widget.configKey);
    final tags = <String>{};
    final projectTypes = <String>{};
    for (final project in projectsForPage) {
      tags.addAll(project.tags);
      if (project.projectType.isNotEmpty) {
        projectTypes.add(project.projectType);
      }
    }
    setState(() {
      _availableTags = tags.toList()..sort();
      _availableProjectTypes = projectTypes.toList()..sort();
    });
  }

  // Helper method to get appropriate cross axis count based on screen size
  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < ResponsiveWebUtils.mobileBreakpoint) {
      return 1; // Mobile: single column
    } else {
      return 2; // Desktop/Tablet: 2 columns
    }
  }

  // Helper method to get horizontal padding based on screen size
  EdgeInsets _getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < ResponsiveWebUtils.mobileBreakpoint) {
      // Mobile: minimal horizontal padding
      return const EdgeInsets.all(16.0);
    } else {
      // Desktop: add significant horizontal padding to prevent content from being too wide
      final horizontalPadding = (screenWidth * 0.1).clamp(32.0, 120.0);
      return EdgeInsets.fromLTRB(horizontalPadding, 32.0, horizontalPadding, 32.0);
    }
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
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(type),
              ),
            ),
          ),
        ],
        onChanged: (value) => setState(() => _selectedProjectType = value),
      ),
    );
  }

  Widget _buildListViewToggle({required bool isMobile}) {
    return Tooltip(
      message: _showListView ? 'Switch to grid view' : 'Switch to list view',
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        visualDensity: isMobile ? VisualDensity.compact : VisualDensity.standard,
        iconSize: isMobile ? 18 : 20,
        onPressed: () {
          setState(() {
            _showListView = !_showListView;
          });
        },
        icon: Icon(
          _showListView ? Icons.view_list : Icons.view_list_outlined,
          // Slightly emphasize active state
          color: _showListView ? Theme.of(context).colorScheme.primary : null,
        ),
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
  Widget _buildResponsiveLayout(BuildContext context, List<ProjectData> projects) {
    final padding = _getResponsivePadding(context);
    final crossAxisCount = _getCrossAxisCount(context);
    final isMobile = ResponsiveWebUtils.isMobile(context);
    return SingleChildScrollView(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isMobile),
            const SizedBox(height: 12),
            _buildSearchBar(context, isMobile),
            const SizedBox(height: 16),
            _buildDescription(context, projects.length, isMobile),
            const SizedBox(height: 20),
            _buildProjectsPreview(context, projects, crossAxisCount, isMobile),
          ],
        ),
      ),
    );
  }

  // Header (title + filter + sort). On mobile the filter and sort stack below the title
  Widget _buildHeader(BuildContext context, bool isMobile) {
    final titleWidget = Text(
      widget.title,
      style: TextStyle(
        fontSize: isMobile ? 26 : 32,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    );

    // Controls row: will be shown below the title for all sizes. On mobile
    // we force the two dropdowns to expand so the four controls fit on one line.
    Widget controlsRow;
    if (isMobile) {
      controlsRow = Row(
        children: [
          Expanded(child: _buildProjectTypeDropdown(isExpanded: true)),
          const SizedBox(width: 8),
          Expanded(child: _buildTagDropdown(isExpanded: true)),
          const SizedBox(width: 8),
          _buildSortButton(isMobile: true),
          const SizedBox(width: 4),
          _buildListViewToggle(isMobile: true),
        ],
      );
    } else {
      // On desktop/tablet spread the four controls across the entire row.
      // Make them part of the same flex so spacing between them is balanced.
      controlsRow = Row(
        children: [
          Expanded(child: _buildProjectTypeDropdown()),
          const SizedBox(width: 8),
          Expanded(child: _buildTagDropdown()),
          const SizedBox(width: 8),
          _buildSortButton(isMobile: false),
          _buildListViewToggle(isMobile: false),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleWidget,
        const SizedBox(height: 8),
        controlsRow,
      ],
    );
  }

  // Description row
  Widget _buildDescription(BuildContext context, int count, bool isMobile) {
    return Text(
      ((widget.description ?? '')).replaceFirst('{count}', '$count'),
      style: TextStyle(
        fontSize: isMobile ? 14 : 18,
        color: Colors.grey,
      ),
    );
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
  Widget _buildProjectsPreview(BuildContext context, List<ProjectData> projects, int crossAxisCount, bool isMobile) {
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.emptyStateIcon,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${widget.title.toLowerCase()} found',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_showListView) {
      return Column(
        children: projects
            .map(
              (project) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: project.buildListItemWidget(context),
              ),
            )
            .toList(),
      );
    }

    if (crossAxisCount == 1) {
      return Column(
        children: projects
            .map((project) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: project.buildPreviewWidget(context),
                ))
            .toList(),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isMobile ? 0.8 : 0.9,
      children: projects.map((project) => project.buildPreviewWidget(context)).toList(),
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
                var projects = ProjectService.getProjectsForPage(widget.configKey, descending: _descending);
                
                // Apply tag filter if selected
                if (_selectedTag != null && _selectedTag!.isNotEmpty) {
                  projects = projects.where((p) => p.tags.contains(_selectedTag)).toList();
                }
                // Apply project type filter if selected
                if (_selectedProjectType != null && _selectedProjectType!.isNotEmpty) {
                  projects = projects.where((p) => p.projectType == _selectedProjectType).toList();
                }
                // Apply search filter if query entered
                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  projects = projects.where((project) {
                    final titleMatch = project.title.toLowerCase().contains(query);
                    final descriptionMatch =
                        project.description?.toLowerCase().contains(query) ?? false;
                    final tagMatch = project.tags.any(
                      (tag) => tag.toLowerCase().contains(query),
                    );
                    return titleMatch || descriptionMatch || tagMatch;
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
