import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Whether [path] is a remote URL (e.g. a Supabase Storage public URL)
/// rather than a bundled local asset path.
bool isNetworkImagePath(String path) =>
    path.startsWith('http://') || path.startsWith('https://');

Widget _loadingSpinner(double? width, double? height) {
  return SizedBox(
    width: width,
    height: height,
    child: const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
  );
}

/// Renders [path] as a raster image, using [Image.network] for remote URLs
/// and [Image.asset] for bundled paths. Network images show a spinner
/// while loading instead of a blank area.
Widget buildAdaptiveImage(
  String path, {
  Key? key,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  FilterQuality filterQuality = FilterQuality.low,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  if (isNetworkImagePath(path)) {
    return Image.network(
      path,
      key: key,
      width: width,
      height: height,
      fit: fit,
      filterQuality: filterQuality,
      errorBuilder: errorBuilder,
      // loadingBuilder's progress events don't fire reliably on Flutter
      // Web, so frameBuilder (which does) is used to detect "not decoded
      // yet" instead.
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return _loadingSpinner(width, height);
      },
    );
  }
  return Image.asset(
    path,
    key: key,
    width: width,
    height: height,
    fit: fit,
    filterQuality: filterQuality,
    errorBuilder: errorBuilder,
  );
}

/// Renders [path] as an SVG, using [SvgPicture.network] for remote URLs and
/// [SvgPicture.asset] for bundled paths. Network SVGs show a spinner while
/// loading instead of a blank area.
Widget buildAdaptiveSvg(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
}) {
  if (isNetworkImagePath(path)) {
    return SvgPicture.network(
      path,
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder: (context) => _loadingSpinner(width, height),
    );
  }
  return SvgPicture.asset(path, width: width, height: height, fit: fit);
}
