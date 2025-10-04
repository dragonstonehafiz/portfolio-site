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

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            descriptionTemplate.replaceFirst('{count}', '${projects.length}'),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Project cards
                          ...projects.map((project) => project.buildPreviewWidget(context)).toList(),
                        ],
                      ),
                    );
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