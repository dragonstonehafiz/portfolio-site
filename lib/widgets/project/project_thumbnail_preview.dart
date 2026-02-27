import 'package:flutter/material.dart';
import '../../data/projects/project_data.dart';
import '../../core/theme.dart';

/// A flexible thumbnail preview widget that displays project images or video thumbnails.
/// Sized based on width/height parameters provided by parent.
class ProjectThumbnailPreview extends StatelessWidget {
  final List<String>? imgPaths;
  final String? videoLink;
  final double width;
  final double height;
  final BorderRadiusGeometry borderRadius;

  const ProjectThumbnailPreview({
    this.imgPaths,
    this.videoLink,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Prefer image if available
    if (imgPaths != null && imgPaths!.isNotEmpty) {
      return _buildImageThumbnail();
    } else if (videoLink != null && videoLink!.isNotEmpty) {
      return _buildVideoThumbnail();
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildImageThumbnail() {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.asset(
        'assets/${imgPaths!.first}',
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image_not_supported),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    final ytId = ProjectData.extractYoutubeId(videoLink!);
    if (ytId == null) {
      return _buildPlaceholder();
    }

    final thumbUrl = 'https://img.youtube.com/vi/$ytId/hqdefault.jpg';
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
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
                      size: height * 0.4,
                    ),
                  ),
                );
              },
            ),
            Container(
              alignment: Alignment.center,
              color: Colors.black26,
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white70,
                size: height * 0.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: Colors.grey[600],
            size: height * 0.3,
          ),
        ),
      ),
    );
  }
}
