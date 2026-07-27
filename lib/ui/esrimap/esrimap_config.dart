import 'dart:convert';
import 'package:http/http.dart' as http;

// Base layer spec

class BaseLayerSpec {
  final String type;        // 'arcgisTiled' | 'arcgisVectorTiled' | 'arcgisMapImage'
  final String? serviceKey; // resolves via EsriMapConfig.serviceUrls
  final String? portalKey;  // resolves via EsriMapConfig.portals
  final String? itemId;

  const BaseLayerSpec({
    required this.type,
    this.serviceKey,
    this.portalKey,
    this.itemId,
  });

  factory BaseLayerSpec.fromJson(Map<String, dynamic> json) => BaseLayerSpec(
    type:       json['type']       as String,
    serviceKey: json['serviceKey'] as String?,
    portalKey:  json['portalKey']  as String?,
    itemId:     json['itemId']     as String?,
  );
}

// Basemaps

class BasemapConfig {
  final String label;
  final String thumbnailAsset;
  final List<BaseLayerSpec> baseLayers;

  const BasemapConfig({
    required this.label,
    required this.thumbnailAsset,
    required this.baseLayers,
  });

  factory BasemapConfig.fromJson(Map<String, dynamic> json) => BasemapConfig(
    label:          json['label']          as String,
    thumbnailAsset: json['thumbnailAsset'] as String,
    baseLayers: (json['baseLayers'] as List)
        .map((e) => BaseLayerSpec.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

// Operational layers

class SublayerEntry {
  final String name;
  final String source;
  final String? url;
  final String? portalKey;
  final String? itemId;
  final int refreshInterval;
  final bool popup;
  final String? popupTemplate;

  const SublayerEntry({
    required this.name,
    required this.source,
    this.url,
    this.portalKey,
    this.itemId,
    required this.refreshInterval,
    required this.popup,
    this.popupTemplate,
  });

  factory SublayerEntry.fromJson(Map<String, dynamic> json) => SublayerEntry(
    name:            json['name']              as String,
    source:          json['source']            as String,
    url:             json['url']               as String?,
    portalKey:       json['portalKey']         as String?,
    itemId:          json['itemId']            as String?,
    refreshInterval: (json['refreshInterval']  as num?)?.toInt() ?? 0,
    popup:           json['popup']             as bool? ?? false,
    popupTemplate:   json['popupTemplate']     as String?,
  );
}

class LayerEntry {
  final String label;
  final String thumbnailAsset;
  final String? source;
  final String? url;
  final String? portalKey;
  final String? itemId;
  final int refreshInterval;
  final bool popup;
  final String? popupTemplate;
  final List<SublayerEntry>? sublayers;

  const LayerEntry({
    required this.label,
    required this.thumbnailAsset,
    this.source,
    this.url,
    this.portalKey,
    this.itemId,
    this.refreshInterval = 0,
    this.popup = false,
    this.popupTemplate,
    this.sublayers,
  });

  bool get hasSublayers => sublayers != null && sublayers!.isNotEmpty;

  factory LayerEntry.fromJson(Map<String, dynamic> json) => LayerEntry(
    label:           json['label']           as String,
    thumbnailAsset:  json['thumbnailAsset']  as String,
    source:          json['source']          as String?,
    url:             json['url']             as String?,
    portalKey:       json['portalKey']       as String?,
    itemId:          json['itemId']          as String?,
    refreshInterval: (json['refreshInterval'] as num?)?.toInt() ?? 0,
    popup:           json['popup']           as bool? ?? false,
    popupTemplate:   json['popupTemplate']   as String?,
    sublayers: json['sublayers'] == null
        ? null
        : (json['sublayers'] as List)
            .map((e) => SublayerEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
  );
}

// Scenes

class SceneConfig {
  final String label;
  final String type; // '2d' | 'scene'
  final String? portalKey;
  final String? itemId;

  const SceneConfig({
    required this.label,
    required this.type,
    this.portalKey,
    this.itemId,
  });

  factory SceneConfig.fromJson(Map<String, dynamic> json) => SceneConfig(
    label:     json['label']     as String,
    type:      json['type']      as String,
    portalKey: json['portalKey'] as String?,
    itemId:    json['itemId']    as String?,
  );
}

// Features
// Allows remote enabling/disabling of app features without redeploying the app.

class FeaturesConfig {
  final bool aiSearch;
  final bool scenes;

  const FeaturesConfig({required this.aiSearch, required this.scenes});

  factory FeaturesConfig.fromJson(Map<String, dynamic> json) => FeaturesConfig(
    aiSearch: json['aiSearch'] as bool? ?? false,
    scenes:   json['scenes']   as bool? ?? false,
  );
}

// Search categories

class SearchCategoryConfig {
  final String label;
  final String poiClass;
  final String icon;
  final String? color;

  const SearchCategoryConfig({
    required this.label,
    required this.poiClass,
    required this.icon,
    this.color,
  });

  factory SearchCategoryConfig.fromJson(Map<String, dynamic> json) =>
      SearchCategoryConfig(
        label:    json['label']    as String,
        poiClass: json['poiClass'] as String,
        icon:     json['icon']     as String,
        color:    json['color']    as String?,
      );
}

// Root config

class EsriMapConfig {
  final Map<String, String> portals;
  final Map<String, String> serviceUrls;
  final Map<String, BasemapConfig> basemaps;
  final Map<String, LayerEntry> layers;
  final Map<String, SceneConfig> scenes;
  final FeaturesConfig features;
  final List<SearchCategoryConfig> searchCategories;

  const EsriMapConfig({
    required this.portals,
    required this.serviceUrls,
    required this.basemaps,
    required this.layers,
    required this.scenes,
    required this.features,
    required this.searchCategories,
  });

  factory EsriMapConfig.fromJson(Map<String, dynamic> json) => EsriMapConfig(
    portals:     (json['portals']     as Map<String, dynamic>).cast<String, String>(),
    serviceUrls: (json['serviceUrls'] as Map<String, dynamic>).cast<String, String>(),
    basemaps: (json['basemaps'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, BasemapConfig.fromJson(v as Map<String, dynamic>)),
    ),
    layers: (json['layers'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, LayerEntry.fromJson(v as Map<String, dynamic>)),
    ),
    scenes: (json['scenes'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, SceneConfig.fromJson(v as Map<String, dynamic>)),
    ),
    features:         FeaturesConfig.fromJson(json['features']         as Map<String, dynamic>),
    searchCategories: (json['searchCategories'] as List)
        .map((e) => SearchCategoryConfig.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

// Service
// Fetches and caches the EsriMapConfig from the backend API.

class EsriMapConfigService {
  static final EsriMapConfigService instance = EsriMapConfigService._();
  EsriMapConfigService._();

  static const _BASE_URL =
      'https://appzxi70zi.execute-api.us-west-2.amazonaws.com/test/ArcGIS-Map';

  EsriMapConfig? _config;
  Future<EsriMapConfig>? _pending;

  Future<EsriMapConfig> fetch() => _pending ??= _doFetch();

  EsriMapConfig? get cached => _config;

  String get tokensUrl => '$_BASE_URL/tokens';

  Future<EsriMapConfig> _doFetch() async {
    final response = await http.get(Uri.parse('$_BASE_URL/config'));
    final isResNotOk = response.statusCode != 200;
    if (isResNotOk) throw Exception('Config fetch failed: ${response.statusCode}');
    _config = EsriMapConfig.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    return _config!;
  }
}