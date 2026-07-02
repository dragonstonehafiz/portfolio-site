import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Whether [path] is a remote URL (e.g. a Supabase Storage public URL)
/// rather than a bundled local asset path.
bool isNetworkImagePath(String path) =>
    path.startsWith('http://') || path.startsWith('https://');

/// Renders [path] as a raster image, using [Image.network] for remote URLs
/// and [Image.asset] for bundled paths.
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
/// [SvgPicture.asset] for bundled paths.
Widget buildAdaptiveSvg(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
}) {
  if (isNetworkImagePath(path)) {
    return SvgPicture.network(path, width: width, height: height, fit: fit);
  }
  return SvgPicture.asset(path, width: width, height: height, fit: fit);
}
