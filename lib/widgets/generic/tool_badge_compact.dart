import 'package:flutter/material.dart';
import 'tool_badge_base.dart';

/// A compact tool badge without icon (minimal style)
class ToolBadgeCompact extends StatelessWidget {
  final String toolKey;
  final double fontSize;

  const ToolBadgeCompact({
    super.key,
    required this.toolKey,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return ToolBadge(
      toolKey: toolKey,
      showIcon: false,
      fontSize: fontSize,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 8,
    );
  }
}
