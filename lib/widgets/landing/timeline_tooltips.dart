import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme.dart';
import '../../data/landing/timeline_data.dart';
import '../../data/projects/project_data.dart';
import '../project/project_compact_card.dart';

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
  final String version;
  final String projectType;
  final List<String> tools;
  final String slug;
  final String? thumbnailPath;
  final String? videoLink;

  const ProjectTooltipWidget({
    super.key,
    required this.title,
    required this.version,
    required this.projectType,
    required this.tools,
    required this.slug,
    required this.thumbnailPath,
    required this.videoLink,
  });

  @override
  Widget build(BuildContext context) {
    final tooltipProject = ProjectData(
      variableName: slug,
      title: title,
      date: '',
      imgPaths: thumbnailPath != null && thumbnailPath!.isNotEmpty
          ? [thumbnailPath!]
          : const [],
      whatIDid: const [],
      tools: tools,
      tags: const [],
      projectType: projectType,
      version: version,
      vignette: '',
      pageList: const [],
      downloadPaths: const [],
      vidLink: videoLink,
    );

    return ProjectCompactCard(project: tooltipProject, width: 250, height: 190);
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
