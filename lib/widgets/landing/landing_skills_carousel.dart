import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/projects/project_data.dart';
import '../project/project_preview_card.dart';

/// Auto-cycling carousel for displaying related projects in skills section
class LandingSkillsCarousel extends StatefulWidget {
  final List<ProjectData> projects;

  const LandingSkillsCarousel({super.key, required this.projects});

  @override
  State<LandingSkillsCarousel> createState() => _LandingSkillsCarouselState();
}

class _LandingSkillsCarouselState extends State<LandingSkillsCarousel> {
  static const Duration _autoAdvanceDuration = Duration(seconds: 6);
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant LandingSkillsCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projects != widget.projects) {
      _index = 0;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.projects.length > 1) {
      _timer = Timer.periodic(_autoAdvanceDuration, (_) {
        setState(() {
          _index = (_index + 1) % widget.projects.length;
        });
      });
    }
  }

  void _prev() {
    setState(() {
      _index = (_index - 1) % widget.projects.length;
      if (_index < 0) _index = widget.projects.length - 1;
    });
  }

  void _next() {
    setState(() {
      _index = (_index + 1) % widget.projects.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.projects.isEmpty) return const SizedBox.shrink();
    final project = widget.projects[_index];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: widget.projects.length > 1 ? _prev : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: ConstrainedBox(
              key: ValueKey(project.slug),
              constraints: const BoxConstraints(maxWidth: 560),
              child: ProjectPreviewCard(project: project),
            ),
          ),
        ),
        IconButton(
          onPressed: widget.projects.length > 1 ? _next : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
