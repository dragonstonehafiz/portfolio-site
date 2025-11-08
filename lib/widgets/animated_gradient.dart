import 'dart:math';
import 'package:flutter/material.dart';

/// A lightweight animated gradient container that slightly moves the gradient
/// over time by animating its begin/end alignments. This creates a subtle
/// flowing effect without changing the colors themselves.
class AnimatedGradient extends StatefulWidget {
  final LinearGradient gradient;
  final Widget? child;
  final Duration duration;
  final Curve curve;
  final BorderRadius? borderRadius;
  final double? initialProgress;

  const AnimatedGradient({
    Key? key,
    required this.gradient,
    this.child,
    this.duration = const Duration(seconds: 6),
    this.curve = Curves.easeInOut,
    this.borderRadius,
    this.initialProgress,
  }) : super(key: key);

  @override
  State<AnimatedGradient> createState() => _AnimatedGradientState();
}

class _AnimatedGradientState extends State<AnimatedGradient>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _controller, curve: widget.curve);
    // Apply an initial phase offset so multiple instances don't animate
    // identically. If caller provided an initialProgress, use it; otherwise
    // pick a random starting point.
    final start = (widget.initialProgress != null)
        ? widget.initialProgress!.clamp(0.0, 1.0)
        : Random().nextDouble();
    // Set controller value to the chosen start. This sets the animation's
    // initial phase before it continues repeating.
    _controller.value = start;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        // Interpolate between a few alignment pairs to create motion.
        final t = _anim.value;

        final begin = Alignment.lerp(Alignment.topLeft, Alignment.topRight, t)!;
        final end = Alignment.lerp(Alignment.bottomRight, Alignment.bottomLeft, t)!;

        final animated = LinearGradient(
          begin: begin,
          end: end,
          colors: widget.gradient.colors,
          stops: widget.gradient.stops,
          tileMode: widget.gradient.tileMode,
        );

        return Container(
          decoration: BoxDecoration(
            gradient: animated,
            borderRadius: widget.borderRadius,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
