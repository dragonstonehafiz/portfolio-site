import 'package:flutter/material.dart';
import 'pages/landing_page.dart';
import 'pages/projects_page.dart';
import 'pages/project_detail_page.dart';
import 'routes/app_routes.dart';
import 'pages/featured_projects_page.dart';
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
        AppRoutes.projects: (context) => const ProjectsPage(),
        AppRoutes.projectDetail: (context) => const ProjectDetailPage(),
        AppRoutes.featured: (context) => const FeaturedProjectsPage(),
      },
    );
  }
}
