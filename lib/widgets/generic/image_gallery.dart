import 'dart:async';
import 'package:flutter/foundation.dart';
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
    final thumbWidth = widget.thumbnailWidth;
    final target = (_currentIndex * (thumbWidth + 12)).toDouble();
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
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
        ),
        if (showProgress) ...[
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: _progressController.value,
                  minHeight: 3,
                  backgroundColor: Colors.white.withOpacity(0.6),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          height: widget.thumbnailHeight,
          child: ListView.separated(
            controller: _thumbController,
            scrollDirection: Axis.horizontal,
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
                  width: widget.thumbnailWidth,
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
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: widget.imagePaths.length,
          ),
        ),
      ],
    );
  }
}
