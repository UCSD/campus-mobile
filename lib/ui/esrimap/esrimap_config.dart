import 'dart:convert';
import 'package:http/http.dart' as http;

// Models
class EsriMapConfig {
  final String agePortalUrl;
  final String agoPortalUrl;
  final String nearmapUrl;
  final EsriTileUrls esriTileUrls;
  final Map<String, BasemapConfig> basemaps;
  final LayerUrls layers;
  final Map<String, SceneConfig> scenes;

  const EsriMapConfig({
    required this.agePortalUrl,
    required this.agoPortalUrl,
    required this.nearmapUrl,
    required this.esriTileUrls,
    required this.basemaps,
    required this.layers,
    required this.scenes,
  });

  factory EsriMapConfig.fromJson(Map<String, dynamic> json) {
    return EsriMapConfig(
      agePortalUrl: json['agePortalUrl'] as String,
      agoPortalUrl: json['agoPortalUrl'] as String,
      nearmapUrl:   json['nearmapUrl'] as String,
      esriTileUrls: EsriTileUrls.fromJson(json['esriTileUrls'] as Map<String, dynamic>),
      basemaps: (json['basemaps'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, BasemapConfig.fromJson(v as Map<String, dynamic>)),
      ),
      layers: LayerUrls.fromJson(json['layers'] as Map<String, dynamic>),
      scenes: (json['scenes'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, SceneConfig.fromJson(v as Map<String, dynamic>)),
      ),
    );
  }
}

class BasemapConfig {
  final String label;
  final String itemId;
  const BasemapConfig({required this.label, required this.itemId});
  factory BasemapConfig.fromJson(Map<String, dynamic> json) => BasemapConfig(
    label:  json['label']  as String,
    itemId: json['itemId'] as String,
  );
}

class EsriTileUrls {
  final String hillshade;
  final String lightGrayBase;
  final String darkGrayBase;
  const EsriTileUrls({required this.hillshade, required this.lightGrayBase, required this.darkGrayBase});
  factory EsriTileUrls.fromJson(Map<String, dynamic> json) => EsriTileUrls(
    hillshade:     json['hillshade']     as String,
    lightGrayBase: json['lightGrayBase'] as String,
    darkGrayBase:  json['darkGrayBase']  as String,
  );
}

class LayerUrls {
  final String transitRoutes;
  final String transitShuttles;
  final String campusDistricts;
  final String construction;
  final String assemblyAreas;
  const LayerUrls({
    required this.transitRoutes,
    required this.transitShuttles,
    required this.campusDistricts,
    required this.construction,
    required this.assemblyAreas,
  });
  factory LayerUrls.fromJson(Map<String, dynamic> json) => LayerUrls(
    transitRoutes:   json['transitRoutes']   as String,
    transitShuttles: json['transitShuttles'] as String,
    campusDistricts: json['campusDistricts'] as String,
    construction:    json['construction']    as String,
    assemblyAreas:   json['assemblyAreas']   as String,
  );
}

class SceneConfig {
  final String portalUrl;
  final String itemId;
  const SceneConfig({required this.portalUrl, required this.itemId});
  factory SceneConfig.fromJson(Map<String, dynamic> json) => SceneConfig(
    portalUrl: json['portalUrl'] as String,
    itemId:    json['itemId']    as String,
  );
}

// Service
class EsriMapConfigService {
  static final EsriMapConfigService instance = EsriMapConfigService._();
  EsriMapConfigService._();

  static const _baseUrl =
      'https://appzxi70zi.execute-api.us-west-2.amazonaws.com/test/ArcGIS-Map';

  EsriMapConfig? _config;
  Future<EsriMapConfig>? _pending;

  /// Fetches config once and caches it for the session.
  Future<EsriMapConfig> fetch() => _pending ??= _doFetch();

  EsriMapConfig? get cached => _config;

  String get tokensUrl => '$_baseUrl/tokens';

  Future<EsriMapConfig> _doFetch() async {
    final response = await http.get(Uri.parse('$_baseUrl/config'));
    if (response.statusCode != 200) {
      throw Exception('Config fetch failed: ${response.statusCode}');
    }
    _config = EsriMapConfig.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    return _config!;
  }
}