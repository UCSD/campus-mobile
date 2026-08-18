/// ============================================================================
/// File: map_search_result.dart
/// Description: Represents a unified search result for both campus buildings
///              and points of interest (POIs) in the Esri Map widget.
/// ============================================================================

/// Identifies the origin/type of search result.
enum MapSearchSource {
  /// Result represents a physical building on campus.
  building,

  /// Result represents a Point of Interest (POI) such as dining, parking, etc.
  poi,
}

/// Unified search result model encapsulating location details, coordinates,
/// description, and serialization logic for recent search persistence.
class MapSearchResult {
  /// Name or title of the building or POI.
  final String name;

  /// Subtitle or secondary detail string (e.g. building code or category).
  final String subtitle;

  /// Latitude coordinate of the location.
  final double latitude;

  /// Longitude coordinate of the location.
  final double longitude;

  /// Source classification indicating whether this is a building or a POI.
  final MapSearchSource source;

  /// Physical address string of the location.
  final String address;

  /// Detailed textual description or additional metadata.
  final String description;

  /// Optional website URL associated with this location.
  final String? websiteUrl;

  /// Optional polygon geometry for the building footprint. Not serialized to JSON.
  final dynamic footprint;

  /// Constructs a [MapSearchResult] instance.
  const MapSearchResult({
    required this.name,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
    required this.source,
    this.address = '',
    this.description = '',
    this.websiteUrl,
    this.footprint,
  });

  /// Serializes the search result into a JSON-compatible map for storage in SharedPreferences.
  Map<String, dynamic> toJson() => {
    'name': name,
    'subtitle': subtitle,
    'latitude': latitude,
    'longitude': longitude,
    'source': source.index,
    'address': address,
    'description': description,
    'websiteUrl': websiteUrl,
  };

  /// Factory constructor to deserialize a [MapSearchResult] from a JSON map.
  factory MapSearchResult.fromJson(Map<String, dynamic> json) {
    return MapSearchResult(
      name: json['name'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      source: MapSearchSource.values[json['source'] as int? ?? 0],
      address: json['address'] as String? ?? '',
      description: json['description'] as String? ?? '',
      websiteUrl: json['websiteUrl'] as String?,
    );
  }
}
