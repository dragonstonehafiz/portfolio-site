import 'package:flutter/material.dart';

import '../core/responsive_web_utils.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../data/projects/project_data.dart';
import '../data/projects/project_service.dart';
import '../widgets/generic/shared_tabs.dart';
import '../widgets/generic/app_breadcrumb.dart';
import '../widgets/project/project_full_detail_card.dart';
import '../widgets/ui/custom_app_bar.dart';
import '../widgets/ui/custom_footer.dart';

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
                    Text(
                      'Project not found',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
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
    return GradientScaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Expanded(
            child: DefaultTabController(
              length: versions.length,
              initialIndex: entry.defaultVersionIndex.clamp(0, versions.length - 1),
              child: SingleChildScrollView(
                padding: ResponsiveWebUtils.getResponsivePadding(context),
                child: SelectionArea(
                  child: Builder(
                    builder: (context) {
                      final controller = DefaultTabController.of(context);
                      final animation = controller.animation ?? controller;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedBuilder(
                            animation: animation,
                            builder: (context, _) {
                              final version = versions[controller.index];
                              final isMobile = ResponsiveWebUtils.isMobile(context);
                              final sectionName =
                                  entry.pageList.isNotEmpty
                                  ? entry.pageList.first
                                  : 'Projects';
                              final sectionPath = sectionName == 'Projects'
                                  ? AppRoutes.projectSummaryPath
                                  : AppRoutes.pagePath(
                                      AppRoutes.slugForPageName(sectionName),
                                    );

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppBreadcrumb(
                                    items: [
                                      BreadcrumbItem(
                                        label: 'Projects',
                                        onTap: () {
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            AppRoutes.projectSummaryPath,
                                            (route) => false,
                                          );
                                        },
                                      ),
                                      BreadcrumbItem(
                                        label: sectionName,
                                        onTap: () {
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            sectionPath,
                                            (route) => false,
                                          );
                                        },
                                      ),
                                      BreadcrumbItem(label: version.title),
                                    ],
                                  ),
                                  if (versions.length > 1) ...[
                                    const SizedBox(height: 16),
                                    _VersionTabBar(versions: versions),
                                  ],
                                  const SizedBox(height: 20),
                                  if (isMobile)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _LeftContentColumn(version: version),
                                        const SizedBox(height: 16),
                                        ProjectDetailMetaRail(project: version),
                                      ],
                                    )
                                  else
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 7,
                                          child: _LeftContentColumn(
                                            version: version,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          flex: 3,
                                          child: ProjectDetailMetaRail(
                                            project: version,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              );
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
          const CustomFooter(),
        ],
      ),
    );
  }
}

class _LeftDetailCard extends StatelessWidget {
  final ProjectData version;

  const _LeftDetailCard({required this.version});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWebUtils.isMobile(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: Theme.of(context).previewGradient,
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    version.title,
                    style: TextStyle(
                      fontSize: isMobile ? 26 : 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 12),
                  _ProjectTypePill(
                    projectType: version.projectType,
                    isMobile: false,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            ProjectDetailMetaHeader(project: version),
            const SizedBox(height: 20),
            ProjectFullDetailCard(project: version),
          ],
        ),
      ),
    );
  }
}

class _LeftContentColumn extends StatelessWidget {
  final ProjectData version;

  const _LeftContentColumn({required this.version});

  @override
  Widget build(BuildContext context) {
    final hasGallery = version.vidLink != null || version.imgPaths.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LeftDetailCard(version: version),
        if (hasGallery) ...[
          const SizedBox(height: 6),
          _LeftGalleryCard(version: version),
        ],
      ],
    );
  }
}

class _LeftGalleryCard extends StatelessWidget {
  final ProjectData version;

  const _LeftGalleryCard({required this.version});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: Theme.of(context).previewGradient,
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gallery',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),
            ProjectDetailGalleryContent(project: version),
          ],
        ),
      ),
    );
  }
}

class _ProjectTypePill extends StatelessWidget {
  final String projectType;
  final bool isMobile;

  const _ProjectTypePill({required this.projectType, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 12,
        vertical: isMobile ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        projectType,
        style: TextStyle(
          fontSize: isMobile ? 12 : 14,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _VersionTabBar extends StatelessWidget {
  final List<ProjectData> versions;

  const _VersionTabBar({required this.versions});

  @override
  Widget build(BuildContext context) {
    return SharedTabs(labels: versions.map((version) => version.version).toList());
  }
}
