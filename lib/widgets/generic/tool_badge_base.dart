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
            // Use ErrorWidget.builder to handle SVG loading failures gracefully
            _SafeSvgIcon(
              iconUrl: config.iconUrl!,
              size: iconSize,
              color: config.textColor,
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

/// A wrapper widget that safely loads SVG icons and handles errors gracefully
class _SafeSvgIcon extends StatelessWidget {
  final String iconUrl;
  final double size;
  final Color color;

  const _SafeSvgIcon({
    required this.iconUrl,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the URL is for a local asset or network URL
    final isAsset = iconUrl.startsWith('assets/');
    final isSvg = iconUrl.toLowerCase().endsWith('.svg');

    return SizedBox(
      width: size,
      height: size,
      child: isAsset
          ? (isSvg
                ? SvgPicture.asset(
                    iconUrl,
                    width: size,
                    height: size,
                  color: color,
                    fit: BoxFit.contain,
                    placeholderBuilder: (context) =>
                        SizedBox(width: size, height: size),
                  )
                : Image.asset(
                    iconUrl,
                    width: size,
                    height: size,
                    color: color,
                    colorBlendMode: BlendMode.srcIn,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ))
          : (isSvg
                ? SvgPicture.network(
                    iconUrl,
                    width: size,
                    height: size,
                    color: color,
                    fit: BoxFit.contain,
                    placeholderBuilder: (context) =>
                        SizedBox(width: size, height: size),
                  )
                : Image.network(
                    iconUrl,
                    width: size,
                    height: size,
                    color: color,
                    colorBlendMode: BlendMode.srcIn,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(width: size, height: size);
                    },
                  )),
    );
  }
}
