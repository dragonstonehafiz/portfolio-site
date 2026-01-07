import 'package:flutter/material.dart';
import 'pages/landing_page.dart';
import 'pages/projects_base_page.dart';
import 'pages/project_detail_loader.dart';
import 'routes/app_routes.dart';
import 'utils/theme.dart';
import 'utils/page_collection.dart';
import 'utils/project_collection.dart';
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

        // Home and static pages
        if (uri.path == AppRoutes.landing) {
          return MaterialPageRoute(builder: (_) => const LandingPage(), settings: settings);
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
              return MaterialPageRoute(
                  builder: (_) => ProjectsBasePage(
                        configKey: pageName,
                        title: pageName,
                        description: pageData?.description ?? '',
                      ),
                  settings: settings);
            }
          } else if (segments[0] == 'projects') {
            final slug = segments[1];
            return MaterialPageRoute(builder: (_) => ProjectDetailLoader(slug: slug), settings: settings);
          }
        }
        debugPrint("No route match for: ${uri.path}");
        return null;
      },
    );
  }
}
