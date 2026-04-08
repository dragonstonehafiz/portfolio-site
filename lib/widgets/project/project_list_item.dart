import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/projects/project_data.dart';
import '../../core/theme.dart';
import '../../core/responsive_web_utils.dart';
import '../ui/hover_card.dart';
import '../ui/animated_gradient.dart';
import '../generic/tool_badge_list.dart';
import 'project_thumbnail_preview.dart';

/// A list item widget for displaying project information in list view.
class ProjectListItem extends StatelessWidget {
  final ProjectData project;
  static const LinearGradient _thumbnailWhiteGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF6F9FC)],
    stops: [0.0, 1.0],
  );

  const ProjectListItem({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWebUtils.isMobile(context);
    final horizontalPadding = isMobile ? 12.0 : 16.0;
    final verticalPadding = isMobile ? 12.0 : 14.0;
    final mediaWidth = isMobile ? double.infinity : 220.0;
    final mediaHeight = 180.0;
    final bulletItems = project.whatIDid.take(3).toList();
    final extraCount = project.whatIDid.length - bulletItems.length;
    final summaryText = project.vignette.trim().isNotEmpty
        ? project.vignette.trim()
        : (project.description ?? '').trim();
    final hasLastUpdate =
        project.lastUpdate != null && project.lastUpdate!.trim().isNotEmpty;
    final displayDate = hasLastUpdate
        ? project.lastUpdate!.trim()
        : project.date.trim();
    final downloadUrl = _firstDownloadUrl(project.downloadPaths);
    final linkColor = IconTheme.of(context).color ?? AppColors.primary;

    return HoverCardWidget(
      borderRadius: 0,
      onTap: () {
        Navigator.pushNamed(context, '/project/${project.slug}');
      },
      child: AnimatedGradient(
        gradient: Theme.of(context).previewGradient,
        borderRadius: BorderRadius.zero,
        duration: const Duration(seconds: 6),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: isMobile
              ? Flex(
                  direction: Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: mediaWidth,
                      child: AnimatedGradient(
                        gradient: _thumbnailWhiteGradient,
                        borderRadius: BorderRadius.zero,
                        duration: const Duration(seconds: 6),
                        child: Container(
                          height: mediaHeight,
                          padding: const EdgeInsets.all(6),
                          child: ProjectThumbnailPreview(
                            imgPaths: project.imgPaths.isNotEmpty
                                ? project.imgPaths
                                : null,
                            videoLink: project.vidLink,
                            width: mediaWidth,
                            height: mediaHeight,
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildContentColumn(
                      isMobile: true,
                      summaryText: summaryText,
                      bulletItems: bulletItems,
                      extraCount: extraCount,
                      displayDate: displayDate,
                      linkColor: linkColor,
                      downloadUrl: downloadUrl,
                    ),
                  ],
                )
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: mediaWidth,
                        child: AnimatedGradient(
                          gradient: _thumbnailWhiteGradient,
                          borderRadius: BorderRadius.zero,
                          duration: const Duration(seconds: 6),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            child: ProjectThumbnailPreview(
                              imgPaths: project.imgPaths.isNotEmpty
                                  ? project.imgPaths
                                  : null,
                              videoLink: project.vidLink,
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildContentColumn(
                          isMobile: false,
                          summaryText: summaryText,
                          bulletItems: bulletItems,
                          extraCount: extraCount,
                          displayDate: displayDate,
                          linkColor: linkColor,
                          downloadUrl: downloadUrl,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildContentColumn({
    required bool isMobile,
    required String summaryText,
    required List<String> bulletItems,
    required int extraCount,
    required String displayDate,
    required Color linkColor,
    required String? downloadUrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              project.title,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: isMobile ? 18 : 30,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (project.projectType.trim().isNotEmpty)
              _buildProjectTypeBadge(project.projectType, isMobile),
          ],
        ),
        if (project.tags.isNotEmpty || project.tools.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final tag in project.tags) _buildTagChip(tag, isMobile: isMobile),
              for (final tool in project.tools) _buildToolBadge(tool),
            ],
          ),
        ],
        if (summaryText.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            summaryText,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (bulletItems.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...bulletItems.map((b) => _buildBulletLine(b, isMobile: isMobile)),
          if (extraCount > 0) ...[
            const SizedBox(height: 4),
            Text(
              '+$extraCount more',
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: AppColors.textSecondary.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (displayDate.isNotEmpty)
              _buildDatePill(
                value: displayDate,
                isCompact: isMobile,
              ),
            if (project.githubLink != null && project.githubLink!.trim().isNotEmpty)
              _buildIconLinkButton(
                icon: Icons.code,
                tooltip: 'Open GitHub',
                url: project.githubLink!,
                color: linkColor,
              ),
            if (project.vidLink != null && project.vidLink!.trim().isNotEmpty)
              _buildIconLinkButton(
                icon: Icons.play_circle_outline,
                tooltip: 'Watch video',
                url: project.vidLink!,
                color: linkColor,
              ),
            if (downloadUrl != null)
              _buildIconLinkButton(
                icon: Icons.download_for_offline_outlined,
                tooltip: 'Download',
                url: downloadUrl,
                color: linkColor,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildProjectTypeBadge(String type, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 10,
        vertical: isMobile ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.toUpperCase(),
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: isMobile ? 11 : 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildBulletLine(String text, {required bool isMobile}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: isMobile ? 8 : 8),
            width: isMobile ? 5 : 6,
            height: isMobile ? 5 : 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text.trim(),
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag, {required bool isMobile}) {
    return Chip(
      label: Text(
        tag,
        textAlign: TextAlign.justify,
        style: TextStyle(fontSize: isMobile ? 11 : 12),
      ),
      backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
      side: BorderSide(
        color: AppColors.secondary.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildDatePill({
    required String value,
    required bool isCompact,
  }) {
    final fontSize = isCompact ? 12.0 : 13.0;
    final paddingH = isCompact ? 8.0 : 10.0;
    final paddingV = isCompact ? 4.0 : 5.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, size: 14, color: Colors.blueGrey),
          const SizedBox(width: 6),
          Text(
            'Updated $value',
            textAlign: TextAlign.justify,
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

  Widget _buildIconLinkButton({
    required IconData icon,
    required String tooltip,
    required String url,
    required Color color,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: color,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        splashRadius: 18,
        onPressed: () => _openLink(url),
      ),
    );
  }

  Widget _buildToolBadge(String tool) {
    return ToolBadgeList(
      tools: [tool],
      showIcons: true,
      fontSize: 11.5,
      spacing: 0,
      runSpacing: 0,
    );
  }

  String? _firstDownloadUrl(List<ProjectDownload> downloadPaths) {
    for (final item in downloadPaths) {
      final url = item.url.trim();
      if (url.isNotEmpty) {
        return url;
      }
    }
    return null;
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
