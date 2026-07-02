import 'project_data.dart' show ProjectEntry;
import '../supabase/supabase_rest.dart';

class ProjectsCollection {
  final Map<String, ProjectEntry> projects;
  static ProjectsCollection? _instance;

  ProjectsCollection._({required this.projects});

  static ProjectsCollection get instance {
    return _instance ??= ProjectsCollection._(projects: {});
  }

  /// Initialize the singleton by loading every project row from the
  /// Supabase `projects` table. Rows whose id starts with "_" are reserved
  /// for site content (page config, landing page) and are skipped here.
  static Future<void> initializeFromSupabase() async {
    if (_instance != null) return; // Already initialized

    try {
      final rows = await SupabaseRest.fetchAll('projects');
      final map = <String, ProjectEntry>{};
      for (final row in rows) {
        final id = row['id']?.toString() ?? '';
        if (id.isEmpty || id.startsWith('_')) continue;
        final data = Map<String, dynamic>.from(row['data'] as Map);
        map[id] = ProjectEntry.fromJson(id, data);
      }
      _instance = ProjectsCollection._(projects: map);
    } catch (e) {
      // Fallback to empty collection if loading fails
      _instance = ProjectsCollection._(projects: {});
    }
  }

  /// Check if the singleton is initialized
  static bool get isInitialized => _instance != null;

  /// Reset singleton for testing purposes
  static void resetForTesting() {
    _instance = null;
  }
}
