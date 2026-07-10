import '../projects/project_data.dart';
import 'landing_page_data.dart';

/// Timeline entry representing a single project version release.
class TimelineEntry {
  final DateTime start;
  final String title;
  final String subtitle;
  final String version;
  final String projectType;
  final List<String> tools;
  final String slug;
  final String? thumbnailPath;
  final String? videoLink;

  TimelineEntry({
    required this.start,
    required this.title,
    required this.subtitle,
    required this.version,
    required this.projectType,
    required this.tools,
    required this.slug,
    required this.thumbnailPath,
    required this.videoLink,
  });
}

enum RangeKind { work, education }

/// Timeline range representing a work or education period.
class TimelineRange {
  final DateTime start;
  final DateTime end;
  final RangeKind kind;
  final String label;
  final String? iconPath;
  final bool isOngoing;

  TimelineRange({
    required this.start,
    required this.end,
    required this.kind,
    required this.label,
    this.iconPath,
    this.isOngoing = false,
  });
}

/// Aggregated timeline data for rendering both timeline widgets.
class TimelineData {
  final List<TimelineEntry> entries;
  final List<TimelineRange> ranges;
  final DateTime? minDate;
  final DateTime? maxDate;

  TimelineData({
    required this.entries,
    required this.ranges,
    this.minDate,
    this.maxDate,
  });

  /// Build timeline data from landing page data and projects.
  static TimelineData fromLandingPageData(
    LandingPageData landingData,
    List<ProjectEntry> projects,
  ) {
    final entries = <TimelineEntry>[];
    final allDates = <DateTime>[];

    for (final project in projects) {
      if (!project.showInTimeline) continue;
      for (final version in project.versions) {
        if (version.date.trim().isEmpty) continue;
        final start = parseDate(version.date);
        if (start == null) continue;
        allDates.add(start);
        final rawType = version.projectType.trim();
        final projectType = rawType.isEmpty ? 'Other' : rawType;
        final subtitle = rawType.isEmpty ? 'Project release' : rawType;
        final thumbnailPath = version.imgPaths.isNotEmpty
            ? version.imgPaths.first
            : null;
        entries.add(
          TimelineEntry(
            start: start,
            title: version.title,
            subtitle: subtitle,
            version: version.version,
            projectType: projectType,
            tools: List<String>.from(version.tools),
            slug: version.slug,
            thumbnailPath: thumbnailPath,
            videoLink: version.vidLink,
          ),
        );
      }
    }

    final ranges = <TimelineRange>[];
    for (final work in landingData.experience) {
      final start = parseDate(work.start);
      if (start == null) continue;
      final parsedEnd = parseDate(work.end, endOfMonth: true);
      final end = parsedEnd ?? _endOfCurrentYear();
      allDates.add(start);
      allDates.add(end);
      final label = '${work.title}  ${work.company}';
      ranges.add(
        TimelineRange(
          start: start,
          end: end,
          kind: RangeKind.work,
          label: label,
          iconPath: work.icon,
          isOngoing: parsedEnd == null,
        ),
      );
    }
    for (final edu in landingData.education) {
      final start = parseDate(edu.start);
      if (start == null) continue;
      final parsedEnd = parseDate(edu.end, endOfMonth: true);
      final end = parsedEnd ?? _endOfCurrentYear();
      allDates.add(start);
      allDates.add(end);
      final label = '${edu.course}  ${edu.school}';
      ranges.add(
        TimelineRange(
          start: start,
          end: end,
          kind: RangeKind.education,
          label: label,
          iconPath: edu.icon,
          isOngoing: parsedEnd == null,
        ),
      );
    }

    allDates.sort((a, b) => a.compareTo(b));
    final minDate = allDates.isEmpty ? null : allDates.first;
    final maxDate = allDates.isEmpty ? null : allDates.last;

    return TimelineData(
      entries: entries,
      ranges: ranges,
      minDate: minDate,
      maxDate: maxDate,
    );
  }

  static DateTime _endOfCurrentYear() {
    final now = DateTime.now();
    return DateTime(now.year, 12, 31);
  }

  static DateTime? parseDate(String? raw, {bool endOfMonth = false}) {
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

  static String formatMonthYear(DateTime date) {
    const months = [
      '',
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
    ];
    final m = (date.month >= 1 && date.month <= 12) ? months[date.month] : '';
    return m.isEmpty ? '${date.year}' : '$m ${date.year}';
  }

  static String formatDayMonthYear(DateTime date) {
    const months = [
      '',
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
    ];
    final m = (date.month >= 1 && date.month <= 12) ? months[date.month] : '';
    return m.isEmpty ? '${date.year}' : '${date.day} $m ${date.year}';
  }

  static String formatRangeDates(
    DateTime start,
    DateTime end, {
    bool isOngoing = false,
  }) {
    final endLabel = isOngoing ? 'Present' : formatMonthYear(end);
    return '${formatMonthYear(start)} — $endLabel';
  }
}
