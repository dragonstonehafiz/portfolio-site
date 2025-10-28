import 'package:flutter/widgets.dart';

/// Shared responsive helpers for the portfolio site.
class ResponsiveWebUtils {
  static const double mobileBreakpoint = 768;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
}
