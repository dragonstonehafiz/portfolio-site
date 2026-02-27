import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;
import '../../utils/responsive_web_utils.dart';

/// A reusable YouTube video player widget with responsive sizing and embedded playback.
/// Automatically adapts to mobile and desktop layouts.
/// On web, uses iframe embedding with pointer event gating; falls back to external link on other platforms.
class YoutubeVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const YoutubeVideoPlayer({
    required this.videoUrl,
    super.key,
  });

  @override
  State<YoutubeVideoPlayer> createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<YoutubeVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = ResponsiveWebUtils.isMobile(context);

    if (isMobile) {
      final width = screenSize.width * 0.92;
      final height = (width * 9) / 16;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: width,
              height: height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: _buildEmbeddedPlayer(width / height),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }

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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return _buildEmbeddedPlayer(
                    constraints.maxWidth / constraints.maxHeight,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildEmbeddedPlayer(double aspectRatio) {
    final url = widget.videoUrl;

    if (url.trim().isEmpty) return const SizedBox.shrink();

    // On web, convert any YouTube URL directly to embed URL and use iframe
    if (kIsWeb) {
      final embedSrc = _convertToEmbedUrl(url);
      if (embedSrc != null) {
        return LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 640.0;
          final height = width / aspectRatio;
          final viewId = 'youtube-iframe-${DateTime.now().millisecondsSinceEpoch}';
          
          // Register iframe directly without pointer-events manipulation
          _registerIframeView(viewId, embedSrc, width, height);

          return SizedBox(
            width: width,
            height: height,
            child: HtmlElementView(viewType: viewId),
          );
        });
      }
    }

    return _externalButton(url);
  }

  Widget _externalButton(String url) => ElevatedButton.icon(
    onPressed: () async {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri);
      }
    },
    icon: const Icon(Icons.play_arrow),
    label: const Text('Watch Video'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
  );

  // Convert any YouTube URL to embed URL format
  String? _convertToEmbedUrl(String url) {
    if (url.trim().isEmpty) return null;

    try {
      final uri = Uri.parse(url.trim());
      String? videoId;

      // Handle youtu.be format
      if (uri.host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
        videoId = uri.pathSegments.first;
      }
      // Handle youtube.com format
      else if (uri.host.contains('youtube.com')) {
        videoId = uri.queryParameters['v'];
      }

      if (videoId != null && videoId.isNotEmpty) {
        return 'https://www.youtube.com/embed/$videoId?rel=0&showinfo=0&controls=1';
      }
    } catch (_) {}

    return null;
  }

  void _registerIframeView(String viewId, String embedSrc, double width, double height) {
    final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;
    iframe.src = embedSrc;
    iframe.id = viewId;
    iframe.style.border = '0';
    iframe.style.width = '${width.toInt()}px';
    iframe.style.height = '${height.toInt()}px';
    iframe.style.display = 'block';
    iframe.allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';
    iframe.setAttribute('allowfullscreen', 'true');

    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => iframe,
    );
  }
}
