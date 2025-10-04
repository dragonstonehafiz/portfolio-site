// Web implementation: registers an IFrameElement using modern web APIs
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart';

String createIframeView(String id, String src, {double width = 640, double height = 360}) {
  final viewId = 'youtube-iframe-$id-${DateTime.now().millisecondsSinceEpoch}';

  // Create iframe element using modern web APIs
  final iframe = document.createElement('iframe') as HTMLIFrameElement;
  iframe.src = src;
  iframe.style.border = '0';
  // Ensure explicit CSS width/height are set so the platform view doesn't default to 100%
  // Use px to make values explicit; fall back to defaults when values are not finite
  final safeWidth = (width.isFinite && width > 0) ? '${width.toInt()}px' : '100%';
  final safeHeight = (height.isFinite && height > 0) ? '${height.toInt()}px' : '100%';
  iframe.style.width = safeWidth;
  iframe.style.height = safeHeight;
  // Also set element attributes for broader browser compatibility
  iframe.width = (width.isFinite && width > 0) ? width.toInt().toString() : '';
  iframe.height = (height.isFinite && height > 0) ? height.toInt().toString() : '';
  iframe.style.display = 'block';
  iframe.allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';
  iframe.setAttribute('allowfullscreen', 'true');

  // Register the view factory so Flutter can render the iframe
  ui_web.platformViewRegistry.registerViewFactory(
    viewId,
    (int viewId) => iframe,
  );
  return viewId;
}
