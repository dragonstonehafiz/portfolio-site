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
      title: 'Portfolio Site',
      theme: buildAppTheme(),
      initialRoute: AppRoutes.landing,
      routes: {
        AppRoutes.landing: (context) => const LandingPage(),
        AppRoutes.projects: (context) => const ProjectsBasePage(
              configKey: 'projects_archive',
              title: 'Projects',
              descriptionTemplate:
                  'Explore {count} projects showcasing my work across different technologies and domains.',
            ),
        AppRoutes.projectDetail: (context) => const ProjectDetailPage(),
        AppRoutes.featured: (context) => const ProjectsBasePage(
              configKey: 'featured_projects',
              title: 'Featured Projects',
              descriptionTemplate:
                  'A curated selection of {count} standout projects that showcase my best work.',
              emptyStateIcon: Icons.star_outline,
            ),
        AppRoutes.japaneseTranslations: (context) => const ProjectsBasePage(
              configKey: 'translations',
              title: 'Japanese Translations',
              descriptionTemplate:
                  'Discover {count} projects focused on Japanese language translations and localization.',
              emptyStateIcon: Icons.translate,
            ),
      },
    );
  }
}
