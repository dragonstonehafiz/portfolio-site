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
    final cardPadding = isMobile ? 12.0 : 16.0;
    final iconSize = isMobile ? 34.0 : 48.0;
    final schoolFontSize = isMobile ? 13.0 : 16.0;
    final courseFontSize = isMobile ? 12.0 : 16.0;
    final gpaFontSize = isMobile ? 12.0 : 22.0;
    final dateFontSize = isMobile ? 11.0 : 12.0;
    final modulesHeight = isMobile ? 108.0 : 120.0;
    final chipFontSize = isMobile ? 12.0 : 14.0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 2),
        child: AnimatedGradient(
        gradient: Theme.of(context).previewGradient,
        borderRadius: BorderRadius.zero,
        duration: const Duration(seconds: 8),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: SelectionArea(
            child: DefaultTextStyle(
              style: const TextStyle(color: Color(0xFF0F1724)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: Icon (left) + School/Course + GPA (right)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon on the left
                      if (edu.icon != null && edu.icon!.isNotEmpty)
                        SizedBox(
                          width: iconSize,
                          height: iconSize,
                          child: _buildIconWidget(edu.icon!),
                        )
                      else
                        SizedBox(
                          width: iconSize,
                          height: iconSize,
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
                                fontSize: schoolFontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              edu.course,
                              style: TextStyle(
                                fontSize: courseFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (edu.gpa != null && edu.gpa!.isNotEmpty) ...[
                        SizedBox(width: isMobile ? 8 : 16),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'GPA: ${edu.gpa}',
                            style: TextStyle(
                              fontSize: gpaFontSize,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Date range row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_formatMonthYear(edu.start)} - ${edu.end != null ? _formatMonthYear(edu.end) : 'Present'}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: dateFontSize,
                          ),
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
                            height: modulesHeight,
                            child: TabBarView(
                              children: groups.map((g) {
                                return SingleChildScrollView(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: g.items
                                        .map(
                                          (it) => Chip(
                                            visualDensity: isMobile
                                                ? VisualDensity.compact
                                                : VisualDensity.standard,
                                            materialTapTargetSize: isMobile
                                                ? MaterialTapTargetSize.shrinkWrap
                                                : MaterialTapTargetSize.padded,
                                            label: Text(
                                              it,
                                              style: TextStyle(
                                                fontSize: chipFontSize,
                                              ),
                                            ),
                                          ),
                                        )
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
