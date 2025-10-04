import 'package:flutter/material.dart';
import 'pages/landing_page.dart';
import 'pages/projects_base_page.dart';
import 'pages/project_detail_page.dart';
import 'routes/app_routes.dart';
import 'utils/theme.dart';

void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muhd Hafiz\'s Portfolio Site',
      theme: buildAppTheme(),
      initialRoute: AppRoutes.landing,
      routes: {
        AppRoutes.landing: (context) => const LandingPage(),
        AppRoutes.projects: (context) => const ProjectsBasePage(
              configKey: 'projects_archive',
              title: 'Programming Projects',
            ),
        AppRoutes.projectDetail: (context) => const ProjectDetailPage(),
        AppRoutes.featured: (context) => const ProjectsBasePage(
              configKey: 'featured_projects',
              title: 'Featured Projects',
              emptyStateIcon: Icons.star_outline,
            ),
        AppRoutes.japaneseTranslations: (context) => const ProjectsBasePage(
              configKey: 'translations',
              title: 'Japanese Translations',
              emptyStateIcon: Icons.translate,
            ),
      },
    );
  }
}
