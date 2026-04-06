import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'pages/landing_page.dart';
import 'pages/projects_base_page.dart';
import 'pages/project_detail_page.dart';
import 'pages/project_summary_page.dart';
import 'pages/not_found_page.dart';
import 'core/routes.dart';
import 'core/theme.dart';
import 'data/pages/page_collection.dart';
import 'data/projects/project_collection.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  // Ensure Flutter bindings are initialized before using rootBundle or other
  // services. This prevents the 'Binding has not yet been initialized' error
  // when loading assets during startup.
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Initialize singletons from assets and dynamic routes
  await Future.wait([
    ProjectsCollection.initializeFromAssets(),
    AppRoutes.initialize(), 
  ]);

  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muhd Hafiz',
      theme: buildAppTheme(),
      onGenerateInitialRoutes: (initialRouteName) {
        final rawPath = Uri.base.path;
        final canonicalPath = _canonicalizePath(rawPath);
        if (canonicalPath != rawPath) {
          html.window.history.replaceState(null, '', canonicalPath);
        }

        return [
          _buildRoute(
            RouteSettings(name: canonicalPath),
            notFoundRequestedPath: canonicalPath == AppRoutes.notFound
                ? rawPath
                : null,
          ),
        ];
      },
      onGenerateRoute: (settings) => _buildRoute(settings),
    );
  }

  PageRoute<dynamic> _buildRoute(
    RouteSettings settings, {
    String? notFoundRequestedPath,
  }) {
    final uri = Uri.parse(settings.name ?? '');
    final path = uri.path;

    PageRoute<T> slideUpRoute<T>(
      Widget page, {
      RouteSettings? routeSettings,
    }) {
      return PageRouteBuilder<T>(
        settings: routeSettings ?? settings,
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
      );
    }

    if (path == '/' || path == AppRoutes.landing) {
      if (path == '/') {
        html.window.history.replaceState(null, '', AppRoutes.landing);
      }
      return slideUpRoute(
        const LandingPage(),
        routeSettings: const RouteSettings(name: AppRoutes.landing),
      );
    }

    if (path == AppRoutes.notFound) {
      return slideUpRoute(
        NotFoundPage(requestedPath: notFoundRequestedPath ?? ''),
      );
    }

    if (path == '/projects' || path == AppRoutes.projectSummaryPath) {
      return slideUpRoute(const ProjectSummaryPage());
    }

    final segments = uri.pathSegments;
    if (segments.length == 2 && segments[0] == AppRoutes.projectSummarySlug) {
      final slug = segments[1];
      final pageName = AppRoutes.genericPageSlugs[slug];
      if (pageName != null) {
        final pageData = PageCollection.instance.findGenericPageByName(pageName);
        return slideUpRoute(
          ProjectsBasePage(
            configKey: pageName,
            title: pageName,
            description: pageData?.description ?? '',
          ),
        );
      }
    } else if (segments.length == 2 && segments[0] == 'project') {
      final slug = segments[1];
      return slideUpRoute(ProjectDetailPage(slug: slug));
    }

    debugPrint("No route match for: $path");
    html.window.history.replaceState(null, '', AppRoutes.notFound);
    return slideUpRoute(
      NotFoundPage(requestedPath: path),
      routeSettings: const RouteSettings(name: AppRoutes.notFound),
    );
  }

  String _canonicalizePath(String path) {
    if (path.isEmpty || path == '/') {
      return AppRoutes.landing;
    }
    if (path == AppRoutes.landing || path == AppRoutes.notFound) {
      return path;
    }
    if (path == '/projects' || path == AppRoutes.projectSummaryPath) {
      return path;
    }

    final uri = Uri.parse(path);
    final segments = uri.pathSegments;
    if (segments.length == 2 && segments[0] == AppRoutes.projectSummarySlug) {
      final slug = segments[1];
      if (AppRoutes.genericPageSlugs.containsKey(slug)) {
        return path;
      }
      return AppRoutes.notFound;
    }
    if (segments.length == 2 && segments[0] == 'project') {
      return path;
    }
    return AppRoutes.notFound;
  }
}
