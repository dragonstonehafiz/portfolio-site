import 'package:flutter/material.dart';
import '../core/responsive_web_utils.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../data/pages/page_collection.dart';
import '../data/projects/project_data.dart';
import '../data/projects/project_service.dart';
import '../widgets/generic/project_horizontal_carousel.dart';
import '../widgets/generic/tool_badge_list.dart';
import '../widgets/ui/custom_app_bar.dart';
import '../widgets/ui/custom_footer.dart';

class ProjectSummaryPage extends StatelessWidget {
  const ProjectSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = PageCollection.instance.genericPages;

    return GradientScaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: ResponsiveWebUtils.getResponsivePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    ...pages.map((page) {
                      final projects = ProjectService.getProjectsForPage(page.pageName);
                      return _ProjectSummarySection(
                        pageName: page.pageName,
                        description: page.description,
                        projects: projects,
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
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

class _ProjectSummarySection extends StatelessWidget {
  final String pageName;
  final String description;
  final List<ProjectData> projects;

  const _ProjectSummarySection({
    required this.pageName,
    required this.description,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWebUtils.isMobile(context);
    final cardWidth = isMobile ? 280.0 : 340.0;
    final carouselHeight = isMobile ? 235.0 : 255.0;
    final pageTools = _collectTools(projects);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pageName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Text(
                '${projects.length} project${projects.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(width: 14),
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.pagePath(AppRoutes.slugForPageName(pageName)),
                    (r) => false,
                  );
                },
                child: const Text(
                  'View all ->',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description.replaceFirst('{count}', '${projects.length}'),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          if (pageTools.isNotEmpty) ...[
            const SizedBox(height: 10),
            ToolBadgeList(
              tools: pageTools,
              showIcons: true,
              fontSize: 12,
              spacing: 8,
              runSpacing: 8,
            ),
          ],
          const SizedBox(height: 12),
          if (projects.isEmpty)
            const SizedBox(
              height: 70,
              child: Center(
                child: Text(
                  'No projects to show',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            SizedBox(
              height: carouselHeight,
              child: SelectionContainer.disabled(
                child: ProjectHorizontalCarousel(
                  projects: projects,
                  cardWidth: cardWidth,
                ),
              ),
            ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Colors.black12),
        ],
      ),
    );
  }

  List<String> _collectTools(List<ProjectData> projects) {
    final seen = <String>{};
    final ordered = <String>[];
    for (final project in projects) {
      for (final tool in project.tools) {
        if (seen.add(tool)) {
          ordered.add(tool);
        }
      }
    }
    return ordered;
  }
}
