import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../data/projects/project_data.dart';
import '../project/project_compact_card.dart';

/// Reusable horizontally scrollable carousel for project compact cards.
class ProjectHorizontalCarousel extends StatefulWidget {
  final List<ProjectData> projects;
  final double cardWidth;
  final double spacing;
  final double minCardHeight;
  final double maxCardHeight;
  final double cardAspectRatio;

  const ProjectHorizontalCarousel({
    super.key,
    required this.projects,
    this.cardWidth = 340.0,
    this.spacing = 12.0,
    this.minCardHeight = 210.0,
    this.maxCardHeight = 280.0,
    this.cardAspectRatio = 0.9,
  });

  @override
  State<ProjectHorizontalCarousel> createState() =>
      _ProjectHorizontalCarouselState();
}

class _ProjectHorizontalCarouselState extends State<ProjectHorizontalCarousel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.projects.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final safeCardWidth = widget.cardWidth.clamp(140.0, 480.0).toDouble();
        final heightFromWidth = safeCardWidth / widget.cardAspectRatio;
        final parentMaxHeight =
            constraints.hasBoundedHeight ? constraints.maxHeight : widget.maxCardHeight;
        final effectiveMaxHeight =
            parentMaxHeight.clamp(widget.minCardHeight, widget.maxCardHeight).toDouble();
        final cardHeight = heightFromWidth.clamp(
          widget.minCardHeight,
          effectiveMaxHeight,
        ).toDouble();

        return SizedBox(
          height: cardHeight,
          child: Listener(
            onPointerSignal: (event) {
              if (event is! PointerScrollEvent || !_scrollController.hasClients) return;
              final dx = event.scrollDelta.dx;
              final dy = event.scrollDelta.dy;
              final delta = dx.abs() > dy.abs() ? dx : dy;
              if (delta == 0) return;

              final position = _scrollController.position;
              final target = (position.pixels + delta).clamp(
                position.minScrollExtent,
                position.maxScrollExtent,
              );
              _scrollController.jumpTo(target);
            },
            child: ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                scrollbars: false,
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.unknown,
                },
              ),
              child: ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.projects.length,
                itemBuilder: (context, index) {
                  final project = widget.projects[index];
                  return ProjectCompactCard(
                    project: project,
                    width: safeCardWidth,
                    height: cardHeight,
                  );
                },
                separatorBuilder: (_, __) => SizedBox(width: widget.spacing),
              ),
            ),
          ),
        );
      },
    );
  }
}
