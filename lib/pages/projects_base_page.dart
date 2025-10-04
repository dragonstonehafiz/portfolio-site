import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_footer.dart';
import '../services/project_service.dart';
import '../utils/projects.dart';

class ProjectsBasePage extends StatelessWidget {
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
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 36 : 48,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 16),
            
            // Description
            Text(
              descriptionTemplate.replaceFirst('{count}', '${projects.length}'),
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
                final Future<List<Project>> projectsFuture = 
                    ProjectService.getProjectsForPage(configKey);
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
                              'Error loading ${title.toLowerCase()}: ${snapshot.error}',
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

                    final projects = snapshot.data ?? [];

                    if (projects.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              emptyStateIcon,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No ${title.toLowerCase()} found',
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