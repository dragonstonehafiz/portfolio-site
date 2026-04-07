import 'package:flutter/widgets.dart';

/// Shared responsive helpers for the portfolio site.
class ResponsiveWebUtils {
  static const double mobileBreakpoint = 768;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Returns responsive padding that scales based on screen width.
  /// Adds moderate horizontal breathing room while keeping content full-width.
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < mobileBreakpoint;
    final horizontal = isMobile ? 16.0 : 64.0;
    final vertical = isMobile ? 16.0 : 24.0;
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  /// Returns responsive horizontal padding for content that needs consistent left/right spacing.
  /// Matches the site's global content gutter.
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < mobileBreakpoint;
    return EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 24.0);
  }
}
