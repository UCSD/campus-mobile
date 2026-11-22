/// ============================================================================
/// File: esrimap_ai_search_model.dart
/// Description: Data models for AI natural language search queries, including
///              location search results, route stops, and response wrappers.
/// ============================================================================

/// Location search result returned by AI search endpoint.
class AiSearchResult {
  /// Name or title of location.
  final String name;

  /// Subtitle / category tag.
  final String subtitle;

  /// Physical address string.
  final String address;

  /// Latitude coordinate.
  final double latitude;

  /// Longitude coordinate.
  final double longitude;

  /// Optional distance in feet.
  final int? distanceFeet;

  /// Optional formatted distance string (e.g. "0.3 mi").
  final String? distanceFormatted;

  /// Constructs an [AiSearchResult] instance.
  const AiSearchResult({
    required this.name,
    required this.subtitle,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distanceFeet,
    this.distanceFormatted,
  });

  /// Factory constructor to deserialize [AiSearchResult] from a JSON map.
  factory AiSearchResult.fromJson(Map<String, dynamic> j) => AiSearchResult(
    name: j['name'] as String,
    subtitle: j['subtitle'] as String? ?? '',
    address: j['address'] as String? ?? '',
    latitude: (j['latitude'] as num).toDouble(),
    longitude: (j['longitude'] as num).toDouble(),
    distanceFeet: j['distanceFeet'] as int?,
    distanceFormatted: j['distanceFormatted'] as String?,
  );
}

/// Geographical coordinate stop along a multi-stop AI route.
class AiSearchRouteStop {
  /// Latitude coordinate.
  final double lat;

  /// Longitude coordinate.
  final double lon;

  /// Constructs an [AiSearchRouteStop] instance.
  const AiSearchRouteStop({required this.lat, required this.lon});

  /// Factory constructor to deserialize [AiSearchRouteStop] from a JSON map.
  factory AiSearchRouteStop.fromJson(Map<String, dynamic> j) =>
      AiSearchRouteStop(lat: (j['lat'] as num).toDouble(), lon: (j['lon'] as num).toDouble());
}

/// Response payload returned from AI search REST API endpoint.
class AiSearchResponse {
  /// Explanatory text or response message.
  final String message;

  /// List of matching location search results.
  final List<AiSearchResult> results;

  /// Optional list of stop names for suggested routes.
  final List<String>? routeStopNames;

  /// Optional list of stop coordinates for suggested routes.
  final List<AiSearchRouteStop>? routeStopCoords;

  /// Constructs an [AiSearchResponse] instance.
  const AiSearchResponse({required this.message, required this.results, this.routeStopNames, this.routeStopCoords});

  /// Factory constructor to deserialize [AiSearchResponse] from a JSON map.
  factory AiSearchResponse.fromJson(Map<String, dynamic> j) {
    List<String>? stopNames;
    List<AiSearchRouteStop>? stopCoords;
    final route = j['suggestedRoute'];
    final hasRoute = route != null;
    if (hasRoute) {
      stopNames = (route['stops'] as List).cast<String>();
      stopCoords = (route['stopCoords'] as List)
          .map((s) => AiSearchRouteStop.fromJson(s as Map<String, dynamic>))
          .toList();
    }
    return AiSearchResponse(
      message: j['message'] as String,
      results: (j['results'] as List).map((r) => AiSearchResult.fromJson(r as Map<String, dynamic>)).toList(),
      routeStopNames: stopNames,
      routeStopCoords: stopCoords,
    );
  }
}
