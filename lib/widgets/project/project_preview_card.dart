import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/projects/project_data.dart';
import '../../core/theme.dart';
import '../../core/responsive_web_utils.dart';
import '../ui/hover_card.dart';
import '../ui/animated_gradient.dart';
import 'project_thumbnail_preview.dart';

/// A preview card widget for displaying project information in grid or list views.
/// Extracts rendering logic from ProjectData to follow separation of concerns.
class ProjectPreviewCard extends StatelessWidget {
  final ProjectData project;

  const ProjectPreviewCard({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: HoverCardWidget(
        onTap: () {
          Navigator.pushNamed(context, '/projects/${project.slug}');
        },
        child: AnimatedGradient(
          gradient: Theme.of(context).previewGradient,
          borderRadius: BorderRadius.circular(12),
          duration: const Duration(seconds: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: DefaultTextStyle(
              style: const TextStyle(color: Color(0xFF0F1724)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and metadata
                  _buildTitleWidget(context),
                  const SizedBox(height: 8),
                  _buildMetaRow(context),

                  // Vignette preview
                  if (project.vignette.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildVignetteSection(context),
                  ],

                  // Tags
                  if (project.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildTagsWidget(),
                  ],

                  // Media preview with proportional sizing based on screen size
                  const SizedBox(height: 8),
                  _buildResponsiveMediaContainer(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            project.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildMetaRow(BuildContext context) {
    final hasDownloads = project.downloadPaths.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Project type
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                project.projectType,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Row 2: Links (video then github)
        if (project.vidLink != null || project.githubLink != null || hasDownloads)
          Row(
            children: [
              if (project.vidLink != null) ...[
                TextButton(
                  onPressed: () => _openLink(project.vidLink!),
                  child: const Text('Video Link', style: TextStyle(fontSize: 12)),
                ),
              ],

              if (project.vidLink != null && project.githubLink != null) 
                const SizedBox(width: 8),

              if (project.githubLink != null) ...[
                TextButton(
                  onPressed: () => _openLink(project.githubLink!),
                  child: const Text('GitHub Link', style: TextStyle(fontSize: 12)),
                ),
              ],

              if ((project.vidLink != null || project.githubLink != null) && hasDownloads)
                const SizedBox(width: 8),

              if (hasDownloads)
                _buildDownloadIndicator(),
            ],
          ),

        const SizedBox(height: 8),

        // Row 3: Dates
        Builder(
          builder: (context) {
            final hasLastUpdate = project.lastUpdate != null && 
                                 project.lastUpdate!.trim().isNotEmpty;
            final displayDate = hasLastUpdate 
                ? project.lastUpdate!.trim() 
                : project.date.trim();
            final dateLabel = hasLastUpdate ? 'Last updated on' : 'Released on';
            if (displayDate.isEmpty) return const SizedBox.shrink();
            return _buildDatePill(
              label: dateLabel,
              value: displayDate,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDatePill({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.blueGrey.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule,
            size: 14,
            color: Colors.blueGrey,
          ),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.download_for_offline_outlined,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          const Text(
            'Download Available',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVignetteSection(BuildContext context) {
    if (project.vignette.isEmpty) return const SizedBox.shrink();
    return Text(
      project.vignette,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 16,
        height: 1.6,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildTagsWidget() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: project.tags.take(3).map((tag) => Chip(
        label: Text(tag, style: const TextStyle(fontSize: 12)),
        backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
        side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3)),
      )).toList(),
    );
  }

  Widget _buildResponsiveMediaContainer(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = ResponsiveWebUtils.isMobile(context);
    
    final containerHeight = isMobile 
        ? screenSize.height * 0.15
        : (screenSize.height * 0.25).clamp(150.0, 250.0);
    
    final containerWidth = isMobile
        ? screenSize.width * 0.85
        : double.infinity;

    if (isMobile) {
      return Container(
        width: containerWidth,
        height: containerHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: ProjectThumbnailPreview(
            imgPaths: project.imgPaths.isNotEmpty ? project.imgPaths : null,
            videoLink: project.vidLink,
            width: containerWidth - 12,
            height: containerHeight - 12,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );
    } else {
      return Expanded(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: containerHeight,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: ProjectThumbnailPreview(
              imgPaths: project.imgPaths.isNotEmpty ? project.imgPaths : null,
              videoLink: project.vidLink,
              width: double.infinity,
              height: containerHeight - 12,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      );
    }
  }


  Future<void> _openLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error launching $url: $e');
    }
  }
}
