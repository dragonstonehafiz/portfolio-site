import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_footer.dart';
import '../services/project_service.dart';
import '../utils/projects.dart';

class ProjectsBasePage extends StatefulWidget {
  final String configKey;
  final String title;
  final String descriptionTemplate;
  final IconData emptyStateIcon;

  const ProjectsBasePage({
    super.key,
    required this.configKey,
    required this.title,
    required this.descriptionTemplate,
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

  @override
  void initState() {
    super.initState();
    // Load available tags for the dropdown
    ProjectService.getAllTags().then((tags) {
      setState(() {
        _availableTags = tags.toList()..sort();
      });
    });
  }

  // Helper method to determine if we're on a mobile device
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  // Helper method to get appropriate cross axis count based on screen size
  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 768) {
      return 1; // Mobile: single column
    } else {
      return 2; // Desktop/Tablet: 2 columns
    }
  }

  // Helper method to get horizontal padding based on screen size
  EdgeInsets _getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 768) {
      // Mobile: minimal horizontal padding
      return const EdgeInsets.all(16.0);
    } else {
      // Desktop: add significant horizontal padding to prevent content from being too wide
      final horizontalPadding = (screenWidth * 0.1).clamp(32.0, 120.0);
      return EdgeInsets.fromLTRB(horizontalPadding, 32.0, horizontalPadding, 32.0);
    }
  }

  // Build responsive layout for projects
  Widget _buildResponsiveLayout(BuildContext context, List<Project> projects) {
    final padding = _getResponsivePadding(context);
    final crossAxisCount = _getCrossAxisCount(context);
    final isMobile = _isMobile(context);

    return SingleChildScrollView(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with tag filter and sort toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: isMobile ? 36 : 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tag filter dropdown
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
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
                              child: Text('All'),
                            ),
                          ),
                          ..._availableTags.map((t) => DropdownMenuItem<String?>(
                                value: t,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: Text(t),
                                ),
                              ))
                              .toList(),
                        ],
                        onChanged: (v) => setState(() => _selectedTag = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                  tooltip: _descending ? 'Sort: Newest first' : 'Sort: Oldest first',
                  onPressed: () {
                    setState(() {
                      _descending = !_descending;
                    });
                  },
                  icon: Icon(_descending ? Icons.arrow_downward : Icons.arrow_upward),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              widget.descriptionTemplate.replaceFirst('{count}', '${projects.length}'),
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Projects grid
            if (crossAxisCount == 1)
              // Mobile: Use Column for single column layout
              Column(
                children: projects
                    .map((project) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: project.buildPreviewWidget(context),
                        ))
                    .toList(),
              )
            else
              // Desktop/Tablet: Use GridView for multi-column layout
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 0.8 : 0.9, // Adjusted for responsive media containers
                children: projects
                    .map((project) => project.buildPreviewWidget(context))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Builder(
              builder: (context) {
                final Future<List<Project>> projectsFuture = ProjectService.getProjectsForPage(widget.configKey, descending: _descending);
                return FutureBuilder<List<Project>>(
                  future: projectsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading ${widget.title.toLowerCase()}: ${snapshot.error}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    var projects = snapshot.data ?? [];
                    // Apply tag filter if selected
                    if (_selectedTag != null && _selectedTag!.isNotEmpty) {
                      projects = projects.where((p) => p.tags.contains(_selectedTag)).toList();
                    }

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

                    return _buildResponsiveLayout(context, projects);
                  },
                );
              },
            ),
          ),
          const CustomFooter(),
        ],
      ),
    );
  }
}