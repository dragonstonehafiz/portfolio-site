import 'package:flutter/widgets.dart';

/// Shared responsive helpers for the portfolio site.
class ResponsiveWebUtils {
  static const double mobileBreakpoint = 768;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Returns responsive padding that scales based on screen width.
  /// Horizontal padding is intentionally zero to allow edge-to-edge layouts.
  /// Vertical spacing is preserved.
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < mobileBreakpoint;
    return EdgeInsets.symmetric(vertical: isMobile ? 24.0 : 32.0);
  }

  /// Returns responsive horizontal padding for content that needs consistent left/right spacing.
  /// Intentionally zero for full-width site layout.
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    return EdgeInsets.zero;
  }
}
