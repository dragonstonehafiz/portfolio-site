import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// A reusable image gallery widget with auto-advancing carousel and thumbnail selector.
/// Features:
/// - Auto-advancing carousel every 8 seconds (configurable)
/// - Progress indicator showing advancement
/// - Horizontal thumbnail strip for manual navigation
/// - Click to view full-size images in an interactive dialog
class ImageGallery extends StatefulWidget {
  final List<String> imagePaths;
  final Duration autoAdvanceDuration;
  final double thumbnailHeight;
  final double thumbnailWidth;

  const ImageGallery({
    required this.imagePaths,
    this.autoAdvanceDuration = const Duration(seconds: 8),
    this.thumbnailHeight = 90,
    this.thumbnailWidth = 96,
    super.key,
  });

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> with SingleTickerProviderStateMixin {
  static const double _desktopBreakpoint = 900;
  static const double _desktopThumbnailSpacing = 12;
  static const double _desktopThumbnailRailWidth = 124;
  static const double _desktopGalleryGap = 20;
  static const double _maxPreviewWidth = 720;
  static const double _maxPreviewHeight = 420;
  static const double _desktopScrollbarThickness = 10;

  late int _currentIndex;
  Timer? _timer;
  final ScrollController _thumbController = ScrollController();
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _progressController = AnimationController(
      vsync: this,
      duration: widget.autoAdvanceDuration,
    );
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant ImageGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.imagePaths, widget.imagePaths)) {
      _currentIndex = 0;
      _startTimer();
      _scrollThumbnailIntoView();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _thumbController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.imagePaths.length > 1) {
      _progressController.forward(from: 0);
      _timer = Timer.periodic(widget.autoAdvanceDuration, (_) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.imagePaths.length;
        });
        _progressController.forward(from: 0);
        _scrollThumbnailIntoView();
      });
    } else {
      _progressController.value = 0;
    }
  }

  void _scrollThumbnailIntoView() {
    if (!_thumbController.hasClients) return;
    final axis = _thumbController.position.axis;
    final itemExtent = axis == Axis.horizontal
        ? widget.thumbnailWidth + 12
        : widget.thumbnailHeight + _desktopThumbnailSpacing;
    final target = (_currentIndex * itemExtent).toDouble();
    _thumbController.animateTo(
      target.clamp(0, _thumbController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _showFullImage(String assetPath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_not_supported),
                        const SizedBox(height: 8),
                        Text(
                          'Missing:\n$assetPath',
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedPath = 'assets/${widget.imagePaths[_currentIndex]}';
    final showProgress = widget.imagePaths.length > 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _desktopBreakpoint) {
          return _buildDesktopLayout(
            context,
            selectedPath: selectedPath,
            showProgress: showProgress,
            maxWidth: constraints.maxWidth,
          );
        }

        return _buildMobileLayout(
          context,
          selectedPath: selectedPath,
          showProgress: showProgress,
        );
      },
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context, {
    required String selectedPath,
    required bool showProgress,
    required double maxWidth,
  }) {
    final previewWidth =
        (maxWidth - _desktopGalleryGap - _desktopThumbnailRailWidth)
            .clamp(320.0, _maxPreviewWidth);
    final totalWidth =
        previewWidth + _desktopGalleryGap + _desktopThumbnailRailWidth;

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: totalWidth,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: previewWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _maxPreviewWidth,
                      maxHeight: _maxPreviewHeight,
                    ),
                    child: _buildMainImage(selectedPath),
                  ),
                  if (showProgress) ...[
                    const SizedBox(height: 12),
                    _buildProgressIndicator(),
                  ],
                ],
              ),
            ),
            const SizedBox(width: _desktopGalleryGap),
            SizedBox(
              width: _desktopThumbnailRailWidth,
              height: _maxPreviewHeight,
              child: _buildThumbnailRail(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context, {
    required String selectedPath,
    required bool showProgress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMainImage(selectedPath),
        if (showProgress) ...[
          const SizedBox(height: 8),
          _buildProgressIndicator(),
        ],
        const SizedBox(height: 16),
        SizedBox(
          height: widget.thumbnailHeight,
          child: _buildThumbnailList(
            scrollDirection: Axis.horizontal,
            separator: const SizedBox(width: 12),
            thumbnailWidth: widget.thumbnailWidth,
            thumbnailHeight: widget.thumbnailHeight,
          ),
        ),
      ],
    );
  }

  Widget _buildMainImage(String selectedPath) {
    return GestureDetector(
      onTap: () => _showFullImage(selectedPath),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Image.asset(
              selectedPath,
              key: ValueKey(selectedPath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_not_supported),
                        const SizedBox(height: 8),
                        Text(
                          'Missing:\n${widget.imagePaths[_currentIndex]}',
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: _progressController.value,
            minHeight: 3,
            backgroundColor: Colors.white.withValues(alpha: 0.6),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
        );
      },
    );
  }

  Widget _buildThumbnailRail() {
    const double listRightPadding = _desktopScrollbarThickness + 8;

    return Scrollbar(
      controller: _thumbController,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      thickness: _desktopScrollbarThickness,
      radius: const Radius.circular(999),
      scrollbarOrientation: ScrollbarOrientation.right,
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
        child: Padding(
          padding: const EdgeInsets.only(right: listRightPadding),
          child: _buildThumbnailList(
            scrollDirection: Axis.vertical,
            separator: const SizedBox(height: _desktopThumbnailSpacing),
            thumbnailWidth: _desktopThumbnailRailWidth - listRightPadding,
            thumbnailHeight: widget.thumbnailHeight,
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailList({
    required Axis scrollDirection,
    required Widget separator,
    required double thumbnailWidth,
    required double thumbnailHeight,
  }) {
    return ListView.separated(
      controller: _thumbController,
      scrollDirection: scrollDirection,
      itemBuilder: (context, index) {
        final assetPath = 'assets/${widget.imagePaths[index]}';
        final isActive = index == _currentIndex;
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
            _startTimer();
            _scrollThumbnailIntoView();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: thumbnailWidth,
            height: thumbnailHeight,
            decoration: BoxDecoration(
              border: Border.all(
                color: isActive ? AppColors.accent : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        'Missing\n${widget.imagePaths[index]}',
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => separator,
      itemCount: widget.imagePaths.length,
    );
  }
}
