/// ============================================================================
/// File: esrimap_config_service.dart
/// Description: Service singleton fetching and caching backend EsriMapConfig
///              JSON data and authentication token endpoints, with offline
///              asset bundle fallback logic.
/// ============================================================================

import 'dart:convert';

import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

/// Service managing remote map configuration loading and token URL lookup.
class EsriMapConfigService {
  /// Singleton instance accessor.
  static final EsriMapConfigService instance = EsriMapConfigService._();
  EsriMapConfigService._();

  /// Base API endpoint URL.
  static const String BASE_URL = 'https://appzxi70zi.execute-api.us-west-2.amazonaws.com/test/ArcGIS-Map';

  /// Asset bundle path for offline fallback map configuration JSON.
  static const String ASSET_FALLBACK_PATH = 'assets/esri_map_assets/mapConfig.json';

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

  /// Fetches map configuration over network, falling back to local asset bundle if offline or failed.
  Future<EsriMapConfig> _doFetch() async {
    // 1. Attempt live HTTP GET request from backend API
    try {
      final response = await http.get(Uri.parse('$BASE_URL/config')).timeout(const Duration(seconds: 5));
      final isResOk = response.statusCode == 200;
      if (isResOk) {
        _config = EsriMapConfig.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
        return _config!;
      }
    } catch (e) {
      debugPrint('Remote map config fetch failed ($e), loading local asset fallback...');
    }

    // 2. Offline Fallback: Load configuration JSON from local app asset bundle
    final fallbackJson = await rootBundle.loadString(ASSET_FALLBACK_PATH);
    _config = EsriMapConfig.fromJson(jsonDecode(fallbackJson) as Map<String, dynamic>);
    return _config!;
  }
}
