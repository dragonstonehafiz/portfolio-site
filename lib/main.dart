import 'package:flutter/material.dart';
import 'pages/landing_page.dart';
import 'pages/projects_base_page.dart';
import 'pages/project_detail_page.dart';
import 'routes/app_routes.dart';
import 'utils/theme.dart';
import 'utils/page_collection.dart';
import 'projects/project_collection.dart';
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
      initialRoute: AppRoutes.landing,
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');
        PageRoute<T> _slideUpRoute<T>(Widget page) {
          return PageRouteBuilder<T>(
            settings: settings,
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

        // Home and static pages
        if (uri.path == AppRoutes.landing) {
          return _slideUpRoute(const LandingPage());
        }

        // Pattern: /pages/<slug> -> map slug to a configured generic page
        // Pattern: /projects/<slug> -> open project detail
        final segments = uri.pathSegments;
        if (segments.length == 2) {
          if (segments[0] == 'pages') {
            final slug = segments[1];
            final pageName = AppRoutes.genericPageSlugs[slug];
            if (pageName != null) {
              final pageData = PageCollection.instance.findGenericPageByName(pageName);
              return _slideUpRoute(
                ProjectsBasePage(
                  configKey: pageName,
                  title: pageName,
                  description: pageData?.description ?? '',
                ),
              );
            }
          } else if (segments[0] == 'projects') {
            final slug = segments[1];
            return _slideUpRoute(ProjectDetailPage(slug: slug));
          }
        }
        debugPrint("No route match for: ${uri.path}");
        return null;
      },
    );
  }
}
