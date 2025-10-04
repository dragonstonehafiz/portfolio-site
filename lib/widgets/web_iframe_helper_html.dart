// Web implementation: registers an IFrameElement using modern web APIs
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart';

String createIframeView(String id, String src, {double width = 640, double height = 360}) {
  final viewId = 'youtube-iframe-$id-${DateTime.now().millisecondsSinceEpoch}';
  
  // Create iframe element using modern web APIs
  final iframe = document.createElement('iframe') as HTMLIFrameElement;
  iframe.src = src;
  iframe.style.border = '0';
  iframe.width = width.toInt().toString();
  iframe.height = height.toInt().toString();
  iframe.allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';
  iframe.setAttribute('allowfullscreen', 'true');

  // Register the view factory so Flutter can render the iframe
  ui_web.platformViewRegistry.registerViewFactory(
    viewId, 
    (int viewId) => iframe,
  );
  return viewId;
}
