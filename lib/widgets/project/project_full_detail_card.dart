import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/responsive_web_utils.dart';
import '../../core/theme.dart';
import '../../data/projects/project_data.dart';
import '../generic/image_gallery.dart';
import '../generic/tool_badge_list.dart';
import '../generic/youtube_video_player.dart';

class ProjectFullDetailCard extends StatelessWidget {
  final ProjectData project;

  const ProjectFullDetailCard({
    required this.project,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectDetailMainContent(project: project);
  }
}

class ProjectDetailMainContent extends StatelessWidget {
  final ProjectData project;

  const ProjectDetailMainContent({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWebUtils.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (project.description?.isNotEmpty ?? false) ...[
          _SectionHeader(title: 'About', projectType: project.projectType),
          const SizedBox(height: 12),
          _AboutSection(project: project),
        ],
      ],
    );
  }
}

class ProjectDetailGalleryContent extends StatelessWidget {
  final ProjectData project;

  const ProjectDetailGalleryContent({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    return _GallerySection(project: project);
  }
}

class ProjectDetailMetaHeader extends StatelessWidget {
  final ProjectData project;

  const ProjectDetailMetaHeader({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWebUtils.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            Text(
              'Created ${ProjectDetailFormatter.formatDate(project.date)}',
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: Colors.grey,
              ),
            ),
            if (project.lastUpdate != null)
              Text(
                'Updated ${ProjectDetailFormatter.formatDate(project.lastUpdate!)}',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class ProjectDetailMetaRail extends StatelessWidget {
  final ProjectData project;

  const ProjectDetailMetaRail({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    final blocks = <Widget>[];

    if (project.whatIDid.isNotEmpty) {
      blocks.add(
        _RailBlock(
          title: 'What I Did',
          child: _WhatIDidRailSection(project: project),
        ),
      );
    }

    final links = _buildLinks(context);
    if (links != null) {
      blocks.add(_RailBlock(title: 'Links', child: links));
    }

    if (project.downloadPaths.isNotEmpty) {
      blocks.add(
        _RailBlock(
          title: 'Downloads',
          child: _DownloadsBlock(project: project),
        ),
      );
    }

    if (project.tags.isNotEmpty) {
      blocks.add(
        _RailBlock(
          title: 'Tags',
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: project.tags
                .map(
                  (tag) => Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                    side: BorderSide(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }

    if (project.tools.isNotEmpty) {
      blocks.add(
        _RailBlock(
          title: 'Tools',
          child: ToolBadgeList(
            tools: project.tools,
            showIcons: true,
            fontSize: 12,
            spacing: 8,
            runSpacing: 8,
          ),
        ),
      );
    }

    if (blocks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          blocks[i],
          if (i != blocks.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }

  Widget? _buildLinks(BuildContext context) {
    final links = <Widget>[];

    if (project.vidLink != null) {
      links.add(
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => ProjectDetailFormatter.openLink(project.vidLink!),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Watch Demo'),
          ),
        ),
      );
    }

    if (project.githubLink != null) {
      links.add(
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => ProjectDetailFormatter.openLink(project.githubLink!),
            icon: const Icon(Icons.code),
            label: const Text('GitHub Repository'),
          ),
        ),
      );
    }

    if (links.isEmpty) return null;

    return Column(
      children: [
        for (var i = 0; i < links.length; i++) ...[
          links[i],
          if (i != links.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? projectType;

  const _SectionHeader({required this.title, this.projectType});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWebUtils.isMobile(context);
    final hasProjectType = projectType != null && projectType!.trim().isNotEmpty;
    final titleWidget = Text(
      title,
      style: TextStyle(
        fontSize: isMobile ? 18 : 22,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    );

    if (isMobile && hasProjectType) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 6,
        children: [
          titleWidget,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              projectType!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    return titleWidget;
  }
}

class _AboutSection extends StatelessWidget {
  final ProjectData project;

  const _AboutSection({required this.project});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWebUtils.isMobile(context);
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium?.copyWith(
          height: 1.6,
          fontSize: isMobile ? 14 : 16,
          color: AppColors.textSecondary,
        ) ??
        TextStyle(
          fontSize: isMobile ? 14 : 16,
          height: 1.6,
          color: AppColors.textSecondary,
        );

    final description = project.description?.trim();
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Text(description ?? '', style: style, textAlign: TextAlign.justify),
    );
  }
}

class _WhatIDidRailSection extends StatelessWidget {
  final ProjectData project;

  const _WhatIDidRailSection({required this.project});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemStyle = theme.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          height: 1.45,
          color: AppColors.textSecondary,
        ) ??
        const TextStyle(
          fontSize: 14,
          height: 1.45,
          color: AppColors.textSecondary,
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < project.whatIDid.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 7),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ProjectDetailFormatter.normalizeIndentation(
                      project.whatIDid[i],
                    ),
                    style: itemStyle,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
            if (i != project.whatIDid.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _GallerySection extends StatelessWidget {
  final ProjectData project;

  const _GallerySection({required this.project});

  @override
  Widget build(BuildContext context) {
    final videoWidget = project.vidLink != null
        ? YoutubeVideoPlayer(videoUrl: project.vidLink!)
        : null;
    final imagesWidget = project.imgPaths.isNotEmpty
        ? ImageGallery(imagePaths: project.imgPaths)
        : null;

    return _ProjectGallerySwitcher(
      videoContent: videoWidget,
      imagesContent: imagesWidget,
    );
  }
}

class _ProjectGallerySwitcher extends StatefulWidget {
  final Widget? videoContent;
  final Widget? imagesContent;

  const _ProjectGallerySwitcher({this.videoContent, this.imagesContent});

  @override
  State<_ProjectGallerySwitcher> createState() =>
      _ProjectGallerySwitcherState();
}

class _ProjectGallerySwitcherState extends State<_ProjectGallerySwitcher> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.videoContent != null ? 'video' : 'images';
  }

  @override
  void didUpdateWidget(covariant _ProjectGallerySwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selected == 'video' &&
        widget.videoContent == null &&
        widget.imagesContent != null) {
      _selected = 'images';
    } else if (_selected == 'images' &&
        widget.imagesContent == null &&
        widget.videoContent != null) {
      _selected = 'video';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <String, Widget>{
      if (widget.videoContent != null) 'video': widget.videoContent!,
      if (widget.imagesContent != null) 'images': widget.imagesContent!,
    };

    if (tabs.isEmpty) return const SizedBox.shrink();

    final current = tabs[_selected] ?? tabs.values.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tabs.length > 1) ...[
          Wrap(
            spacing: 12,
            children: [
              for (final entry in tabs.entries)
                ChoiceChip(
                  label: Text(entry.key == 'video' ? 'Video' : 'Images'),
                  selected: _selected == entry.key,
                  onSelected: (_) => setState(() => _selected = entry.key),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        current,
      ],
    );
  }
}

class _RailBlock extends StatelessWidget {
  final String title;
  final Widget child;

  const _RailBlock({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: Theme.of(context).previewGradient,
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _DownloadsBlock extends StatelessWidget {
  final ProjectData project;

  const _DownloadsBlock({required this.project});

  @override
  Widget build(BuildContext context) {
    final items = project.downloadPaths.map(ProjectDetailFormatter.parseDownload).toList();

    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: items[i].url.startsWith('http')
                  ? () => ProjectDetailFormatter.openLink(items[i].url)
                  : null,
              icon: const Icon(Icons.download),
              label: Text(items[i].label),
            ),
          ),
          if (i != items.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class DownloadItem {
  final String label;
  final String url;

  const DownloadItem({required this.label, required this.url});
}

class ProjectDetailFormatter {
  static String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  static String normalizeIndentation(String input) {
    if (input.isEmpty) return input;

    final lines = input.replaceAll('\r\n', '\n').split('\n');
    int? minIndent;
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final match = RegExp(r'^\s*').firstMatch(line);
      if (match != null) {
        final indent = match.group(0)!.length;
        if (minIndent == null || indent < minIndent) minIndent = indent;
      }
    }

    if (minIndent == null || minIndent == 0) {
      return input.trim();
    }

    final stripped = lines
        .map((line) {
          if (line.trim().isEmpty) return '';
          return line.length >= minIndent! ? line.substring(minIndent) : line.trimLeft();
        })
        .join('\n');

    return stripped.trim();
  }

  static DownloadItem parseDownload(dynamic entry) {
    if (entry is Map<String, dynamic>) {
      final url = entry['url']?.toString() ?? '';
      final label = entry['key']?.toString() ?? _fallbackLabel(url);
      return DownloadItem(label: label, url: url);
    }
    if (entry is String) {
      return DownloadItem(label: _fallbackLabel(entry), url: entry);
    }
    final url = entry.toString();
    return DownloadItem(label: _fallbackLabel(url), url: url);
  }

  static String _fallbackLabel(String url) {
    if (url.isEmpty) return 'Download';
    final parts = url.split('/');
    return parts.isNotEmpty && parts.last.isNotEmpty ? parts.last : 'Download';
  }

  static Future<void> openLink(String url) async {
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
