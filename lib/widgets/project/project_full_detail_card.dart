import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/projects/project_data.dart';
import '../../core/theme.dart';
import '../generic/image_gallery.dart';
import '../generic/youtube_video_player.dart';

/// A comprehensive detail card widget for displaying full project information.
/// Extracts all detail rendering logic from ProjectData for proper separation of concerns.
class ProjectFullDetailCard extends StatelessWidget {
  final ProjectData project;

  const ProjectFullDetailCard({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetaRow(context),
        if (project.vignette.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSectionHeader('What is this Project?'),
          const SizedBox(height: 12),
          _buildVignetteSection(context),
        ],
        if (project.vidLink != null || project.imgPaths.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildProjectGallerySection(context),
        ],
        if ((project.description?.isNotEmpty ?? false) || project.whatIDid.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildProjectDetailsSection(context),
        ],
        if (project.tools.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSectionHeader('Tools'),
          const SizedBox(height: 12),
          _buildToolsWidget(maxToShow: project.tools.length),
        ],
        if (project.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSectionHeader('Tags'),
          const SizedBox(height: 12),
          _buildTagsWidget(maxToShow: project.tags.length),
        ],
        if (project.downloadPaths.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSectionHeader('Downloads'),
          const SizedBox(height: 12),
          _buildDownloads(),
        ],
      ],
    );
  }

  Widget _buildMetaRow(BuildContext context) {
    final hasDownloads = project.downloadPaths.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                project.projectType,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (project.vidLink != null || project.githubLink != null || hasDownloads)
          Row(
            children: [
              if (project.vidLink != null) ...[
                TextButton.icon(
                  onPressed: () => _openLink(project.vidLink!),
                  icon: const Icon(Icons.play_circle_fill, size: 16),
                  label: const Text('Watch Video'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
              if (project.vidLink != null && project.githubLink != null) 
                const SizedBox(width: 8),
              if (project.githubLink != null) ...[
                TextButton.icon(
                  onPressed: () => _openLink(project.githubLink!),
                  icon: const Icon(Icons.code, size: 16),
                  label: const Text('GitHub Link'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(
              child: Text(
                'Created: ${_formatDate(project.date)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (project.lastUpdate != null) ...[
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Updated: ${_formatDate(project.lastUpdate!)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildProjectGallerySection(BuildContext context) {
    final videoWidget = project.vidLink != null ? YoutubeVideoPlayer(videoUrl: project.vidLink!) : null;
    final imagesWidget = project.imgPaths.isNotEmpty 
        ? ImageGallery(imagePaths: project.imgPaths) 
        : null;
    return _ProjectGallerySwitcher(
      videoContent: videoWidget,
      imagesContent: imagesWidget,
    );
  }

  Widget _buildProjectDetailsSection(BuildContext context) {
    final descriptionWidget = (project.description != null && project.description!.isNotEmpty) 
        ? _buildDescriptionWidget(context) 
        : null;
    final deliverablesWidget = project.whatIDid.isNotEmpty 
        ? _buildWhatIDidWidget(context) 
        : null;
    if (descriptionWidget == null && deliverablesWidget == null) {
      return const SizedBox.shrink();
    }
    return _ProjectDetailsSwitcher(
      descriptionContent: descriptionWidget,
      deliverablesContent: deliverablesWidget,
    );
  }

  Widget _buildVignetteSection(BuildContext context) {
    if (project.vignette.isEmpty) return const SizedBox.shrink();
    return Text(
      project.vignette,
      style: const TextStyle(
        fontSize: 16,
        height: 1.6,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    );
  }

  Widget _buildDescriptionWidget(BuildContext context) {
    final content = project.description ?? '';
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
          height: 1.6,
          fontSize: 16,
          color: AppColors.textSecondary,
        ) ??
        const TextStyle(fontSize: 16, height: 1.6, color: AppColors.textSecondary);

    return Text(
      content,
      style: textStyle,
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildTagsWidget({int maxToShow = 999}) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: project.tags.take(maxToShow).map((tag) => Chip(
        label: Text(tag, style: const TextStyle(fontSize: 12)),
        backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
        side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3)),
      )).toList(),
    );
  }

  Widget _buildToolsWidget({int maxToShow = 999}) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: project.tools.take(maxToShow).map((tool) => Chip(
        label: Text(tool, style: const TextStyle(fontSize: 12)),
        backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
        side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3)),
      )).toList(),
    );
  }

  Widget _buildWhatIDidWidget(BuildContext context) {
    final theme = Theme.of(context);
    final itemStyle = theme.textTheme.bodyLarge?.copyWith(
          height: 1.6,
          color: AppColors.textSecondary,
        ) ??
        const TextStyle(fontSize: 16, height: 1.6, color: AppColors.textSecondary);

    return Column(
      children: project.whatIDid.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 3.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _normalizeIndentation(item),
                style: itemStyle,
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildDownloads() {
    return Column(
      children: project.downloadPaths.map((entry) {
        String url;
        String label;

        if (entry is Map<String, dynamic>) {
          url = entry['url'] ?? '';
          label = entry['key'] ?? url.split('/').last;
        } else if (entry is String) {
          url = entry;
          label = entry.split('/').last;
        } else {
          url = entry.toString();
          label = url.split('/').last;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ElevatedButton.icon(
            onPressed: url.startsWith('http') ? () => _downloadFile(url) : null,
            icon: const Icon(Icons.download),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _normalizeIndentation(String input) {
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

    final stripped = lines.map((line) {
      if (line.trim().isEmpty) return '';
      return line.length >= minIndent! ? line.substring(minIndent) : line.trimLeft();
    }).join('\n');

    return stripped.trim();
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

  Future<void> _downloadFile(String path) async {
    try {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        await _openLink(path);
        return;
      }
      debugPrint('Unsupported download path (only http/https allowed): $path');
    } catch (e) {
      debugPrint('Error downloading/opening $path: $e');
    }
  }
}

class _ProjectGallerySwitcher extends StatefulWidget {
  final Widget? videoContent;
  final Widget? imagesContent;

  const _ProjectGallerySwitcher({
    this.videoContent,
    this.imagesContent,
  });

  @override
  State<_ProjectGallerySwitcher> createState() => _ProjectGallerySwitcherState();
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
    if (_selected == 'video' && widget.videoContent == null && widget.imagesContent != null) {
      _selected = 'images';
    } else if (_selected == 'images' && widget.imagesContent == null && widget.videoContent != null) {
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
        const Text(
          'Project Gallery',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        if (tabs.isNotEmpty) ...[
          const SizedBox(height: 12),
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

class _ProjectDetailsSwitcher extends StatefulWidget {
  final Widget? descriptionContent;
  final Widget? deliverablesContent;

  const _ProjectDetailsSwitcher({
    this.descriptionContent,
    this.deliverablesContent,
  });

  @override
  State<_ProjectDetailsSwitcher> createState() => _ProjectDetailsSwitcherState();
}

class _ProjectDetailsSwitcherState extends State<_ProjectDetailsSwitcher> {
  late String _selectedKey;

  @override
  void initState() {
    super.initState();
    _selectedKey = widget.descriptionContent != null
        ? 'description'
        : 'deliverables';
  }

  @override
  void didUpdateWidget(covariant _ProjectDetailsSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedKey == 'deliverables' &&
        widget.deliverablesContent == null &&
        widget.descriptionContent != null) {
      _selectedKey = 'description';
    } else if (_selectedKey == 'description' &&
        widget.descriptionContent == null &&
        widget.deliverablesContent != null) {
      _selectedKey = 'deliverables';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <String, Widget>{
      if (widget.descriptionContent != null)
        'description': widget.descriptionContent!,
      if (widget.deliverablesContent != null)
        'deliverables': widget.deliverablesContent!,
    };

    if (tabs.isEmpty) return const SizedBox.shrink();

    final current = tabs[_selectedKey] ?? tabs.values.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Details',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        if (tabs.length > 1) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              for (final entry in tabs.entries)
                ChoiceChip(
                  label: Text(
                    entry.key == 'description' ? 'Description' : 'Deliverables',
                  ),
                  selected: _selectedKey == entry.key,
                  onSelected: (_) => setState(() {
                    _selectedKey = entry.key;
                  }),
                ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        current,
      ],
    );
  }
}
