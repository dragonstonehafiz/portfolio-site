import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'page_data.dart';

class PageCollection {
  final List<ProjectPageData> _genericProjectPageData;
  List<ProjectPageData> get genericPages => _genericProjectPageData;
  static PageCollection? _instance;
  static bool get isInitialized => _instance != null;

  PageCollection._({required List<ProjectPageData> projectPages}) : 
  _genericProjectPageData = projectPages;

  factory PageCollection._fromJson(Map<String, dynamic> json) {
    final pagesRaw = json['project_pages'] as List<dynamic>? ?? [];
    final pages = pagesRaw.map((e) => ProjectPageData.fromJson(Map<String, dynamic>.from(e))).toList();

    return PageCollection._(projectPages: pages);
  }

  static PageCollection _fromRawJson(String str) => PageCollection._fromJson(json.decode(str));

  static PageCollection get instance {
    return _instance ??= PageCollection._fromJson({});
  }

  /// Initialize the singleton with JSON data from assets.
  static Future<void> initializeFromAssets() async {
    if (_instance != null) return; // Already initialized
    
    try {
      final String raw = await rootBundle.loadString('assets/page_config.json');
      _instance = PageCollection._fromRawJson(raw);
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
