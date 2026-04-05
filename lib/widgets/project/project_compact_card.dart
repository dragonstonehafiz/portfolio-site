import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/projects/project_data.dart';
import '../generic/tool_badge_compact.dart';
import '../ui/animated_gradient.dart';
import '../ui/hover_card.dart';
import 'project_thumbnail_preview.dart';

/// Compact clickable project card.
/// Input: [ProjectData]
/// Output: small clickable project card that routes to the detail page.
class ProjectCompactCard extends StatelessWidget {
  final ProjectData project;
  final double width;
  final double height;

  const ProjectCompactCard({
    super.key,
    required this.project,
    this.width = 190,
    this.height = 210,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: HoverCardWidget(
        borderRadius: 0,
        onTap: () => Navigator.pushNamed(context, '/projects/${project.slug}'),
        child: AnimatedGradient(
          gradient: Theme.of(context).previewGradient,
          borderRadius: BorderRadius.zero,
          duration: const Duration(seconds: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) =>
                      _buildMedia(constraints.maxHeight),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 18,
                      child: _LoopingTicker(
                        tickerId: 'title:${project.slug}:${project.version}',
                        velocity: 26,
                        child: Text(
                          project.title,
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                          softWrap: false,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (project.tools.isNotEmpty)
                      SizedBox(
                        height: 22,
                        child: _LoopingTicker(
                          tickerId:
                              'tools:${project.slug}:${project.tools.join("|")}',
                          velocity: 24,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: project.tools
                                .map(
                                  (tool) => Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ToolBadgeCompact(
                                      toolKey: tool,
                                      fontSize: 10,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 18,
                        child: _LoopingTicker(
                          tickerId: 'version:${project.slug}:${project.version}',
                          velocity: 24,
                          child: Text(
                            project.version,
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                            softWrap: false,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedia(double mediaHeight) {
    final hasMedia =
        project.imgPaths.isNotEmpty ||
        (project.vidLink != null && project.vidLink!.isNotEmpty);

    final mediaChild = hasMedia
        ? ProjectThumbnailPreview(
            imgPaths: project.imgPaths.isNotEmpty ? project.imgPaths : null,
            videoLink: project.vidLink,
            width: width,
            height: mediaHeight,
            borderRadius: BorderRadius.zero,
          )
        : Container(color: _placeholderColorForType(project.projectType));

    return Stack(
      children: [
        Positioned.fill(child: mediaChild),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              _shortType(project.projectType),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _shortType(String type) {
    if (type.isEmpty) return 'PROJECT';
    final t = type.trim().toLowerCase();
    if (t == 'artificial intelligence') return 'AI';
    return t.length <= 10
        ? type.toUpperCase()
        : type.substring(0, 10).toUpperCase();
  }

  Color _placeholderColorForType(String type) {
    final t = type.toLowerCase();
    if (t == 'ai' || t.contains('artificial intelligence')) {
      return const Color(0xFF0D1C34);
    }
    if (t == 'productivity') {
      return const Color(0xFF15261A);
    }
    if (t == 'games' || t == 'game') {
      return const Color(0xFF2A182E);
    }
    if (t == 'miscellaneous' || t == 'misc') {
      return const Color(0xFF2E2517);
    }
    return AppColors.background;
  }
}

class _LoopingTicker extends StatefulWidget {
  final String tickerId;
  final double velocity;
  final Widget child;

  const _LoopingTicker({
    required this.tickerId,
    required this.velocity,
    required this.child,
  });

  @override
  State<_LoopingTicker> createState() => _LoopingTickerState();
}

class _LoopingTickerState extends State<_LoopingTicker> {
  static const double _gap = 20;
  final GlobalKey _contentKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  Timer? _timer;
  double _offset = 0;
  double _viewportWidth = 0;
  double _contentWidth = 0;
  bool _shouldScroll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndConfigure());
  }

  @override
  void didUpdateWidget(covariant _LoopingTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tickerId != widget.tickerId) {
      _offset = 0;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      _contentWidth = 0;
      _shouldScroll = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndConfigure());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _scrollController.dispose();
    super.dispose();
  }

  void _measureAndConfigure() {
    if (!mounted) return;
    final ro = _contentKey.currentContext?.findRenderObject();
    if (ro is! RenderBox) return;

    final measuredWidth = ro.size.width;
    final shouldScroll = measuredWidth > (_viewportWidth + 2);
    final changed =
        measuredWidth != _contentWidth || shouldScroll != _shouldScroll;

    _contentWidth = measuredWidth;
    _shouldScroll = shouldScroll;

    if (!_shouldScroll) {
      _timer?.cancel();
      _timer = null;
      _offset = 0;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      if (changed) setState(() {});
      return;
    }

    _startTicker();

    if (changed) setState(() {});
  }

  void _startTicker() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted || !_shouldScroll) return;
      if (!_scrollController.hasClients) return;

      final cycle = _contentWidth + _gap;
      if (cycle <= 0) return;

      _offset += widget.velocity * 0.016;
      if (_offset >= cycle) {
        _offset -= cycle;
      }

      final max = _scrollController.position.maxScrollExtent;
      final target = _offset.clamp(0.0, max).toDouble();
      _scrollController.jumpTo(target);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_viewportWidth != constraints.maxWidth) {
          _viewportWidth = constraints.maxWidth;
          WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndConfigure());
        }

        if (!_shouldScroll) {
          return ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: KeyedSubtree(key: _contentKey, child: widget.child),
              ),
            ),
          );
        }

        return ClipRect(
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                KeyedSubtree(key: _contentKey, child: widget.child),
                const SizedBox(width: _gap),
                widget.child,
              ],
            ),
          ),
        );
      },
    );
  }
}
