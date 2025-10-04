import 'package:flutter/material.dart';
import 'pages/landing_page.dart';
import 'pages/projects_base_page.dart';
import 'pages/project_detail_loader.dart';
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
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');

        // Home and static pages
        if (uri.path == AppRoutes.landing) {
          return MaterialPageRoute(builder: (_) => const LandingPage(), settings: settings);
        }
        if (uri.path == AppRoutes.projects) {
          return MaterialPageRoute(
              builder: (_) => const ProjectsBasePage(
                    configKey: 'projects_archive',
                    title: 'Programming Projects',
                  ),
              settings: settings);
        }

        if (uri.path == AppRoutes.featured) {
          return MaterialPageRoute(
              builder: (_) => const ProjectsBasePage(
                    configKey: 'featured_projects',
                    title: 'Featured Projects',
                    emptyStateIcon: Icons.star_outline,
                  ),
              settings: settings);
        }

        if (uri.path == AppRoutes.japaneseTranslations) {
          return MaterialPageRoute(
              builder: (_) => const ProjectsBasePage(
                    configKey: 'translations',
                    title: 'Japanese Translations',
                    emptyStateIcon: Icons.translate,
                  ),
              settings: settings);
        }

        // Pattern: /projects/<slug>
        final segments = uri.pathSegments;
        if (segments.length == 2 && segments[0] == 'projects') {
          final slug = segments[1];
          return MaterialPageRoute(builder: (_) => ProjectDetailLoader(slug: slug), settings: settings);
        }

        // No fallback old detail page; unknown routes will return null.

        // Unknown route
        return null;
      },
    );
  }
}
