import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/youtube_embedded.dart';
import '../utils/theme.dart';
import '../routes/app_routes.dart';

class Project {
  final String variableName;
  final String category;
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
  final List<String> downloadPaths;

  Project({
    required this.variableName,
    required this.category,
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
    required this.downloadPaths,
  });

  factory Project.fromJson(String key, Map<String, dynamic> json) {
    return Project(
      variableName: json['variable_name'] ?? key,
      category: json['category'] ?? '',
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
      downloadPaths: List<String>.from(json['download_paths'] ?? []),
    );
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
      // If the path is a URL, open it. If it's a local asset path, try to open the file URL.
      if (path.startsWith('http://') || path.startsWith('https://')) {
        await _openLink(path);
        return;
      }

      // For local assets, attempt to open the containing folder via a file URI —
      // on web/mobile this will normally just open the asset in the browser.
      final uri = Uri.parse(path);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error downloading/opening $path: $e');
    }
  }

  // Returns a preview widget for projects/featured pages
  Widget buildPreviewWidget(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.projectDetail,
            arguments: {'project': this},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                _buildDescriptionWidget(maxLines: 2),
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
    );
  }

  // Returns a full detailed widget for the project detail page
  Widget buildFullWidget(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
              const Text(
                'Back to Projects',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Project title and metadata (use helpers)
          _buildTitleWidget(context, isPreview: false),
          const SizedBox(height: 16),
          _buildMetaRow(context, isPreview: false),

          // Video (embedded) or links row
          const SizedBox(height: 24),
          if (vidLink != null) ...[
            _buildVideoWidget(context),
          ],

          // Description
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 32),
            _buildSection('About This Project', null),
            const SizedBox(height: 12),
            _buildDescriptionWidget(),
          ],

          // What I did
          if (whatIDid.isNotEmpty) ...[
            const SizedBox(height: 32),
            _buildSection('What I Did', null),
            const SizedBox(height: 12),
            _buildWhatIDidList(),
          ],

          // Tags
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 32),
            _buildSection('Tags', null),
            const SizedBox(height: 12),
            _buildTagsWidget(maxToShow: tags.length),
          ],

          // Images gallery
          if (imgPaths.isNotEmpty) ...[
            const SizedBox(height: 32),
            _buildSection('Project Gallery', null),
            const SizedBox(height: 16),
            _buildFullImage(context),
          ],

          // Downloads
          if (downloadPaths.isNotEmpty) ...[
            const SizedBox(height: 32),
            _buildSection('Downloads', null),
            const SizedBox(height: 12),
            _buildDownloads(),
          ],
        ],
      ),
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

  // Responsive media container that scales with screen size
  Widget _buildResponsiveMediaContainer(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;
    
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
            color: AppColors.skyDark,
          ),
      ],
    );
  }

  // Meta row (project type and date) used both in preview and full view
  Widget _buildMetaRow(BuildContext context, {bool isPreview = false}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: isPreview ? 8 : 12, vertical: isPreview ? 4 : 6),
          decoration: BoxDecoration(
            color: AppColors.skyAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(isPreview ? 12 : 16),
          ),
          child: Text(
            projectType,
            style: TextStyle(
              fontSize: isPreview ? 12 : 14,
              color: AppColors.skyDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Video link (if available) shown before GitHub link
        if (vidLink != null) ...[
          isPreview
              ? TextButton(
                  onPressed: () => _openLink(vidLink!),
                  child: const Text('Video', style: TextStyle(fontSize: 12)),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextButton.icon(
                    onPressed: () => _openLink(vidLink!),
                    icon: const Icon(Icons.play_circle_fill, size: 16),
                    label: const Text('Watch Video'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.skyDark,
                    ),
                  ),
                ),
        ],

        // Github link next to project type
        if (githubLink != null) ...[
          isPreview
              ? TextButton(
                  onPressed: () => _openLink(githubLink!),
                  child: const Text('GitHub Link', style: TextStyle(fontSize: 12)),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextButton.icon(
                    onPressed: () => _openLink(githubLink!),
                    icon: const Icon(Icons.code, size: 16),
                    label: const Text('GitHub Link'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.skyDark,
                    ),
                  ),
                ),
        ],

        const SizedBox(width: 8),

        Text(
          isPreview ? (DateTime.tryParse(date)?.year.toString() ?? date) : 'Created: ${_formatDate(date)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        if (!isPreview && lastUpdate != null) ...[
          const SizedBox(width: 16),
          Text(
            'Updated: ${_formatDate(lastUpdate!)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  // Description widget (can be used in preview with maxLines)
  Widget _buildDescriptionWidget({int? maxLines}) {
    return Text(
      description ?? '',
      style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.4),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible,
    );
  }

  // Tags widget
  Widget _buildTagsWidget({int maxToShow = 999}) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: tags.take(maxToShow).map((tag) => Chip(
        label: Text(tag, style: const TextStyle(fontSize: 12)),
        backgroundColor: AppColors.sky.withOpacity(0.1),
        side: BorderSide(color: AppColors.sky.withOpacity(0.3)),
      )).toList(),
    );
  }

  // What I did list
  Widget _buildWhatIDidList() {
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
                color: AppColors.skyDark,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item,
                style: const TextStyle(fontSize: 16, height: 1.5),
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
      children: downloadPaths.map((path) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ElevatedButton.icon(
          onPressed: () => _downloadFile(path),
          icon: const Icon(Icons.download),
          label: Text(path.split('/').last),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.sky,
            foregroundColor: Colors.white,
          ),
        ),
      )).toList(),
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
  Widget _buildVideoWidget(BuildContext context, {double width = 427, double height = 240}) {
    final link = vidLink;
    if (link == null) return const SizedBox.shrink();

    // Delegate ID extraction and fallback button to the YoutubeEmbed widget.
    final aspect = width / height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            width: width,
            height: height,
            child: YoutubeEmbed(link, aspectRatio: aspect),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }


}

