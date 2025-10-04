import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_iframe_helper_html.dart';

/// A lightweight embedded YouTube player that accepts either a full
class YoutubeEmbed extends StatefulWidget {
  final String url;
  final double aspectRatio;

  const YoutubeEmbed(this.url, {super.key, this.aspectRatio = 16 / 9});

  @override
  State<YoutubeEmbed> createState() => _YoutubeEmbedState();
}

class _YoutubeEmbedState extends State<YoutubeEmbed> {
  @override
  Widget build(BuildContext context) {
  final url = widget.url;

  if (url.trim().isEmpty) return const SizedBox.shrink();
    
    // On web, convert any YouTube URL directly to embed URL and use iframe
    if (kIsWeb) {
      final embedSrc = _convertToEmbedUrl(url);
      if (embedSrc != null) {
        return LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 640.0;
          final height = width / widget.aspectRatio;
          final viewId = createIframeView(url, embedSrc, width: width, height: height);
          if (viewId.isEmpty) {
            return _externalButton(url);
          }
          return StatefulBuilder(builder: (context, setState) {
            bool activated = false;
            void activate() {
              try {
                enableIframeInteraction(viewId);
              } catch (_) {}
              setState(() => activated = true);
            }

            return SizedBox(
              width: width,
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  HtmlElementView(viewType: viewId),
                  // Overlay: show play button and intercept pointer events until activated
                  if (!activated)
                    Material(
                      color: Colors.black.withValues(alpha: 0.35),
                      child: InkWell(
                        onTap: activate,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: const Icon(Icons.play_arrow, size: 32, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          });
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
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
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
}
