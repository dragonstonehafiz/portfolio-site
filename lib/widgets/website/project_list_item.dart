import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../projects/project_data.dart';
import '../../utils/theme.dart';
import '../../utils/responsive_web_utils.dart';
import '../hover_card_widget.dart';
import '../animated_gradient.dart';
import 'project_thumbnail_preview.dart';

/// A list item widget for displaying project information in list view.
/// Extracts rendering logic from ProjectData to follow separation of concerns.
class ProjectListItem extends StatelessWidget {
  final ProjectData project;

  const ProjectListItem({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWebUtils.isMobile(context);
    final horizontalGap = isMobile ? 8.0 : 12.0;
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ) ??
        TextStyle(
          fontSize: isMobile ? 16 : 18,
          fontWeight: FontWeight.w600,
        );

    Widget? projectTypeBadge;
    if (project.projectType.isNotEmpty) {
      projectTypeBadge = Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 10,
          vertical: isMobile ? 4 : 5,
        ),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          project.projectType,
          style: TextStyle(
            fontSize: isMobile ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
          ),
        ),
      );
    }

    final linkColor = IconTheme.of(context).color ?? AppColors.primary;

    Widget buildLinkButton({
      required IconData icon,
      required String tooltip,
      required String url,
    }) {
      return Tooltip(
        message: tooltip,
        child: IconButton(
          icon: Icon(icon, size: 20),
          color: linkColor,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          splashRadius: 18,
          onPressed: () => _openLink(url),
        ),
      );
    }

    final linkButtons = <Widget>[];
    if (project.githubLink != null && project.githubLink!.isNotEmpty) {
      linkButtons.add(buildLinkButton(
        icon: Icons.code,
        tooltip: 'Open GitHub',
        url: project.githubLink!,
      ));
    }
    if (project.vidLink != null && project.vidLink!.isNotEmpty) {
      linkButtons.add(buildLinkButton(
        icon: Icons.play_circle_outline,
        tooltip: 'Watch video',
        url: project.vidLink!,
      ));
    }
    final hasDownloads = project.downloadPaths.isNotEmpty;
    final hasLastUpdate = project.lastUpdate != null && project.lastUpdate!.trim().isNotEmpty;
    final displayDate = hasLastUpdate ? project.lastUpdate!.trim() : project.date.trim();
    final dateLabel = hasLastUpdate ? 'Last updated on' : 'Released on';

    return HoverCardWidget(
      onTap: () {
        Navigator.pushNamed(context, '/projects/${project.slug}');
      },
      child: AnimatedGradient(
        gradient: Theme.of(context).previewGradient,
        borderRadius: BorderRadius.circular(10),
        duration: const Duration(seconds: 6),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 10 : 12,
          ),
          child: Row(
            children: [
              // Small thumbnail preview on the left
              ProjectThumbnailPreview(
                imgPaths: project.imgPaths.isNotEmpty ? project.imgPaths : null,
                videoLink: project.vidLink,
                width: isMobile ? 48.0 : 56.0,
                height: isMobile ? 48.0 : 56.0,
                borderRadius: BorderRadius.circular(6),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              // Main content (title, tags, links)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            project.title,
                            style: titleStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (projectTypeBadge != null) ...[
                          SizedBox(width: horizontalGap),
                          projectTypeBadge,
                        ],
                      ],
                    ),
                    if (project.tags.isNotEmpty || linkButtons.isNotEmpty || hasDownloads) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (final tag in project.tags)
                            Chip(
                              label: Text(tag, style: const TextStyle(fontSize: 12)),
                              backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                              side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3)),
                            ),
                          if (linkButtons.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var i = 0; i < linkButtons.length; i++) ...[
                                  linkButtons[i],
                                  if (i != linkButtons.length - 1) SizedBox(width: horizontalGap / 2),
                                ],
                              ],
                            ),
                          if (hasDownloads)
                            _buildDownloadIndicator(
                              horizontalGap: horizontalGap,
                              color: linkColor,
                            ),
                        ],
                      ),
                    ],
                    if (displayDate.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildDatePill(
                        label: dateLabel,
                        value: displayDate,
                        isCompact: isMobile,
                        horizontalGap: horizontalGap,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePill({
    required String label,
    required String value,
    required bool isCompact,
    required double horizontalGap,
  }) {
    final fontSize = isCompact ? 12.0 : 13.0;
    final paddingH = isCompact ? 8.0 : 10.0;
    final paddingV = isCompact ? 4.0 : 5.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
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
          SizedBox(width: horizontalGap / 2),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadIndicator({
    required double horizontalGap,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.download_for_offline_outlined,
            size: 14,
            color: color,
          ),
        ],
      ),
    );
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
