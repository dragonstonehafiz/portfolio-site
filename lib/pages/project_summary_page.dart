import 'package:flutter/material.dart';

import '../core/responsive_web_utils.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../data/pages/page_collection.dart';
import '../data/projects/project_data.dart';
import '../data/projects/project_service.dart';
import '../widgets/generic/project_horizontal_carousel.dart';
import '../widgets/generic/tool_badge_compact.dart';
import '../widgets/generic/tool_badge_list.dart';
import '../widgets/ui/animated_gradient.dart';
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
                    ...pages.map((page) {
                      final projects = ProjectService.getProjectsForPage(
                        page.pageName,
                      );
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
    final isFeaturedSection = pageName.trim().toLowerCase() == 'featured';
    final cardWidth = isMobile ? 240.0 : 340.0;
    final carouselHeight = isMobile ? 220.0 : 260.0;
    final pageTools = _collectTools(projects);
    final uniqueVersionsCount = _countUniqueVersions(projects);
    final projectsLabel =
        '${projects.length} project${projects.length == 1 ? '' : 's'}';
    final versionsLabel =
        '$uniqueVersionsCount unique version${uniqueVersionsCount == 1 ? '' : 's'}';
    final sectionBorderColor = isFeaturedSection
        ? AppColors.featuredGold.withValues(alpha: 0.24)
        : Colors.black.withValues(alpha: 0.12);
    final titleColor = AppColors.textPrimary;
    final countColor = AppColors.textSecondary;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: isFeaturedSection
              ? [
                  BoxShadow(
                    color: AppColors.featuredGold.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: isFeaturedSection
              ? AnimatedGradient(
                  gradient: Theme.of(context).featuredSectionGradient,
                  borderRadius: BorderRadius.circular(18),
                  borderColor: sectionBorderColor,
                  duration: const Duration(seconds: 7),
                  child: _buildSectionContent(
                    context: context,
                    isMobile: isMobile,
                    titleColor: titleColor,
                    countColor: countColor,
                    projectsLabel: projectsLabel,
                    versionsLabel: versionsLabel,
                    pageTools: pageTools,
                    carouselHeight: carouselHeight,
                    cardWidth: cardWidth,
                    isFeaturedSection: isFeaturedSection,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: sectionBorderColor),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: _buildSectionContent(
                    context: context,
                    isMobile: isMobile,
                    titleColor: titleColor,
                    countColor: countColor,
                    projectsLabel: projectsLabel,
                    versionsLabel: versionsLabel,
                    pageTools: pageTools,
                    carouselHeight: carouselHeight,
                    cardWidth: cardWidth,
                    isFeaturedSection: isFeaturedSection,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionContent({
    required BuildContext context,
    required bool isMobile,
    required Color titleColor,
    required Color countColor,
    required String projectsLabel,
    required String versionsLabel,
    required List<String> pageTools,
    required double carouselHeight,
    required double cardWidth,
    required bool isFeaturedSection,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 14 : 18,
        isMobile ? 14 : 18,
        isMobile ? 14 : 18,
        isMobile ? 16 : 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            Text(
              pageName.toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: titleColor,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _buildCountItems(
                    projectsLabel: projectsLabel,
                    versionsLabel: versionsLabel,
                    textColor: countColor,
                  ),
                ),
                _buildViewAllButton(
                  context,
                  foregroundColor: null,
                ),
              ],
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: Text(
                    pageName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                _buildCountItems(
                  projectsLabel: projectsLabel,
                  versionsLabel: versionsLabel,
                  textColor: countColor,
                ),
                const SizedBox(width: 12),
                _buildViewAllButton(
                  context,
                  foregroundColor: null,
                ),
              ],
            ),
          const SizedBox(height: 8),
          Text(
            description.replaceFirst('{count}', '${projects.length}'),
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: isMobile ? 13 : 15,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (pageTools.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (isMobile)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pageTools
                    .map(
                      (tool) =>
                          ToolBadgeCompact(toolKey: tool, fontSize: 11),
                    )
                    .toList(),
              )
            else
              ToolBadgeList(
                tools: pageTools,
                showIcons: true,
                fontSize: 12,
                spacing: 8,
                runSpacing: 8,
              ),
          ],
          const SizedBox(height: 14),
          if (projects.isEmpty)
            const SizedBox(
              height: 80,
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
        ],
      ),
    );
  }

  Widget _buildViewAllButton(
    BuildContext context, {
    Color? foregroundColor,
  }) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.pagePath(AppRoutes.slugForPageName(pageName)),
          (r) => false,
        );
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: foregroundColor,
      ),
      child: const Text(
        'View all ->',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildCountItems({
    required String projectsLabel,
    required String versionsLabel,
    required Color textColor,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildCountItem(projectsLabel, textColor: textColor),
        _buildCountItem(versionsLabel, textColor: textColor),
      ],
    );
  }

  Widget _buildCountItem(String label, {required Color textColor}) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 0.4,
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

  int _countUniqueVersions(List<ProjectData> projects) {
    var versionCount = 0;
    for (final project in projects) {
      final entry = ProjectService.getProjectEntryBySlug(project.slug);
      versionCount += entry?.versions.length ?? 1;
    }
    return versionCount;
  }
}
