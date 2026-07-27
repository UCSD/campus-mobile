/// ============================================================================
/// File: esrimap_config_service.dart
/// Description: Service singleton fetching and caching backend EsriMapConfig
///              JSON data and authentication token endpoints.
/// ============================================================================

import 'dart:convert';
import 'package:campus_mobile_experimental/ui/esrimap/models/esrimap_config.dart';
import 'package:http/http.dart' as http;

/// Service managing remote map configuration loading and token URL lookup.
class EsriMapConfigService {
  /// Singleton instance accessor.
  static final EsriMapConfigService instance = EsriMapConfigService._();
  EsriMapConfigService._();

  /// Base API endpoint URL.
  static const String BASE_URL = 'https://appzxi70zi.execute-api.us-west-2.amazonaws.com/test/ArcGIS-Map';

  EsriMapConfig? _config;
  Future<EsriMapConfig>? _pending;

  /// Fetches [EsriMapConfig], reusing existing or in-flight Future tasks.
  Future<EsriMapConfig> fetch() {
    _pending ??= _doFetch();
    return _pending!;
  }

  /// Returns cached [EsriMapConfig], or null if not yet loaded.
  EsriMapConfig? get cached => _config;

  /// Returns backend tokens URL for authentication challenge handlers.
  String get tokensUrl => '$BASE_URL/tokens';

  /// Performs actual HTTP GET request to fetch remote configuration.
  Future<EsriMapConfig> _doFetch() async {
    final response = await http.get(Uri.parse('$BASE_URL/config'));
    final isResNotOk = response.statusCode != 200;
    if (isResNotOk) {
      throw Exception('Config fetch failed: ${response.statusCode}');
    }
    _config = EsriMapConfig.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    return _config!;
  }
}
