import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme.dart';
import '../../data/landing/timeline_data.dart';
import '../project/project_thumbnail_preview.dart';

/// Tooltip content for work and education range segments.
class RangeTooltipWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? iconPath;
  final RangeKind kind;

  const RangeTooltipWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.iconPath,
    required this.kind,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;
    final path = iconPath;
    if (path != null && path.isNotEmpty) {
      final ext = path.toLowerCase().split('.').last;
      if (ext == 'svg') {
        iconWidget = SvgPicture.asset(
          path,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        );
      } else {
        iconWidget = Image.asset(
          path,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        );
      }
    } else {
      iconWidget = Icon(
        kind == RangeKind.work ? Icons.work_outline : Icons.school_outlined,
        size: 24,
        color: Colors.blueGrey,
      );
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: DefaultTextStyle(
          style: const TextStyle(color: AppColors.textPrimary),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 28, height: 28, child: iconWidget),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tooltip content for project release dots.
class ProjectTooltipWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String version;
  final String dateLabel;
  final String? thumbnailPath;
  final String? videoLink;

  const ProjectTooltipWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.version,
    required this.dateLabel,
    required this.thumbnailPath,
    required this.videoLink,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 6,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: DefaultTextStyle(
            style: const TextStyle(color: AppColors.textPrimary),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProjectThumbnailPreview(
                  imgPaths: thumbnailPath != null && thumbnailPath!.isNotEmpty
                      ? [thumbnailPath!]
                      : null,
                  videoLink: videoLink,
                  width: 220,
                  height: 120,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (version.trim().isNotEmpty)
                  Text(
                    'Release: $version',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  dateLabel,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlay tooltip that follows the cursor on hover.
class HoverTooltipWidget extends StatefulWidget {
  final Widget child;
  final Widget content;

  const HoverTooltipWidget({
    super.key,
    required this.child,
    required this.content,
  });

  @override
  State<HoverTooltipWidget> createState() => _HoverTooltipWidgetState();
}

class _HoverTooltipWidgetState extends State<HoverTooltipWidget> {
  OverlayEntry? _entry;

  void _showOverlay(PointerHoverEvent event) {
    final overlay = Overlay.of(context);
    _entry?.remove();

    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (overlayBox == null) return;
    final overlayOrigin = overlayBox.localToGlobal(Offset.zero);
    final position = event.position - overlayOrigin + const Offset(0, 12);

    _entry = OverlayEntry(
      builder: (_) => Positioned(
        left: position.dx,
        top: position.dy,
        child: IgnorePointer(child: widget.content),
      ),
    );
    overlay.insert(_entry!);
  }

  void _hideOverlay() {
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _showOverlay,
      onExit: (_) => _hideOverlay(),
      child: widget.child,
    );
  }
}
