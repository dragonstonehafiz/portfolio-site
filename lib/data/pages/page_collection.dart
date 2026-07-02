import 'page_models.dart';
import '../supabase/supabase_rest.dart';

class PageCollection {
  final List<ProjectPageData> _genericProjectPageData;
  List<ProjectPageData> get genericPages => _genericProjectPageData;
  static PageCollection? _instance;
  static bool get isInitialized => _instance != null;

  PageCollection._({required List<ProjectPageData> projectPages})
    : _genericProjectPageData = projectPages;

  factory PageCollection._fromJson(Map<String, dynamic> json) {
    final pagesRaw = json['project_pages'] as List<dynamic>? ?? [];
    final pages = pagesRaw
        .map((e) => ProjectPageData.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return PageCollection._(projectPages: pages);
  }

  static PageCollection get instance {
    return _instance ??= PageCollection._fromJson({});
  }

  /// Initialize the singleton by loading the `_page_config` row from the
  /// Supabase `projects` table.
  static Future<void> initializeFromSupabase() async {
    if (_instance != null) return; // Already initialized

    try {
      final row = await SupabaseRest.fetchById('projects', '_page_config');
      final data = row == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(row['data'] as Map);
      _instance = PageCollection._fromJson(data);
    } catch (e) {
      // Fallback to empty collection if loading fails
      _instance = PageCollection._fromJson({});
    }
  }

  /// Reset singleton for testing purposes
  static void resetForTesting() {
    _instance = null;
  }

  /// Find a generic page by its `page_name` (case-insensitive). This searches
  /// only `genericPages` and does not consider the featured projects block.
  ProjectPageData? findGenericPageByName(String name) {
    final lname = name.toLowerCase();
    for (final p in genericPages) {
      if (p.pageName.toLowerCase() == lname) return p;
    }
    return null;
  }
}
