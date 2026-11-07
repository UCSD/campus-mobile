/// ============================================================================
/// File: esrimap_basemaps.dart
/// Description: Enum models and conversion utilities for basemap types
///              (Default, Light, Dark, Satellite).
/// ============================================================================

/// Enumeration representing available basemap styles on the map view.
enum BasemapType {
  /// Default standard campus vector map basemap.
  defaultMap,

  /// Light neutral canvas basemap.
  light,

  /// Dark slate mode basemap.
  dark,

  /// Satellite imagery basemap.
  satellite,
}

/// Converts a [BasemapType] enum value into its corresponding configuration string key.
String basemapKey(BasemapType type) {
  switch (type) {
    case BasemapType.defaultMap:
      return 'defaultMap';
    case BasemapType.light:
      return 'light';
    case BasemapType.dark:
      return 'dark';
    case BasemapType.satellite:
      return 'satellite';
  }
}

/// Converts a raw string key into a matching [BasemapType] enum, or null if unmapped.
BasemapType? basemapTypeFromKey(String key) {
  switch (key) {
    case 'defaultMap':
      return BasemapType.defaultMap;
    case 'light':
      return BasemapType.light;
    case 'dark':
      return BasemapType.dark;
    case 'satellite':
      return BasemapType.satellite;
    default:
      return null;
  }
}
