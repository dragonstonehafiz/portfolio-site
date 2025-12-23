import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../widgets/youtube_embedded.dart';
import '../utils/theme.dart';
import '../utils/responsive_web_utils.dart';
import '../widgets/hover_card_widget.dart';
import '../widgets/animated_gradient.dart';

class ProjectData {
  final String variableName;
  final String title;
  final String? description;
  final String date;
  final String? lastUpdate;
  final String? vidLink;
  final String? githubLink;
  final List<String> imgPaths;
  final List<String> whatIDid;
  final List<String> tags;
  final String projectType;
  final String version;
  // Each download entry is expected to be a map with keys 'key' and 'url'.
  // For backward compatibility we still accept a list of string URLs.
  final List<dynamic> downloadPaths;

  ProjectData({
    required this.variableName,
    required this.title,
    this.description,
    required this.date,
    this.lastUpdate,
    this.vidLink,
    this.githubLink,
    required this.imgPaths,
    required this.whatIDid,
    required this.tags,
    required this.projectType,
    required this.version,
    required this.downloadPaths,
  });

  factory ProjectData.fromJson(
    String key,
    Map<String, dynamic> json, {
    String? versionOverride,
  }) {
    return ProjectData(
      variableName: json['variable_name'] ?? key,
      title: json['title'] ?? '',
      description: json['description'],
      date: json['date'] ?? '',
      lastUpdate: json['last_update'],
      vidLink: json['vid_link'],
      githubLink: json['github_link'],
      imgPaths: List<String>.from(json['img_paths'] ?? []),
      whatIDid: List<String>.from(json['what_i_did'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      projectType: json['project_type'] ?? '',
      version: versionOverride ?? json['version']?.toString() ?? 'default',
      downloadPaths: (json['download_paths'] as List<dynamic>?)?.toList() ?? [],
    );
  }

  /// Return a URL-friendly slug for this project.
  String get slug {
    // Use variableName as the canonical identifier for slugs. This ensures
    // slugs are stable and unique (assuming variableName is unique in
    // projects.json).
    final base = variableName.trim().isNotEmpty ? variableName : title;
    final s = base.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), '-');
    return s.replaceAll(RegExp(r'-+'), '-').trim().replaceAll(RegExp(r'^-+|-+\$'), '');
  }

  Future<void> _openLink(String url) async {
    try {
      final uri = Uri.parse(url);
      // Prefer launching as an external application when possible
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        // fallback: try without specifying mode
        await launchUrl(uri);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error launching $url: $e');
    }
  }


  Future<void> _downloadFile(String path) async {
    try {
      // Only allow HTTP(S) links for downloads. Local file handling removed.
      if (path.startsWith('http://') || path.startsWith('https://')) {
        await _openLink(path);
        return;
      }

      // If we get here the path is not a supported remote URL. Log and ignore.
      debugPrint('Unsupported download path (only http/https allowed): $path');
    } catch (e) {
      // ignore: avoid_print
      debugPrint('Error downloading/opening $path: $e');
    }
  }

