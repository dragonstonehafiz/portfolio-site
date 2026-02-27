import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/website/custom_app_bar.dart';
import '../widgets/website/custom_footer.dart';
import '../widgets/ui/animated_gradient.dart';
import '../core/theme.dart';
import '../data/landing/landing_page_data.dart';
import '../core/responsive_web_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/projects/project_collection.dart';
import '../data/projects/project_data.dart';
import '../data/landing/timeline_data.dart';
import '../widgets/website/single_year_timeline.dart';
import '../widgets/generic/shared_tabs.dart';
import '../widgets/project/project_preview_card.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  LandingPageData? _data;
  bool _loading = true;
  int _skillsTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final d = await LandingPageData.loadFromAssets();
      setState(() {
        _data = d;
        _loading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load landing page data: $e');
      setState(() => _loading = false);
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

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: ResponsiveWebUtils.getResponsivePadding(context),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: _loading
                        ? const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()))
                        : _data == null
                            ? const SizedBox(height: 240, child: Center(child: Text('Failed to load content')))
                            : _buildHomeLayout(context, _data!),
                  ),
                ),
              ),
            ),
          ),
          const CustomFooter(),
        ],
      ),
    );
  }

  Widget _buildHomeLayout(BuildContext context, LandingPageData data) {
    final projects = ProjectsCollection.instance.projects.values.toList();
    final timelineData = TimelineData.fromLandingPageData(data, projects);
    final timeline = SingleYearTimelineWidget(data: timelineData);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildIntro(context, data.intro),
        const SizedBox(height: 18),
        timeline,
        const SizedBox(height: 24),
        _buildSectionTitle('Experience'),
        const SizedBox(height: 12),
        ...data.experience.map((w) => _buildWorkCard(w)),
        const SizedBox(height: 18),
        _buildSectionTitle('Education'),
        const SizedBox(height: 12),
        ...data.education.map((e) => _buildEducationCard(e)),
        const SizedBox(height: 18),
        _buildSectionTitle('Skills'),
        const SizedBox(height: 12),
        _buildSkills(data.skills),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildIntro(BuildContext context, Intro intro) {
    final theme = Theme.of(context);
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(intro.name, style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(intro.headline, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(intro.summary, style: const TextStyle(fontSize: 16, color: Colors.grey)),
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey));
  }

  Widget _buildWorkCard(WorkItem work) {
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
                        child: Icon(Icons.work_outline, color: Colors.blueGrey),
                      ),
                    const SizedBox(width: 12),
                    // Company and title (expanded to fill available space)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(work.company, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(work.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('${_formatMonthYear(work.start)} — ${work.end != null ? _formatMonthYear(work.end) : 'Present'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 12),
                // Bullets rendered as simple bulleted list
                ...work.bullets.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(child: Text(b)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildEducationCard(EducationItem edu) {
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
                        child: const Icon(Icons.school_outlined, color: Colors.blueGrey),
                      ),
                    SizedBox(width: isMobile ? 10 : 12),
                    // School and course (expanded to fill available space)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(edu.school, style: TextStyle(fontSize: isMobile ? 15 : 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(edu.course, style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold)),
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
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                    if (edu.gpa != null && edu.gpa!.isNotEmpty)
                      Text(
                        'GPA: ${edu.gpa}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
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
                                  children: g.items.map((it) => Chip(label: Text(it))).toList(),
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

  String _formatMonthYear(String? s) {
    if (s == null || s.isEmpty) return '';
    // Expect formats like YYYY-MM or YYYY-MM-DD. Parse safely.
    try {
      final parts = s.split('-');
      final year = int.parse(parts[0]);
      final month = parts.length > 1 ? int.parse(parts[1]) : 1;
      const months = [
        '',
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final m = (month >= 1 && month <= 12) ? months[month] : '';
      return '$m $year';
    } catch (_) {
      return s;
    }
  }

  Widget _buildSkills(Skills skills) {
    final isMobile = ResponsiveWebUtils.isMobile(context);
    final categories = skills.categories.entries.where((e) => e.value.items.isNotEmpty).toList();
    
    if (categories.isEmpty) return const SizedBox.shrink();
    if (_skillsTabIndex >= categories.length) {
      _skillsTabIndex = 0;
    }
    final currentEntry = categories[_skillsTabIndex];
    
    return DefaultTabController(
      length: categories.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                  SharedTabs(
                    labels: categories.map((e) => e.key).toList(),
                    onTap: (index) => setState(() => _skillsTabIndex = index),
                  ),
          const SizedBox(height: 12),
          _buildSkillCategoryCard(currentEntry, isMobile),
        ],
      ),
    );
  }

  Widget _buildSkillCategoryCard(
    MapEntry<String, SkillCategory> entry,
    bool isMobile,
  ) {
    final desc = entry.value.description;
    final relatedProjects = _resolveRelatedProjects(entry.value.relatedProjects);
    final carouselHeight = isMobile ? 420.0 : 430.0;
    final filteredItems = entry.value.items;

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
                if (desc.trim().isNotEmpty) ...[
                  Text(
                    desc,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ) ??
                        const TextStyle(height: 1.4, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: filteredItems
                      .map((skill) => Chip(label: Text(skill)))
                      .toList(),
                ),
                if (relatedProjects.isNotEmpty && filteredItems.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: carouselHeight,
                    child: _SkillProjectCarousel(projects: relatedProjects),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  List<ProjectData> _resolveRelatedProjects(List<String> ids) {
    if (ids.isEmpty) return [];

    final collection = ProjectsCollection.instance.projects;
    final projects = <ProjectData>[];
    for (final id in ids) {
      final entry = collection[id];
      if (entry != null) {
        projects.add(entry.defaultVersion);
        continue;
      }
      // Fallback: match by variableName or slug.
      for (final p in collection.values) {
        final def = p.defaultVersion;
        if (p.variableName == id || def.slug == id) {
          projects.add(def);
          break;
        }
      }
    }
    return projects;
  }

}

class _SkillProjectCarousel extends StatefulWidget {
  final List<ProjectData> projects;

  const _SkillProjectCarousel({required this.projects});

  @override
  State<_SkillProjectCarousel> createState() => _SkillProjectCarouselState();
}

class _SkillProjectCarouselState extends State<_SkillProjectCarousel> {
  static const Duration _autoAdvanceDuration = Duration(seconds: 6);
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _SkillProjectCarousel oldWidget) {
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
