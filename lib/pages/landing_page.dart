import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_footer.dart';
import '../widgets/animated_gradient.dart';
import '../utils/theme.dart';
import '../utils/landing_page_data.dart';
import '../utils/responsive_web_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  LandingPageData? _data;
  bool _loading = true;

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
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: _loading
                        ? const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()))
                        : _data == null
                            ? const SizedBox(height: 240, child: Center(child: Text('Failed to load content')))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 24),
                                  _buildIntro(context, _data!.intro),
                                  const SizedBox(height: 24),
                                  _buildSectionTitle('Experience'),
                                  const SizedBox(height: 12),
                                  ..._data!.experience.map((w) => _buildWorkCard(w)).toList(),
                                  const SizedBox(height: 18),
                                  _buildSectionTitle('Education'),
                                  const SizedBox(height: 12),
                                  ..._data!.education.map((e) => _buildEducationCard(e)).toList(),
                                  const SizedBox(height: 18),
                                  _buildSectionTitle('Skills'),
                                  const SizedBox(height: 12),
                                  _buildSkills(_data!.skills),
                                  const SizedBox(height: 48),
                                ],
                              ),
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

  Widget _buildIntro(BuildContext context, Intro intro) {
    final theme = Theme.of(context);
    return Column(
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
          child: DefaultTextStyle(
            style: const TextStyle(color: Color(0xFF0F1724)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Company, Title (bold), dates
                Text(work.company, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(work.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('${_formatMonthYear(work.start)} — ${work.end != null ? _formatMonthYear(work.end) : 'Present'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 12),
                // Bullets rendered as simple bulleted list
                ...work.bullets.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  Widget _buildEducationCard(EducationItem edu) {
    // Render education entry with full-width animated gradient background matching project previews
    final groups = edu.modules;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedGradient(
        gradient: Theme.of(context).previewGradient,
        borderRadius: BorderRadius.circular(12),
        duration: const Duration(seconds: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DefaultTextStyle(
            style: const TextStyle(color: Color(0xFF0F1724)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: School, Programme (bold), dates
                Text(edu.school, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(edu.course, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('${_formatMonthYear(edu.start)} — ${edu.end != null ? _formatMonthYear(edu.end) : 'Present'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 12),
                if (groups.isNotEmpty)
                  DefaultTabController(
                    length: groups.length,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TabBar(
                          isScrollable: true,
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Colors.grey[600],
                          indicatorColor: Theme.of(context).primaryColor,
                          tabs: groups.map((g) => Tab(text: g.name)).toList(),
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
    // Dynamically render each skill category as individual animated gradient cards
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dynamic skill categories
        ...skills.dynamicSkills.entries.map((entry) {
          final categoryName = entry.key;
          final skillItems = entry.value;
          
          if (skillItems.isEmpty) return const SizedBox.shrink();
          
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            child: AnimatedGradient(
              gradient: Theme.of(context).previewGradient,
              borderRadius: BorderRadius.circular(12),
              duration: const Duration(seconds: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DefaultTextStyle(
                  style: const TextStyle(color: Color(0xFF0F1724)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(categoryName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: skillItems.map((s) => Chip(label: Text(s))).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

}