import 'package:flutter/material.dart';
import '../widgets/ui/custom_app_bar.dart';
import '../widgets/ui/custom_footer.dart';
import '../core/theme.dart';
import '../core/responsive_web_utils.dart';
import '../data/landing/landing_page_data.dart';
import '../data/landing/timeline_data.dart';
import '../data/projects/project_collection.dart';
import '../widgets/landing/timeline_single_year.dart';
import '../widgets/landing/landing_intro.dart';
import '../widgets/landing/landing_work_card.dart';
import '../widgets/landing/landing_education_card.dart';
import '../widgets/landing/landing_skills_section.dart';

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
                        ? const SizedBox(
                            height: 240,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : _data == null
                        ? const SizedBox(
                            height: 240,
                            child: Center(
                              child: Text('Failed to load content'),
                            ),
                          )
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
    final timeline = TimelineSingleYear(data: timelineData);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        LandingIntro(intro: data.intro),
        const SizedBox(height: 18),
        timeline,
        const SizedBox(height: 24),
        _buildSectionTitle('Experience'),
        const SizedBox(height: 12),
        ...data.experience.map((w) => LandingWorkCard(work: w)),
        const SizedBox(height: 18),
        _buildSectionTitle('Education'),
        const SizedBox(height: 12),
        ...data.education.map((e) => LandingEducationCard(edu: e)),
        const SizedBox(height: 18),
        _buildSectionTitle('Skills'),
        const SizedBox(height: 12),
        LandingSkillsSection(skills: data.skills),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    );
  }
}
