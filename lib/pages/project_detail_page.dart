import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_footer.dart';
import '../projects/project_service.dart';
import '../projects/project_data.dart';
import '../utils/theme.dart';
import '../widgets/shared_tabs.dart';
import '../widgets/website/project_full_detail_card.dart';

class ProjectDetailPage extends StatelessWidget {
  final String slug;
  const ProjectDetailPage({required this.slug, super.key});

  @override
  Widget build(BuildContext context) {
    final entry = ProjectService.getProjectEntryBySlug(slug);

    if (entry == null) {
      return GradientScaffold(
        appBar: const CustomAppBar(),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Project not found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('The requested project could not be found.'),
                  ],
                ),
              ),
            ),
            const CustomFooter(),
          ],
        ),
      );
    }

    final versions = entry.versions;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 1000 ? 1000.0 : screenWidth * 0.9;

    return GradientScaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Expanded(
            child: DefaultTabController(
              length: versions.length,
              initialIndex: entry.defaultVersionIndex.clamp(0, versions.length - 1),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: Theme.of(context).previewGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: SelectionArea(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Builder(
                            builder: (context) {
                              final controller = DefaultTabController.of(context)!;
                              final animation = controller.animation ?? controller;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: const Icon(Icons.arrow_back, color: Colors.blueGrey),
                                      ),
                                      const Text(
                                        'Back to Projects',
                                        style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  _VersionTabBar(versions: versions),
                                  const SizedBox(height: 16),
                                  AnimatedBuilder(
                                    animation: animation,
                                    builder: (context, _) {
                                      final version = versions[controller.index];
                                      return Center(
                                        child: Text(
                                          version.title,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AnimatedBuilder(
                                    animation: animation,
                                    builder: (context, _) {
                                      final version = versions[controller.index];
                                      return ProjectFullDetailCard(project: version);
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const CustomFooter(),
        ],
      ),
    );
  }
}

class _VersionTabBar extends StatelessWidget {
  final List<ProjectData> versions;

  const _VersionTabBar({required this.versions});

  @override
  Widget build(BuildContext context) {
    return SharedTabs(
      labels: versions.map((v) => v.version).toList(),
    );
  }
}
