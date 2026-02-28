import 'package:flutter/material.dart';
import 'tool_badge_base.dart';

/// A widget that displays multiple tool badges in a wrap layout
class ToolBadgeList extends StatelessWidget {
  final List<String> tools;
  final bool showIcons;
  final double fontSize;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  final EdgeInsetsGeometry badgePadding;

  const ToolBadgeList({
    super.key,
    required this.tools,
    this.showIcons = true,
    this.fontSize = 12,
    this.spacing = 8,
    this.runSpacing = 8,
    this.alignment = WrapAlignment.start,
    this.badgePadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  @override
  Widget build(BuildContext context) {
    if (tools.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      children: tools
          .map(
            (tool) => ToolBadge(
              toolKey: tool,
              showIcon: showIcons,
              fontSize: fontSize,
              padding: badgePadding,
            ),
          )
          .toList(),
    );
  }
}
