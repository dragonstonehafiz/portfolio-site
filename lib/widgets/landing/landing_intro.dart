import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/responsive_web_utils.dart';
import '../../core/theme.dart';
import '../../data/landing/landing_page_data.dart';
import '../ui/animated_gradient.dart';

/// Landing page introduction widget displaying name, headline, summary, and download buttons
class LandingIntro extends StatelessWidget {
  final Intro intro;
  final WorkItem? topExperience;
  final EducationItem? topEducation;

  const LandingIntro({
    super.key,
    required this.intro,
    this.topExperience,
    this.topEducation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveWebUtils.isMobile(context);

    if (isMobile) {
      return SelectionArea(
        child: _buildIntroCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPrimaryContent(theme),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildQuickStats(theme),
            ],
          ),
        ),
      );
    }

    return SelectionArea(
      child: _buildIntroCard(
        context,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: _buildPrimaryContent(theme),
                ),
              ),
              Container(width: 1, color: Colors.black12),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: _buildQuickStats(theme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context, {required Widget child}) {
    return AnimatedGradient(
      gradient: Theme.of(context).previewGradient,
      borderRadius: BorderRadius.circular(12),
      duration: const Duration(seconds: 8),
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: child,
      ),
    );
  }

  Widget _buildPrimaryContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          intro.name,
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(intro.headline, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Text(
          intro.summary,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: intro.downloads.map((d) {
            return ElevatedButton(
              onPressed: () => _openUrl(d.url, external: d.external),
              child: Text(d.label),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickStats(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatBlock(
          label: 'Experience',
          title: topExperience?.company ?? '-',
          subtitle: topExperience?.title ?? '-',
          meta: topExperience == null
              ? '-'
              : '${_formatMonthYear(topExperience!.start)} - ${topExperience!.end != null ? _formatMonthYear(topExperience!.end) : 'Present'}',
          theme: theme,
          showBottomDivider: true,
        ),
        _buildStatBlock(
          label: 'Education',
          title: topEducation?.school ?? '-',
          subtitle: topEducation?.course ?? '-',
          meta: _educationMeta(topEducation),
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildStatBlock({
    required String label,
    required String title,
    required String subtitle,
    required String meta,
    required ThemeData theme,
    bool showBottomDivider = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: showBottomDivider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12)),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 2),
          Text(meta, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  String _educationMeta(EducationItem? edu) {
    if (edu == null) return '-';
    final range =
        '${_formatMonthYear(edu.start)} - ${edu.end != null ? _formatMonthYear(edu.end) : 'Present'}';
    if (edu.gpa == null || edu.gpa!.isEmpty) return range;
    return '$range - GPA ${edu.gpa}';
  }

  String _formatMonthYear(String? s) {
    if (s == null || s.isEmpty) return '';
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

  void _openUrl(String url, {bool external = false}) async {
    final uri = Uri.parse(url);
    if (external) {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri);
      }
    } else {
      // attempt to open local asset or fallback to external
      if (!await launchUrl(uri)) {
        // ignore
      }
    }
  }
}

