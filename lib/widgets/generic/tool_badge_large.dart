import 'package:flutter/material.dart';
import 'tool_badge_base.dart';

/// A large tool badge with larger icon (for featured display)
class ToolBadgeLarge extends StatelessWidget {
  final String toolKey;
  final double fontSize;

  const ToolBadgeLarge({super.key, required this.toolKey, this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    return ToolBadge(
      toolKey: toolKey,
      showIcon: true,
      fontSize: fontSize,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      borderRadius: 16,
    );
  }
}
