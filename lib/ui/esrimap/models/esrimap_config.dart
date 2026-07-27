/// ============================================================================
/// File: esrimap_config.dart
/// Description: Data models for parsing backend map configuration JSON,
///              including portals, basemaps, operational layers, scenes, and feature flags.
/// ============================================================================

/// Specification for a base map layer.
class BaseLayerSpec {
  /// Layer type identifier ('arcgisTiled', 'arcgisVectorTiled', 'arcgisMapImage').
  final String type;

  /// Service key resolving to a URL in [EsriMapConfig.serviceUrls].
  final String? serviceKey;

  /// Portal key resolving to a portal URI in [EsriMapConfig.portals].
  final String? portalKey;

  /// Optional item ID for portal items.
  final String? itemId;

  /// Constructs a [BaseLayerSpec] instance.
  const BaseLayerSpec({
    required this.type,
    this.serviceKey,
    this.portalKey,
    this.itemId,
  });

  /// Factory constructor to deserialize [BaseLayerSpec] from a JSON map.
  factory BaseLayerSpec.fromJson(Map<String, dynamic> json) => BaseLayerSpec(
        type: json['type'] as String,
        serviceKey: json['serviceKey'] as String?,
        portalKey: json['portalKey'] as String?,
        itemId: json['itemId'] as String?,
      );
}

/// Configuration structure for a basemap option.
class BasemapConfig {
  /// Display label for the basemap tile in UI.
  final String label;

  /// Asset path or URL for the basemap thumbnail image.
  final String thumbnailAsset;

  /// List of underlying base layers constituting the basemap.
  final List<BaseLayerSpec> baseLayers;

  /// Constructs a [BasemapConfig] instance.
  const BasemapConfig({
    required this.label,
    required this.thumbnailAsset,
    required this.baseLayers,
  });

