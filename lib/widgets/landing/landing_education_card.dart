import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme.dart';
import '../../core/responsive_web_utils.dart';
import '../../data/landing/landing_page_data.dart';
import '../ui/animated_gradient.dart';
import '../generic/shared_tabs.dart';

/// Landing page education card widget
class LandingEducationCard extends StatelessWidget {
  final EducationItem edu;

  const LandingEducationCard({super.key, required this.edu});

  @override
  Widget build(BuildContext context) {
    // Render education entry with full-width animated gradient background matching project previews
    final groups = edu.modules;
    final isMobile = ResponsiveWebUtils.isMobile(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedGradient(
        gradient: Theme.of(context).previewGradient,
        borderRadius: BorderRadius.circular(12),
        duration: const Duration(seconds: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SelectionArea(
            child: DefaultTextStyle(
              style: const TextStyle(color: Color(0xFF0F1724)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: Icon (left) + School/Course (center-left, expanded)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon on the left
                      if (edu.icon != null && edu.icon!.isNotEmpty)
                        SizedBox(
                          width: isMobile ? 40 : 48,
                          height: isMobile ? 40 : 48,
                          child: _buildIconWidget(edu.icon!),
                        )
                      else
                        SizedBox(
                          width: isMobile ? 40 : 48,
                          height: isMobile ? 40 : 48,
                          child: const Icon(
                            Icons.school_outlined,
                            color: Colors.blueGrey,
                          ),
                        ),
                      SizedBox(width: isMobile ? 10 : 12),
                      // School and course (expanded to fill available space)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              edu.school,
                              style: TextStyle(
                                fontSize: isMobile ? 15 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              edu.course,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Date range and GPA on the same row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_formatMonthYear(edu.start)} — ${edu.end != null ? _formatMonthYear(edu.end) : 'Present'}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (edu.gpa != null && edu.gpa!.isNotEmpty)
                        Text(
                          'GPA: ${edu.gpa}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (groups.isNotEmpty)
                    DefaultTabController(
                      length: groups.length,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SharedTabs(
                            labels: groups.map((g) => g.name).toList(),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            // Fixed height for tab content
                            height: 120,
                            child: TabBarView(
                              children: groups.map((g) {
                                return SingleChildScrollView(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: g.items
                                        .map((it) => Chip(label: Text(it)))
                                        .toList(),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper to render icon based on file extension (SVG or raster image)
  Widget _buildIconWidget(String iconPath) {
    final extension = iconPath.toLowerCase().split('.').last;
    if (extension == 'svg') {
      return SvgPicture.asset(iconPath, fit: BoxFit.contain);
    } else {
      // PNG, JPG, etc.
      return Image.asset(
        iconPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );
    }
  }

  String _formatMonthYear(String? s) {
    if (s == null || s.isEmpty) return '';
    // Expect formats like YYYY-MM or YYYY-MM-DD. Parse safely.
    try {
      final parts = s.split('-');
      final year = int.parse(parts[0]);
      final month = parts.length > 1 ? int.parse(parts[1]) : 1;
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
      final m = (month >= 1 && month <= 12) ? months[month] : '';
      return '$m $year';
    } catch (_) {
      return s;
    }
  }
}
