import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/projects/tool_config.dart';

/// A badge widget that displays a technology/tool with an icon and colored background
class ToolBadge extends StatelessWidget {
  final String toolKey;
  final bool showIcon;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double iconSize;

  const ToolBadge({
    super.key,
    required this.toolKey,
    this.showIcon = true,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.borderRadius = 12,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final config = getToolConfig(toolKey);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon && config.iconUrl != null) ...[
            SvgPicture.network(
              config.iconUrl!,
              width: iconSize,
              height: iconSize,
              color: config.textColor,
              placeholderBuilder: (context) =>
                  SizedBox(width: iconSize, height: iconSize),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            config.displayName,
            style: TextStyle(
              color: config.textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