  // Returns a preview widget for projects/featured pages
  Widget buildPreviewWidget(BuildContext context) {
    // Use the theme's primary gradient for preview cards. Remove the outer
    // Card so HoverCardWidget controls elevation on hover and we avoid
    // doubled shadows. Text inside previews should contrast with the
    // gradient, so apply a white default text color for readability.
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: HoverCardWidget(
        onTap: () {
          Navigator.pushNamed(context, '/projects/${this.slug}');
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
                  _buildTitleWidget(context, isPreview: true),
                  const SizedBox(height: 8),
                  _buildMetaRow(context, isPreview: true),

                  // Description preview
                  if (description != null && description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildDescriptionWidget(context, maxLines: 2),
                  ],

                  // Tags
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildTagsWidget(maxToShow: 3),
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

  // Returns a compact row-styled preview for list mode
  Widget buildListItemWidget(BuildContext context) {
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
    if (projectType.isNotEmpty) {
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
          projectType,
          style: TextStyle(
            fontSize: isMobile ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
          ),
        ),
      );
    }

    Widget buildLinkButton({
      required IconData icon,
      required String tooltip,
      required String url,
    }) {
      return Tooltip(
        message: tooltip,
        child: IconButton(
          icon: Icon(icon, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          splashRadius: 18,
          onPressed: () => _openLink(url),
        ),
      );
    }

    final linkButtons = <Widget>[];
    if (githubLink != null && githubLink!.isNotEmpty) {
      linkButtons.add(buildLinkButton(
        icon: Icons.code,
        tooltip: 'Open GitHub',
        url: githubLink!,
      ));
    }
    if (vidLink != null && vidLink!.isNotEmpty) {
      linkButtons.add(buildLinkButton(
        icon: Icons.play_circle_outline,
        tooltip: 'Watch video',
        url: vidLink!,
      ));
    }

    // Use the same subtle animated preview gradient for list items so the
    // UI reads consistently between grid previews and list previews. Keep
    // the HoverCardWidget for the hover interaction and wrap the inner row
    // with `AnimatedGradient` to provide the animated background.
    return HoverCardWidget(
      onTap: () {
        Navigator.pushNamed(context, '/projects/${this.slug}');
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
              _buildListThumbnail(isMobile),
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
                            title,
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
                    if (tags.isNotEmpty || linkButtons.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (final tag in tags)
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
                        ],
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

  // Returns a full detailed widget for the project detail page
  Widget buildFullWidget(
    BuildContext context, {
    Widget Function(BuildContext context)? versionTabsBuilder,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 1000 ? 1000.0 : screenWidth * 0.9;

    return SingleChildScrollView(
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
                child: Column(
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
                    Center(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (versionTabsBuilder != null) ...[
                      versionTabsBuilder(context),
                      const SizedBox(height: 16),
                    ],
                    buildDetailBody(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDetailBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetaRow(context, isPreview: false),
        if (description != null && description!.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSection('About This Project', null),
          const SizedBox(height: 12),
          _buildDescriptionWidget(context),
        ],
        const SizedBox(height: 24),
        if (vidLink != null) _buildVideoWidget(context),
        if (whatIDid.isNotEmpty) ...[
          const SizedBox(height: 32),
          _buildSection('What I Did', null),
          const SizedBox(height: 12),
          _buildWhatIDidList(context),
        ],
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 32),
          _buildSection('Tags', null),
          const SizedBox(height: 12),
          _buildTagsWidget(maxToShow: tags.length),
        ],
        if (imgPaths.isNotEmpty) ...[
          const SizedBox(height: 32),
          _buildSection('Project Gallery', null),
          const SizedBox(height: 16),
          _buildFullImage(context),
        ],
        if (downloadPaths.isNotEmpty) ...[
          const SizedBox(height: 32),
          _buildSection('Downloads', null),
          const SizedBox(height: 12),
          _buildDownloads(),
        ],
      ],
    );
  }

  Widget _buildSection(String title, String? content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        if (content != null) ...[
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ],
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

  // Placeholder widget when no media is available
  Widget _buildPlaceholderWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 32,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 4),
          Text(
            'No Preview',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Compact thumbnail for list items - small and fixed size.
  Widget _buildListThumbnail(bool isMobile) {
    final size = isMobile ? 48.0 : 56.0; // Small square thumbnail

    // Prefer local image first
    if (imgPaths.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            'assets/${imgPaths.first}',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[600],
                  size: size * 0.4,
                ),
              );
            },
          ),
        ),
      );
    } else if (vidLink != null && vidLink!.isNotEmpty) {
      final ytId = _extractYoutubeId(vidLink!);
      if (ytId != null) {
        final thumbUrl = 'https://img.youtube.com/vi/$ytId/hqdefault.jpg';
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Network thumbnail with graceful error fallback
                Image.network(
                  thumbUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: AppColors.accent,
                          size: size * 0.5,
                        ),
                      ),
                    );
                  },
                ),
                // Small translucent play overlay to indicate video
                Container(
                  alignment: Alignment.center,
                  color: Colors.black26,
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white70,
                    size: size * 0.32,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // If we couldn't parse a YouTube ID, fall back to the simple play icon
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(
          Icons.play_circle_fill,
          color: AppColors.accent,
          size: size * 0.5,
        ),
      );
    } else {    
      return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        Icons.code,
        color: Colors.grey[600],
        size: size * 0.4,
      ),
    );
    }
  }

  // Extract a YouTube video id from common URL formats. Returns null if not found.
  String? _extractYoutubeId(String url) {
    try {
      // Common YouTube URL patterns: youtu.be/ID, v=ID, /embed/ID
      final patterns = [
        RegExp(r'youtu\.be\/([\w-]{11})'),
        RegExp(r'v=([\w-]{11})'),
        RegExp(r'embed\/([\w-]{11})'),
      ];
      for (final p in patterns) {
        final m = p.firstMatch(url);
        if (m != null && m.groupCount >= 1) return m.group(1);
      }

      // As a last resort, try to find any 11-char token that looks like an ID
      final any = RegExp(r'([\w-]{11})');
      final m = any.firstMatch(url);
      if (m != null) return m.group(1);
    } catch (_) {}
    return null;
  }

  // Responsive media container that scales with screen size
  Widget _buildResponsiveMediaContainer(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = ResponsiveWebUtils.isMobile(context);
    
    // Calculate proportional dimensions with better scaling for larger screens
    final containerHeight = isMobile 
        ? screenSize.height * 0.15  // 15% of screen height on mobile
        : (screenSize.height * 0.25).clamp(150.0, 250.0); // 25% of screen height, clamped between 150-250px
    
    final containerWidth = isMobile
        ? screenSize.width * 0.85   // 85% of screen width on mobile (accounting for padding)
        : double.infinity;          // Use full available width on desktop (GridView handles the column width)

    if (isMobile) {
      // Mobile: Use fixed dimensions
      return Container(
        width: containerWidth,
        height: containerHeight,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: imgPaths.isNotEmpty
              ? _buildResponsiveImagePreview(containerWidth - 12, containerHeight - 12)
              : (vidLink != null
                  ? _buildResponsiveVideoPreview(context, containerWidth - 12, containerHeight - 12)
                  : _buildPlaceholderWidget()),
        ),
      );
    } else {
      // Desktop: Use Expanded to fill available space with minimum height
      return Expanded(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: containerHeight,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: imgPaths.isNotEmpty
                ? _buildDesktopImagePreview()
                : (vidLink != null
                    ? _buildDesktopVideoPreview(context)
                    : _buildPlaceholderWidget()),
          ),
        ),
      );
    }
  }

  // Responsive image preview that fits within container dimensions
  Widget _buildResponsiveImagePreview(double width, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: width,
        height: height,
        child: Image.asset(
          'assets/${imgPaths.first}',
          fit: BoxFit.cover, // Use cover to fill the container nicely
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image_not_supported, color: Colors.grey),
                    const SizedBox(height: 4),
                    Text(
                      imgPaths.first,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Responsive video preview that fits within container dimensions
  Widget _buildResponsiveVideoPreview(BuildContext context, double width, double height) {
    final link = vidLink;
    if (link == null) return _buildPlaceholderWidget();

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: width,
        height: height,
        child: YoutubeEmbed(link, aspectRatio: width / height),
      ),
    );
  }

  // Desktop image preview that expands to fill available space
  Widget _buildDesktopImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        'assets/${imgPaths.first}',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image_not_supported, color: Colors.grey),
                  const SizedBox(height: 4),
                  Text(
                    imgPaths.first,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Desktop video preview that expands to fill available space
  Widget _buildDesktopVideoPreview(BuildContext context) {
    final link = vidLink;
    if (link == null) return _buildPlaceholderWidget();

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return YoutubeEmbed(
            link,
            aspectRatio: constraints.maxWidth / constraints.maxHeight,
          );
        },
      ),
    );
  }

  // Title widget used in preview and full view
  Widget _buildTitleWidget(BuildContext context, {bool isPreview = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isPreview ? 24 : 48,
              fontWeight: FontWeight.bold,
              color: isPreview ? null : Colors.blueGrey,
            ),
          ),
        ),
        if (isPreview)
          Icon(
            Icons.arrow_forward_ios,
            color: AppColors.primary,
          ),
      ],
    );
  }

  // Meta row (project type and date) used both in preview and full view
  Widget _buildMetaRow(BuildContext context, {bool isPreview = false}) {
    // Split meta into three stacked rows to avoid horizontal overflow on narrow
    // screens: (1) project type, (2) links (video & github), (3) dates
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Project type
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: isPreview ? 8 : 12, vertical: isPreview ? 4 : 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(isPreview ? 12 : 16),
              ),
              child: Text(
                projectType,
                style: TextStyle(
                  fontSize: isPreview ? 12 : 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Row 2: Links (video then github)
        if (vidLink != null || githubLink != null)
          Row(
            children: [
              if (vidLink != null) ...[
                isPreview
                    ? TextButton(
                        onPressed: () => _openLink(vidLink!),
                        child: const Text('Video Link', style: TextStyle(fontSize: 12)),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 0.0),
                        child: TextButton.icon(
                          onPressed: () => _openLink(vidLink!),
                          icon: const Icon(Icons.play_circle_fill, size: 16),
                          label: const Text('Watch Video'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ),
              ],

              // Only insert horizontal spacing if both links are present
              if (vidLink != null && githubLink != null) const SizedBox(width: 8),

              if (githubLink != null) ...[
                isPreview
                    ? TextButton(
                        onPressed: () => _openLink(githubLink!),
                        child: const Text('GitHub Link', style: TextStyle(fontSize: 12)),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 0.0),
                        child: TextButton.icon(
                          onPressed: () => _openLink(githubLink!),
                          icon: const Icon(Icons.code, size: 16),
                          label: const Text('GitHub Link'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ),
              ],
            ],
          ),

        const SizedBox(height: 8),

        // Row 3: Dates - always show Created and Updated (if present), even in preview.
        Row(
          children: [
            Flexible(
              child: Text(
                'Created: ${_formatDate(date)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Keep a small gap and show Updated date if available
            if (lastUpdate != null) ...[
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Updated: ${_formatDate(lastUpdate!)}',
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

  // Description widget (can be used in preview with maxLines)
  Widget _buildDescriptionWidget(BuildContext context, {int? maxLines}) {
    // Keep the preview behavior using plain Text so we can reliably show a
    // truncated, single-line/2-line preview with ellipsis. For the full view
    // (when maxLines is null) render Markdown so project descriptions can
    // include formatting, links, lists, etc.
    final content = description ?? '';

    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.4) ??
        const TextStyle(fontSize: 16, color: Colors.grey, height: 1.4);

    if (maxLines != null) {
      return Text(
        content,
        style: textStyle,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Full view: normalize indentation to avoid accidental code-block
    // rendering (many JSON files embed multiline strings with leading
    // spaces). Then use Markdown body with a simple style mapping and
    // wire link taps to the existing _openLink handler.
    final normalized = _normalizeMultilineIndentation(content);

    return MarkdownBody(
      data: normalized,
      selectable: false,
      onTapLink: (text, href, title) async {
        if (href != null && href.isNotEmpty) {
          await _openLink(href);
        }
      },
      styleSheet: MarkdownStyleSheet(
        p: textStyle.copyWith(height: 1.6),
        a: TextStyle(color: AppColors.primary),
        listBullet: textStyle,
      ),
    );
  }

  // Remove common leading indentation from multiline text so Markdown
  // parsers don't treat the content as a code block when the source
  // string was indented (for readability in JSON/YAML files).
  String _normalizeMultilineIndentation(String input) {
    if (input.isEmpty) return input;

    final lines = input.replaceAll('\r\n', '\n').split('\n');
    // Find minimum leading spaces among non-empty lines
    int? minIndent;
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final match = RegExp(r'^(\s*)').firstMatch(line);
      if (match != null) {
        final indent = match.group(0)!.length;
        if (minIndent == null || indent < minIndent) minIndent = indent;
      }
    }

    if (minIndent == null || minIndent == 0) {
      return input.trim();
    }

    final minIndentVal = minIndent;
    final stripped = lines.map((line) {
      if (line.trim().isEmpty) return '';
      return line.length >= minIndentVal ? line.substring(minIndentVal) : line.trimLeft();
    }).join('\n');

    return stripped.trim();
  }

  // Tags widget
  Widget _buildTagsWidget({int maxToShow = 999}) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: tags.take(maxToShow).map((tag) => Chip(
        label: Text(tag, style: const TextStyle(fontSize: 12)),
        backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
        side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3)),
      )).toList(),
    );
  }

  // What I did list (render each item as Markdown so inline formatting and
  // links work). Accepts BuildContext to use theme colors.
  Widget _buildWhatIDidList(BuildContext context) {
    final theme = Theme.of(context);
    final itemStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.5) ??
        const TextStyle(fontSize: 16, height: 1.5);

    return Column(
      children: whatIDid.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
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
              child: MarkdownBody(
                data: _normalizeMultilineIndentation(item),
                styleSheet: MarkdownStyleSheet(
                  p: itemStyle,
                  listBullet: itemStyle,
                ),
                onTapLink: (text, href, title) async {
                  if (href != null && href.isNotEmpty) await _openLink(href);
                },
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  // Downloads list
  Widget _buildDownloads() {
    return Column(
      children: downloadPaths.map((entry) {
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

  // Full image widget used on the full project page (uses gallery behavior)
  Widget _buildFullImage(BuildContext context) {
    if (imgPaths.isEmpty) return const SizedBox.shrink();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: imgPaths.length,
      itemBuilder: (context, index) {
        final fullImagePath = 'assets/${imgPaths[index]}';
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                insetPadding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: InteractiveViewer(
                    panEnabled: true,
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.asset(
                      fullImagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.image_not_supported),
                                const SizedBox(height: 8),
                                Text(
                                  'Missing:\n${imgPaths[index]}',
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              fullImagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_not_supported),
                        const SizedBox(height: 4),
                        Text(
                          'Missing:\n${imgPaths[index]}',
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Video widget: shows an embedded YouTube player when possible, otherwise a fallback button
  Widget _buildVideoWidget(BuildContext context) {
    final link = vidLink;
    if (link == null) return const SizedBox.shrink();

    final screenSize = MediaQuery.of(context).size;
    final isMobile = ResponsiveWebUtils.isMobile(context);

    // On mobile, constrain width to a large proportion of the screen and compute
    // height using a 16:9 aspect ratio (or fallback to a square if very narrow).
    if (isMobile) {
      final width = screenSize.width * 0.92; // account for page padding
      final height = (width * 9) / 16;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: width,
              height: height,
              child: _buildResponsiveVideoPreview(context, width, height),
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }

    // On desktop/tablet use the desktop preview which adapts to available space.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenSize.width * 0.8,
              maxHeight: screenSize.height * 0.6,
              minHeight: 200,
            ),
            child: _buildDesktopVideoPreview(context),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }


}

class ProjectEntry {
  final String id;
  final String defaultVersionId;
  final List<ProjectData> _versions;

  ProjectEntry({
    required this.id,
    required this.defaultVersionId,
    required List<ProjectData> versions,
  }) : _versions = List.unmodifiable(versions);

  factory ProjectEntry.fromJson(String id, Map<String, dynamic> json) {
    if (json.containsKey('versions')) {
      final versionsRaw = (json['versions'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final versions = <ProjectData>[];
      for (final versionJson in versionsRaw) {
        final versionId = versionJson['version']?.toString() ?? 'default';
        versions.add(
          ProjectData.fromJson(id, versionJson, versionOverride: versionId),
        );
      }
      final fallback = versions.isNotEmpty ? versions.first.version : 'default';
      final defaultVersion = json['default_version']?.toString();
      final resolvedDefault = defaultVersion != null &&
              versions.any((v) => v.version == defaultVersion)
          ? defaultVersion
          : fallback;
      return ProjectEntry(
        id: id,
        defaultVersionId: resolvedDefault,
        versions: versions,
      );
    }

    final singleVersion =
        ProjectData.fromJson(id, json, versionOverride: 'default');
    return ProjectEntry(
      id: id,
      defaultVersionId: singleVersion.version,
      versions: [singleVersion],
    );
  }

  List<ProjectData> get versions => _versions;

  int get defaultVersionIndex {
    final idx = _versions.indexWhere((v) => v.version == defaultVersionId);
    return idx == -1 ? 0 : idx;
  }

  ProjectData get defaultVersion => _versions[defaultVersionIndex];

  ProjectData? versionById(String versionId) {
    for (final version in _versions) {
      if (version.version == versionId) return version;
    }
    return null;
  }
}
