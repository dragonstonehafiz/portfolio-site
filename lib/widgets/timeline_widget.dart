import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../utils/landing_page_data.dart';
import '../utils/project_data.dart';
import '../utils/responsive_web_utils.dart';
import '../utils/theme.dart';
import '../widgets/animated_gradient.dart';

class TimelineWidget extends StatefulWidget {
  final LandingPageData data;
  final List<ProjectEntry> projects;

  const TimelineWidget({
    super.key,
    required this.data,
    required this.projects,
  });

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries();
    final isMobile = ResponsiveWebUtils.isMobile(context);
    final titleStyle = TextStyle(
      fontSize: isMobile ? 20 : 22,
      fontWeight: FontWeight.bold,
      color: Colors.blueGrey,
    );

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Timeline', style: titleStyle),
        const SizedBox(height: 12),
        AnimatedGradient(
          gradient: Theme.of(context).previewGradient,
          borderRadius: BorderRadius.circular(12),
          duration: const Duration(seconds: 8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 14 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: true,
                    dragDevices: {
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.touch,
                      PointerDeviceKind.trackpad,
                    },
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14, top: 18),
                        child: _buildTimelineRow(context, entries),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<_TimelineEntry> _buildEntries() {
    final entries = <_TimelineEntry>[];

    for (final entry in widget.projects) {
      if (!entry.shown) continue;
      final version = entry.defaultVersion;
      if (version.date.trim().isEmpty) continue;
      final start = _parseDate(version.date);
      if (start == null) continue;
      final subtitle = version.projectType.trim().isEmpty
          ? 'Project release'
          : version.projectType.trim();
      entries.add(_TimelineEntry(
        start: start,
        title: version.title,
        subtitle: subtitle,
      ));
    }

    entries.sort((a, b) => b.start.compareTo(a.start));
    return entries;
  }

  Widget _buildTimelineRow(BuildContext context, List<_TimelineEntry> entries) {
    final isMobile = ResponsiveWebUtils.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final segmentWidth = (screenWidth * (isMobile ? 0.75 : 0.45)).clamp(260.0, 440.0);
    final emptyYearWidth = (segmentWidth * 0.35).clamp(120.0, segmentWidth);
    final yearGap = isMobile ? 18.0 : 24.0;
    final lineColor = Colors.blueGrey.withOpacity(0.25);
    final titleStyle = TextStyle(
      fontSize: isMobile ? 14 : 15,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
    final subtitleStyle = TextStyle(
      fontSize: isMobile ? 12 : 13,
      color: AppColors.textSecondary,
    );
    final dateStyle = TextStyle(
      fontSize: isMobile ? 12 : 14,
      color: Colors.blueGrey,
      fontWeight: FontWeight.w600,
    );
    final yearLabelStyle = TextStyle(
      fontSize: isMobile ? 14 : 16,
      fontWeight: FontWeight.w800,
      color: Colors.blueGrey,
    );

    final ranges = _buildRanges();
    if (entries.isEmpty && ranges.isEmpty) return const SizedBox.shrink();

    final sorted = List<_TimelineEntry>.from(entries)
      ..sort((a, b) => b.start.compareTo(a.start));

    final allDates = <DateTime>[];
    for (final entry in sorted) {
      allDates.add(entry.start);
    }
    for (final range in ranges) {
      allDates.add(range.start);
      allDates.add(range.end);
    }
    allDates.sort((a, b) => a.compareTo(b));
    final minYear = allDates.first.year;
    final maxYear = allDates.last.year;
    final yearCount = (maxYear - minYear) + 1;
    final lineY = 48.0;
    final dotY = lineY - 7;
    final yearTextY = 0.0;
    final monthTextY = lineY + 22;
    final labelWidth = isMobile ? 80.0 : 100.0;
    final gapWidth = yearGap;
    final startPadding = gapWidth;
    final minLabelSpacing = isMobile ? 70.0 : 90.0;

    final years = <int>[];
    for (var y = maxYear; y >= minYear; y--) {
      years.add(y);
    }
    final projectYears = entries.map((e) => e.start.year).toSet();
    final yearWidths = <int, double>{};
    for (final y in years) {
      yearWidths[y] = projectYears.contains(y) ? segmentWidth : emptyYearWidth;
    }
    final yearStarts = <int, double>{};
    double cursor = startPadding;
    for (var i = 0; i < years.length; i++) {
      yearStarts[years[i]] = cursor;
      cursor += yearWidths[years[i]]!;
      if (i < years.length - 1) {
        cursor += gapWidth;
      }
    }
    final totalWidth = cursor;

    return SizedBox(
      width: totalWidth,
      height: monthTextY + 36,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: lineY,
            left: 0,
            right: 0,
            child: Row(
              children: [
                SizedBox(width: startPadding),
                for (var i = 0; i < years.length; i++) ...[
                  Container(width: yearWidths[years[i]]!, height: 2, color: lineColor),
                  if (i < years.length - 1) SizedBox(width: yearGap),
                ],
              ],
            ),
          ),
          ..._buildRangeSegments(
            ranges: ranges,
            minYear: minYear,
            maxYear: maxYear,
            segmentWidth: segmentWidth,
            yearGap: gapWidth,
            startPadding: startPadding,
            baseY: lineY,
            yearStarts: yearStarts,
            yearWidths: yearWidths,
          ),
          for (var i = 0; i < years.length; i++)
            Positioned(
              top: yearTextY,
              left: (yearStarts[years[i]]! + (yearWidths[years.first] ?? segmentWidth) - (gapWidth / 2)) - (labelWidth / 4),
              width: labelWidth,
              child: Transform.rotate(
                angle: -1.57079632679,
                alignment: Alignment.center,
                child: Text(
                  '${years[i]}',
                  textAlign: TextAlign.center,
                  style: yearLabelStyle,
                ),
              ),
            ),
          ..._buildPositionedDots(
            entries: sorted,
            minYear: minYear,
            maxYear: maxYear,
            segmentWidth: segmentWidth,
            yearGap: gapWidth,
            leadingGap: startPadding,
            dotY: dotY,
            labelWidth: labelWidth,
            monthTextY: monthTextY,
            minLabelSpacing: minLabelSpacing,
            titleStyle: titleStyle,
            subtitleStyle: subtitleStyle,
            dateStyle: dateStyle,
            yearStarts: yearStarts,
            yearWidths: yearWidths,
          ),
        ],
      ),
    );
  }

  DateTime? _parseDate(String? raw, {bool endOfMonth = false}) {
    if (raw == null || raw.trim().isEmpty) return null;
    final trimmed = raw.trim();
    try {
      if (RegExp(r'^\d{4}-\d{2}$').hasMatch(trimmed)) {
        if (endOfMonth) {
          final parts = trimmed.split('-');
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final lastDay = DateTime(year, month + 1, 0).day;
          return DateTime(year, month, lastDay);
        }
        return DateTime.parse('$trimmed-01');
      }
      return DateTime.parse(trimmed);
    } catch (_) {
      return null;
    }
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final m = (date.month >= 1 && date.month <= 12) ? months[date.month] : '';
    return m.isEmpty ? '${date.year}' : '$m ${date.year}';
  }

  String _formatRangeDates(DateTime start, DateTime end) {
    return '${_formatMonthYear(start)} — ${_formatMonthYear(end)}';
  }

  Widget _buildDot() {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  List<_TimeRange> _buildRanges() {
    final ranges = <_TimeRange>[];
    for (final work in widget.data.experience) {
      final start = _parseDate(work.start);
      if (start == null) continue;
      final end = _parseDate(work.end, endOfMonth: true) ?? DateTime.now();
      final label = '${work.title} — ${work.company}';
      ranges.add(_TimeRange(start: start, end: end, kind: _RangeKind.work, label: label));
    }
    for (final edu in widget.data.education) {
      final start = _parseDate(edu.start);
      if (start == null) continue;
      final end = _parseDate(edu.end, endOfMonth: true) ?? DateTime.now();
      final label = '${edu.course} — ${edu.school}';
      ranges.add(_TimeRange(start: start, end: end, kind: _RangeKind.education, label: label));
    }
    return ranges;
  }

  List<Widget> _buildRangeSegments({
    required List<_TimeRange> ranges,
    required int minYear,
    required int maxYear,
    required double segmentWidth,
    required double yearGap,
    required double startPadding,
    required double baseY,
    required Map<int, double> yearStarts,
    required Map<int, double> yearWidths,
  }) {
    const lineHeight = 4.0;
    final workColor = const Color(0xFF8B5CF6);
    final eduColor = const Color(0xFF22C55E);
    const offset = 8.0;
    final eduY = baseY + offset;
    final workY = baseY + (offset * 2);
    final widgets = <Widget>[];

    for (final range in ranges) {
      final startX = _xForDate(
        date: range.start,
        minYear: minYear,
        maxYear: maxYear,
        segmentWidth: segmentWidth,
        yearGap: yearGap,
        startPadding: startPadding,
        yearStarts: yearStarts,
        yearWidths: yearWidths,
      );
      final endX = _xForDate(
        date: range.end,
        minYear: minYear,
        maxYear: maxYear,
        segmentWidth: segmentWidth,
        yearGap: yearGap,
        startPadding: startPadding,
        yearStarts: yearStarts,
        yearWidths: yearWidths,
      );
      final left = startX < endX ? startX : endX;
      final width = (startX - endX).abs().clamp(4.0, double.infinity);
      final color = range.kind == _RangeKind.work ? workColor : eduColor;
      final y = range.kind == _RangeKind.work ? workY : eduY;

      widgets.add(
        Positioned(
          top: y,
          left: left,
          child: _HoverTooltip(
            content: _RangeTooltipContent(
              title: range.label,
              subtitle: _formatRangeDates(range.start, range.end),
            ),
            child: Container(
              width: width,
              height: lineHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  double _xForDate({
    required DateTime date,
    required int minYear,
    required int maxYear,
    required double segmentWidth,
    required double yearGap,
    required double startPadding,
    required Map<int, double> yearStarts,
    required Map<int, double> yearWidths,
  }) {
    final monthIndex = date.month - 1;
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    final dayFraction = ((date.day - 1).clamp(0, daysInMonth - 1)) / daysInMonth;
    final monthPos = ((11 - monthIndex) + dayFraction) / 12.0;
    final yearWidth = yearWidths[date.year] ?? segmentWidth;
    final offsetInYear = monthPos * yearWidth;
    final start = yearStarts[date.year] ?? startPadding;
    return start + offsetInYear;
  }

  List<Widget> _buildPositionedDots({
    required List<_TimelineEntry> entries,
    required int minYear,
    required int maxYear,
    required double segmentWidth,
    required double yearGap,
    required double leadingGap,
    required double dotY,
    required double labelWidth,
    required double monthTextY,
    required double minLabelSpacing,
    required TextStyle titleStyle,
    required TextStyle subtitleStyle,
    required TextStyle dateStyle,
    required Map<int, double> yearStarts,
    required Map<int, double> yearWidths,
  }) {
    const dotSize = 14.0;
    final widgets = <Widget>[];
    double? lastLabelX;

    for (final entry in entries) {
      final monthIndex = entry.start.month - 1;
      final monthPos = ((11 - monthIndex) + 0.5) / 12.0;
      final yearWidth = yearWidths[entry.start.year] ?? segmentWidth;
      final offsetInYear = monthPos * yearWidth;
      final start = yearStarts[entry.start.year] ?? leadingGap;
      final x = start + offsetInYear;
      final showLabel = lastLabelX == null || (x - lastLabelX!).abs() >= minLabelSpacing;
      if (showLabel) {
        lastLabelX = x;
      }

      widgets.add(
        Positioned(
          top: dotY,
          left: x - (dotSize / 2),
          child: Tooltip(
            richMessage: TextSpan(
              children: [
                TextSpan(text: entry.title, style: titleStyle),
                TextSpan(text: '\n${entry.subtitle}', style: subtitleStyle),
                TextSpan(
                  text: '\n${_formatMonthYear(entry.start)}',
                  style: subtitleStyle,
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            textStyle: const TextStyle(color: AppColors.textPrimary),
            child: _buildDot(),
          ),
        ),
      );

      if (showLabel) {
        widgets.add(
          Positioned(
            top: monthTextY,
            left: x - (labelWidth / 2),
            width: labelWidth,
            child: Text(
              _formatMonthYear(entry.start),
              style: dateStyle,
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }

    return widgets;
  }
}

class _TimelineEntry {
  final DateTime start;
  final String title;
  final String subtitle;

  _TimelineEntry({
    required this.start,
    required this.title,
    required this.subtitle,
  });
}

enum _RangeKind { work, education }

class _TimeRange {
  final DateTime start;
  final DateTime end;
  final _RangeKind kind;
  final String label;

  _TimeRange({
    required this.start,
    required this.end,
    required this.kind,
    required this.label,
  });
}

class _RangeTooltipContent extends StatelessWidget {
  final String title;
  final String subtitle;

  const _RangeTooltipContent({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: DefaultTextStyle(
          style: const TextStyle(color: AppColors.textPrimary),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverTooltip extends StatefulWidget {
  final Widget child;
  final Widget content;

  const _HoverTooltip({
    required this.child,
    required this.content,
  });

  @override
  State<_HoverTooltip> createState() => _HoverTooltipState();
}

class _HoverTooltipState extends State<_HoverTooltip> {
  OverlayEntry? _entry;

  void _showOverlay(PointerHoverEvent event) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;
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
