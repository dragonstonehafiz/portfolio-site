import 'package:flutter/widgets.dart';

/// Shared responsive helpers for the portfolio site.
class ResponsiveWebUtils {
  static const double mobileBreakpoint = 768;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Returns responsive padding that scales based on screen width.
  /// On mobile: provides consistent padding on all sides (including left/right)
  /// On desktop: adds significant horizontal padding to prevent content from being too wide
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < mobileBreakpoint) {
      // Mobile: consistent padding on all sides including left and right
      return const EdgeInsets.all(24.0);
    } else {
      // Desktop: add significant horizontal padding to prevent content from being too wide
      final horizontalPadding = (screenWidth * 0.1).clamp(32.0, 120.0);
      return EdgeInsets.fromLTRB(horizontalPadding, 32.0, horizontalPadding, 32.0);
    }
  }

  /// Returns responsive horizontal padding for content that needs consistent left/right spacing.
  /// Useful for sections within already padded containers.
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < mobileBreakpoint) {
      // Mobile: minimal horizontal padding
      return const EdgeInsets.symmetric(horizontal: 16.0);
    } else {
      // Desktop: moderate horizontal padding
      final horizontalPadding = (screenWidth * 0.05).clamp(16.0, 60.0);
      return EdgeInsets.symmetric(horizontal: horizontalPadding);
    }
  }
}
