import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/supabase_config.dart';

/// Minimal PostgREST client for read-only access to Supabase tables.
class SupabaseRest {
  static Map<String, String> get _headers => {
    'apikey': SupabaseConfig.publishableKey,
    'Authorization': 'Bearer ${SupabaseConfig.publishableKey}',
  };

  static Future<List<Map<String, dynamic>>> fetchAll(
    String table, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse(
      '${SupabaseConfig.url}/rest/v1/$table',
    ).replace(queryParameters: query);
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception(
        'Supabase request to $table failed (${response.statusCode}): ${response.body}',
      );
    }
    final decoded = json.decode(response.body) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Fetches a single row by its `id` column, or null if not found.
  static Future<Map<String, dynamic>?> fetchById(String table, String id) async {
    final rows = await fetchAll(table, query: {'id': 'eq.$id'});
    if (rows.isEmpty) return null;
    return rows.first;
  }
}
