import 'package:flutter/material.dart';
import '../../data/landing/timeline_data.dart';
import '../../core/responsive_web_utils.dart';
import '../../core/theme.dart';
import '../ui/animated_gradient.dart';
import 'timeline_tooltips.dart';

class TimelineSingleYear extends StatefulWidget {
  final TimelineData data;

  const TimelineSingleYear({super.key, required this.data});

  @override
  State<TimelineSingleYear> createState() => _TimelineSingleYearState();
}

class _TimelineSingleYearState extends State<TimelineSingleYear> {
  late int _selectedYear;
  late int _minYear;
  late int _maxYear;
  final Set<String> _disabledProjectTypes = <String>{};

  static const _projectTypePalette = <Color>[
    Color(0xFF2563EB),
    Color(0xFF06B6D4),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];
  static const _workColor = Color(0xFF8B5CF6);
  static const _eduColor = Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();
    final minDate = widget.data.minDate;
    final maxDate = widget.data.maxDate;

    if (minDate == null || maxDate == null) {
      _minYear = DateTime.now().year;
      _maxYear = DateTime.now().year;
      _selectedYear = DateTime.now().year;
    } else {
      _minYear = minDate.year;
      _maxYear = maxDate.year;
      _selectedYear = _maxYear;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWebUtils.isMobile(context);
    final typeColorMap = _buildTypeColorMap();
    final filteredEntries = widget.data.entries
        .where((entry) => !_disabledProjectTypes.contains(entry.projectType))
        .where((entry) => entry.start.year == _selectedYear)
        .toList();

    final titleStyle = TextStyle(
      fontSize: isMobile ? 20 : 22,
      fontWeight: FontWeight.bold,
      color: Colors.blueGrey,
    );

    if (widget.data.entries.isEmpty) {
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
                // Year navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildYearButton(
                      icon: Icons.arrow_back_ios_new,
                      onPressed: _selectedYear < _maxYear
                          ? () => setState(() => _selectedYear++)
                          : null,
                    ),
                    Text(
                      '$_selectedYear',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    _buildYearButton(
                      icon: Icons.arrow_forward_ios,
                      onPressed: _selectedYear > _minYear
                          ? () => setState(() => _selectedYear--)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Timeline visualization
                LayoutBuilder(
                  builder: (context, constraints) => _buildSingleYearTimeline(
                    context,
                    filteredEntries,
                    typeColorMap,
                    isMobile,
                    constraints.maxWidth,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLegend(context, typeColorMap),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return MouseRegion(
      cursor: onPressed != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: onPressed != null
                ? Colors.blueGrey.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 20,
            color: onPressed != null ? Colors.blueGrey : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildSingleYearTimeline(
    BuildContext context,
    List<TimelineEntry> entries,
    Map<String, Color> typeColorMap,
    bool isMobile,
    double availableWidth,
  ) {
    final ranges = widget.data.ranges.where((r) {
      return (r.start.year <= _selectedYear) && (r.end.year >= _selectedYear);
    }).toList();

    const startPadding = 16.0;
    final segmentWidth = (availableWidth - startPadding * 2).clamp(
      200.0,
      double.infinity,
    );

    final lineColor = Colors.blueGrey.withValues(alpha: 0.25);
    final dateStyle = TextStyle(
      fontSize: isMobile ? 12 : 14,
      color: Colors.blueGrey,
      fontWeight: FontWeight.w600,
    );

    const lineY = 48.0;
    const dotY = lineY - 7;
    const monthTextY = lineY + 22;
    const labelWidth = 100.0;

    // Jan, Apr, Jul, Oct, Dec — covers full span including the rightmost edge
    final monthMarkers = [1, 4, 7, 10, 12];
    final monthMarkerWidgets = <Widget>[];

    for (final month in monthMarkers) {
      final monthIndex = month - 1;
      final monthPos = ((11 - monthIndex) + 0.5) / 12.0;
      final x = startPadding + (monthPos * segmentWidth);
      final monthName = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][month - 1];

      monthMarkerWidgets.add(
        Positioned(
          top: 0,
          left: x - (labelWidth / 2),
          width: labelWidth,
          child: Text(monthName, style: dateStyle, textAlign: TextAlign.center),
        ),
      );
    }

    return SizedBox(
      width: availableWidth,
      height: monthTextY + 36,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Timeline line
          Positioned(
            top: lineY,
            left: startPadding,
            right: startPadding,
            child: Container(height: 2, color: lineColor),
          ),
          // Month markers at top
          ...monthMarkerWidgets,
          // Work and education ranges
          ..._buildRangeSegmentsForYear(
            ranges: ranges,
            segmentWidth: segmentWidth,
            startPadding: startPadding,
            baseY: lineY,
            selectedYear: _selectedYear,
          ),
          // Project dots
          ..._buildPositionedDotsForYear(
            entries: entries,
            segmentWidth: segmentWidth,
            startPadding: startPadding,
            dotY: dotY,
            monthTextY: monthTextY,
            typeColorMap: typeColorMap,
            selectedYear: _selectedYear,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRangeSegmentsForYear({
    required List<TimelineRange> ranges,
    required double segmentWidth,
    required double startPadding,
    required double baseY,
    required int selectedYear,
  }) {
    const lineHeight = 6.0;
    const offset = 8.0;
    final eduY = baseY + offset;
    final workY = baseY + (offset * 2);
    final widgets = <Widget>[];

    // Axis is reversed: Dec is on the LEFT (startPadding),
    //                   Jan is on the RIGHT (startPadding + segmentWidth).
    // When a range starts before selectedYear → clamp right end to Jan edge.
    // When a range ends after selectedYear   → clamp left end to Dec edge.
    final janEdge = startPadding + segmentWidth;
    final decEdge = startPadding;

    for (final range in ranges) {
      final extendsPastJan = range.start.year < selectedYear;
      final extendsPastDec = range.end.year > selectedYear;

      final startX = extendsPastJan
          ? janEdge
          : _getMonthPosition(range.start.month, segmentWidth, startPadding);

      final endX = extendsPastDec
          ? decEdge
          : _getMonthPosition(range.end.month, segmentWidth, startPadding);

      final left = startX < endX ? startX : endX;
      final width = (startX - endX).abs().clamp(4.0, double.infinity);
      final color = range.kind == RangeKind.work ? _workColor : _eduColor;
      final y = range.kind == RangeKind.work ? workY : eduY;

      // Square off ends that are clamped to the edge; round the actual ends.
      final borderRadius = BorderRadius.horizontal(
        left: extendsPastDec ? Radius.zero : const Radius.circular(999),
        right: extendsPastJan ? Radius.zero : const Radius.circular(999),
      );

      widgets.add(
        Positioned(
          top: y,
          left: left,
          child: HoverTooltipWidget(
            content: RangeTooltipWidget(
              title: range.label,
              subtitle: TimelineData.formatRangeDates(range.start, range.end),
              iconPath: range.iconPath,
              kind: range.kind,
            ),
            child: Container(
              width: width,
              height: lineHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: borderRadius,
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  List<Widget> _buildPositionedDotsForYear({
    required List<TimelineEntry> entries,
    required double segmentWidth,
    required double startPadding,
    required double dotY,
    required double monthTextY,
    required Map<String, Color> typeColorMap,
    required int selectedYear,
  }) {
    const dotSize = 14.0;
    final widgets = <Widget>[];

    // Calculate positions for all entries
    final entriesWithPositions = <List<dynamic>>[];
    for (final entry in entries) {
      final x =
          _getMonthPosition(entry.start.month, segmentWidth, startPadding) -
          ((entry.start.day - 1) /
                  DateTime(entry.start.year, entry.start.month + 1, 0).day) *
              (segmentWidth / 12);
      entriesWithPositions.add([entry, x]);
    }

    // Sort by position (descending = right to left, older to newer)
    entriesWithPositions.sort(
      (a, b) => (b[1] as double).compareTo(a[1] as double),
    );

    // Adjust overlaps by moving more recent items (smaller x) further left
    for (var i = 0; i < entriesWithPositions.length - 1; i++) {
      final current = entriesWithPositions[i];
      final next = entriesWithPositions[i + 1];
      final currentX = current[1] as double;
      final nextX = next[1] as double;
      final distance = (currentX - nextX).abs();

      if (distance < dotSize) {
        final newNextX = currentX - dotSize;
        next[1] = newNextX;
      }
    }

    // Render dots at their adjusted positions
    for (final item in entriesWithPositions) {
      final entry = item[0] as TimelineEntry;
      final x = item[1] as double;
      final dotColor = typeColorMap[entry.projectType] ?? AppColors.accent;

      widgets.add(
        Positioned(
          top: dotY,
          left: x - (dotSize / 2),
          child: HoverTooltipWidget(
            content: ProjectTooltipWidget(
              title: entry.title,
              subtitle: entry.subtitle,
              version: entry.version,
              dateLabel: TimelineData.formatDayMonthYear(entry.start),
              thumbnailPath: entry.thumbnailPath,
              videoLink: entry.videoLink,
            ),
            child: GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, '/projects/${entry.slug}'),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: _buildDot(dotColor),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  double _getMonthPosition(
    int month,
    double segmentWidth,
    double startPadding,
  ) {
    final monthIndex = month - 1;
    final monthPos = ((11 - monthIndex) + 0.5) / 12.0;
    return startPadding + (monthPos * segmentWidth);
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  Map<String, Color> _buildTypeColorMap() {
    final types = widget.data.entries.map((e) => e.projectType).toSet().toList()
      ..sort();
    if (types.remove('Other')) {
      types.add('Other');
    }
    final map = <String, Color>{};
    for (var i = 0; i < types.length; i++) {
      map[types[i]] = _projectTypePalette[i % _projectTypePalette.length];
    }
    return map;
  }

  Widget _buildLegend(BuildContext context, Map<String, Color> typeColorMap) {
    final isMobile = ResponsiveWebUtils.isMobile(context);
    final labelStyle = TextStyle(
      fontSize: isMobile ? 12 : 13,
      fontWeight: FontWeight.w600,
      color: Colors.blueGrey,
    );
    final itemStyle = TextStyle(
      fontSize: isMobile ? 12 : 13,
      color: AppColors.textSecondary,
    );

    final legendEntries = typeColorMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Legend', style: labelStyle),
        const SizedBox(height: 4),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (final entry in legendEntries)
              _legendDotItem(
                label: entry.key,
                color: entry.value,
                textStyle: itemStyle,
                disabled: _disabledProjectTypes.contains(entry.key),
                onTap: () {
                  setState(() {
                    if (_disabledProjectTypes.contains(entry.key)) {
                      _disabledProjectTypes.remove(entry.key);
                    } else {
                      _disabledProjectTypes.add(entry.key);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _legendLineItem('Work', _workColor, itemStyle),
            _legendLineItem('Education', _eduColor, itemStyle),
          ],
        ),
      ],
    );
  }

  Widget _legendLineItem(String label, Color color, TextStyle textStyle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: textStyle),
      ],
    );
  }

  Widget _legendDotItem({
    required String label,
    required Color color,
    required TextStyle textStyle,
    required bool disabled,
    required VoidCallback onTap,
  }) {
    final displayColor = disabled ? Colors.grey : color;
    final displayTextStyle = disabled
        ? textStyle.copyWith(color: Colors.grey)
        : textStyle;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(displayColor),
            const SizedBox(width: 6),
            Text(label, style: displayTextStyle),
          ],
        ),
      ),
    );
  }
}