  /// Factory constructor to deserialize [BasemapConfig] from a JSON map.
  factory BasemapConfig.fromJson(Map<String, dynamic> json) => BasemapConfig(
        label: json['label'] as String,
        thumbnailAsset: json['thumbnailAsset'] as String,
        baseLayers: (json['baseLayers'] as List)
            .map((e) => BaseLayerSpec.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Configuration structure for a sublayer inside a map image layer.
class SublayerEntry {
  /// Display name of the sublayer.
  final String name;

  /// Data source classification ('url', etc.).
  final String source;

  /// REST service URL for the sublayer.
  final String? url;

  /// Key resolving to a portal URI in [EsriMapConfig.portals].
  final String? portalKey;

  /// Optional item ID for portal items.
  final String? itemId;

  /// Refresh timer interval in seconds (0 = disabled).
  final int refreshInterval;

  /// Whether popup feature information is enabled for this sublayer.
  final bool popup;

  /// Optional template string for feature popups.
  final String? popupTemplate;

  /// Constructs a [SublayerEntry] instance.
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

  /// Factory constructor to deserialize [SublayerEntry] from a JSON map.
  factory SublayerEntry.fromJson(Map<String, dynamic> json) => SublayerEntry(
        name: json['name'] as String,
        source: json['source'] as String,
        url: json['url'] as String?,
        portalKey: json['portalKey'] as String?,
        itemId: json['itemId'] as String?,
        refreshInterval: (json['refreshInterval'] as num?)?.toInt() ?? 0,
        popup: json['popup'] as bool? ?? false,
        popupTemplate: json['popupTemplate'] as String?,
      );
}

/// Configuration structure for an operational layer toggle.
class LayerEntry {
  /// Display label for the layer in UI.
  final String label;

  /// Asset path or URL for the layer thumbnail image.
  final String thumbnailAsset;

  /// Data source type string.
  final String? source;

  /// REST service URL for the layer.
  final String? url;

  /// Key resolving to a portal URI in [EsriMapConfig.portals].
  final String? portalKey;

  /// Optional item ID for portal items.
  final String? itemId;

  /// Refresh timer interval in seconds (0 = disabled).
  final int refreshInterval;

  /// Whether popup feature information is enabled.
  final bool popup;

  /// Optional template string for feature popups.
  final String? popupTemplate;

  /// Optional list of sublayers if this is a composite layer.
  final List<SublayerEntry>? sublayers;

  /// Constructs a [LayerEntry] instance.
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

  /// Returns true if sublayers list is non-null and not empty.
  bool get hasSublayers {
    final hasSub = sublayers != null && sublayers!.isNotEmpty;
    return hasSub;
  }

  /// Factory constructor to deserialize [LayerEntry] from a JSON map.
  factory LayerEntry.fromJson(Map<String, dynamic> json) {
    final sublayersJson = json['sublayers'];
    final hasSublayersJson = sublayersJson != null;

    return LayerEntry(
      label: json['label'] as String,
      thumbnailAsset: json['thumbnailAsset'] as String,
      source: json['source'] as String?,
      url: json['url'] as String?,
      portalKey: json['portalKey'] as String?,
      itemId: json['itemId'] as String?,
      refreshInterval: (json['refreshInterval'] as num?)?.toInt() ?? 0,
      popup: json['popup'] as bool? ?? false,
      popupTemplate: json['popupTemplate'] as String?,
      sublayers: hasSublayersJson
          ? (sublayersJson as List).map((e) => SublayerEntry.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }
}

/// Configuration structure for a 3D scene mode.
class SceneConfig {
  /// Display label for the scene option.
  final String label;

  /// Scene view type ('2d' or 'scene').
  final String type;

  /// Key resolving to a portal URI in [EsriMapConfig.portals].
  final String? portalKey;

  /// Item ID for the 3D WebScene item in ArcGIS Online / Enterprise.
  final String? itemId;

  /// Constructs a [SceneConfig] instance.
  const SceneConfig({
    required this.label,
    required this.type,
    this.portalKey,
    this.itemId,
  });

  /// Factory constructor to deserialize [SceneConfig] from a JSON map.
  factory SceneConfig.fromJson(Map<String, dynamic> json) => SceneConfig(
        label: json['label'] as String,
        type: json['type'] as String,
        portalKey: json['portalKey'] as String?,
        itemId: json['itemId'] as String?,
      );
}

/// Feature flags controlling availability of experimental app capabilities remotely.
class FeaturesConfig {
  /// Whether AI natural language search sheet is enabled.
  final bool aiSearch;

  /// Whether 3D scene modes are enabled.
  final bool scenes;

  /// Constructs a [FeaturesConfig] instance.
  const FeaturesConfig({
    required this.aiSearch,
    required this.scenes,
  });

  /// Factory constructor to deserialize [FeaturesConfig] from a JSON map.
  factory FeaturesConfig.fromJson(Map<String, dynamic> json) => FeaturesConfig(
        aiSearch: json['aiSearch'] as bool? ?? false,
        scenes: json['scenes'] as bool? ?? false,
      );
}

/// Configuration structure for a search category quick-filter chip.
class SearchCategoryConfig {
  /// Display label for the category.
  final String label;

  /// POI class string used to query backend server.
  final String poiClass;

  /// Icon name key mapped via [iconDataForName].
  final String icon;

  /// Hexadecimal color string (e.g. "#F5F0E6").
  final String? color;

  /// Constructs a [SearchCategoryConfig] instance.
  const SearchCategoryConfig({
    required this.label,
    required this.poiClass,
    required this.icon,
    this.color,
  });

  /// Factory constructor to deserialize [SearchCategoryConfig] from a JSON map.
  factory SearchCategoryConfig.fromJson(Map<String, dynamic> json) => SearchCategoryConfig(
        label: json['label'] as String,
        poiClass: json['poiClass'] as String,
        icon: json['icon'] as String,
        color: json['color'] as String?,
      );
}

/// Root configuration container object holding all map settings.
class EsriMapConfig {
  /// Map of portal keys to portal endpoint URIs.
  final Map<String, String> portals;

  /// Map of service keys to ArcGIS REST endpoint URLs.
  final Map<String, String> serviceUrls;

  /// Map of basemap keys to basemap configuration objects.
  final Map<String, BasemapConfig> basemaps;

  /// Map of layer keys to operational layer entries.
  final Map<String, LayerEntry> layers;

  /// Map of scene keys to 3D scene mode configurations.
  final Map<String, SceneConfig> scenes;

  /// Remote feature flags config.
  final FeaturesConfig features;

  /// Quick-search category entries.
  final List<SearchCategoryConfig> searchCategories;

  /// Constructs an [EsriMapConfig] instance.
  const EsriMapConfig({
    required this.portals,
    required this.serviceUrls,
    required this.basemaps,
    required this.layers,
    required this.scenes,
    required this.features,
    required this.searchCategories,
  });

  /// Factory constructor to deserialize root [EsriMapConfig] from a JSON map.
  factory EsriMapConfig.fromJson(Map<String, dynamic> json) => EsriMapConfig(
        portals: (json['portals'] as Map<String, dynamic>).cast<String, String>(),
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
        features: FeaturesConfig.fromJson(json['features'] as Map<String, dynamic>),
        searchCategories: (json['searchCategories'] as List)
            .map((e) => SearchCategoryConfig.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
