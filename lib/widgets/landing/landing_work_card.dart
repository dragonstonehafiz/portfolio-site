import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme.dart';
import '../../data/landing/landing_page_data.dart';
import '../ui/animated_gradient.dart';

/// Landing page work experience card widget
class LandingWorkCard extends StatelessWidget {
  final WorkItem work;

  const LandingWorkCard({super.key, required this.work});

  @override
  Widget build(BuildContext context) {
    // Render work entry with full-width animated gradient background matching project previews
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
                  // Header row: Icon (left) + Company/Title (center-left, expanded)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon on the left (fixed width for alignment)
                      if (work.icon != null && work.icon!.isNotEmpty)
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: _buildIconWidget(work.icon!),
                        )
                      else
                        const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(
                            Icons.work_outline,
                            color: Colors.blueGrey,
                          ),
                        ),
                      const SizedBox(width: 12),
                      // Company and title (expanded to fill available space)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              work.company,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              work.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_formatMonthYear(work.start)} — ${work.end != null ? _formatMonthYear(work.end) : 'Present'}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  // Bullets rendered as simple bulleted list
                  ...work.bullets.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(child: Text(b)),
                        ],
                      ),
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
