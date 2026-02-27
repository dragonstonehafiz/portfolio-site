import '../data/pages/page_collection.dart';

class AppRoutes {
  static const String landing = '/';

  // Map slug -> pageName for generic pages. Initialized at app startup.
  static final Map<String, String> genericPageSlugs = {};

  /// Initialize AppRoutes by loading PageCollection data and preparing slug -> pageName mappings.
  static Future<void> initialize() async {
    // Make sure PageCollection is loaded with actual data first
    await PageCollection.initializeFromAssets();
    
    final collection = PageCollection.instance;
    for (final page in collection.genericPages) {
      final slug = _slugify(page.pageName);
      genericPageSlugs[slug] = page.pageName;
    }
  }

  static String _slugify(String input) {
    final s = input.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), '-');
    // Collapse repeated dashes, trim whitespace, and remove leading/trailing dashes
    return s.replaceAll(RegExp(r'-+'), '-').trim().replaceAll(RegExp(r'^-+|-+$'), '');
  }

  /// Helper to generate the path for a generic page slug (e.g. '/pages/<slug>').
  static String pagePath(String slug) => '/pages/$slug';

  /// Helper to generate a slug from a page name.
  static String slugForPageName(String pageName) => _slugify(pageName);
}
