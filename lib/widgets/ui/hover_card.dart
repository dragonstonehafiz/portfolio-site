import 'package:flutter/material.dart';

/// A hoverable card widget for web that scales and lifts on mouse hover.
class HoverCardWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;

  const HoverCardWidget({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 12.0,
  });

  @override
  State<HoverCardWidget> createState() => _HoverCardWidgetState();
}

class _HoverCardWidgetState extends State<HoverCardWidget> {
  bool _hover = false;

  void _setHover(bool v) => setState(() => _hover = v);

  Widget _buildCard({required double scale, required double elevation}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      transform: Matrix4.identity()..scaleByDouble(scale, scale, 1.0, 1.0),
      curve: Curves.easeOut,
      child: Material(
        elevation: elevation,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: widget.child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      cursor: SystemMouseCursors.click,
      child: _buildCard(
        scale: _hover ? 1.02 : 1.0,
        elevation: _hover ? 18.0 : 8.0,
      ),
    );
  }
}
