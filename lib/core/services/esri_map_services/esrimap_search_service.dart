/// ============================================================================
/// File: esrimap_search_service.dart
/// Description: Service handling REST API requests for campus buildings & POIs,
///              as well as persisting recent search history to SharedPreferences.
/// ============================================================================

import 'dart:convert';
import 'dart:math' as math;

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/map_search_result.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service class managing location queries, POI class lookup, and local search history.
class EsriMapSearchService {
  /// Base API URL endpoint.
  static const String BASE_URL = 'https://appzxi70zi.execute-api.us-west-2.amazonaws.com/test/ArcGIS-Map';

  /// SharedPreferences key used to persist recent searches.
  static const String RECENT_SEARCHES_KEY = 'esri_map_recent_searches';

  /// Maximum number of recent searches retained.
  static const int MAX_RECENT_SEARCHES = 5;

  // ---------------------------------------------------------------------------
  // REST API Helpers
  // ---------------------------------------------------------------------------

  /// Performs an HTTP GET request to the specified [path] with optional query [params].
  static Future<Map<String, dynamic>> apiGet(String path, [Map<String, String>? params]) async {
    final uri = Uri.parse('$BASE_URL/$path').replace(queryParameters: params);
    final response = await http.get(uri);
    final isResNotOk = response.statusCode != 200;
    if (isResNotOk) throw Exception('API error ${response.statusCode}: ${response.body}');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Performs an HTTP POST request to the specified [path] with a JSON [body].
  static Future<Map<String, dynamic>> apiPost(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final isResNotOk = response.statusCode != 200;
    if (isResNotOk) throw Exception('API error ${response.statusCode}: ${response.body}');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// Queries campus buildings matching the search string [query].
  static Future<List<MapSearchResult>> queryBuildings(String query) async {
    final data = await apiGet('buildings', {'q': query});
    return (data['results'] as List<dynamic>? ?? [])
        .map<MapSearchResult>((r) {
          return MapSearchResult(
            name: r['name'] as String? ?? 'Unknown Building',
            subtitle: r['subtitle'] as String? ?? 'Building',
            latitude: (r['latitude'] as num?)?.toDouble() ?? 0.0,
            longitude: (r['longitude'] as num?)?.toDouble() ?? 0.0,
            source: MapSearchSource.building,
            address: r['address'] as String? ?? '',
          );
        })
        .where((r) => r.latitude != 0.0 && r.longitude != 0.0)
        .toList();
  }

  /// Fetches all available POI class strings from the backend.
  static Future<List<String>> fetchAllPoiClasses() async {
    try {
      final data = await apiGet('poi/classes');
      return (data['classes'] as List<dynamic>? ?? []).map((c) => c as String).toList();
    } catch (e) {
      debugPrint('Failed to fetch POI classes: $e');
      return [];
    }
  }

  /// Queries POIs matching the search string [query].
  static Future<List<MapSearchResult>> queryPOIs(String query) async {
    final data = await apiGet('poi', {'q': query});
    return parsePOIResults(data);
  }

  /// Queries POIs belonging to a specific [classValue] (e.g. "Dining", "Parking").
  static Future<List<MapSearchResult>> queryPOIsByClass(String classValue) async {
    final data = await apiGet('poi', {'class': classValue, 'limit': '100'});
    return parsePOIResults(data);
  }

  /// Parses raw JSON response maps into a list of [MapSearchResult] objects.
  static List<MapSearchResult> parsePOIResults(Map<String, dynamic> data) {
    return (data['results'] as List<dynamic>? ?? [])
        .map<MapSearchResult>((r) {
          return MapSearchResult(
            name: r['name'] as String? ?? 'Unknown POI',
            subtitle: r['subtitle'] as String? ?? '',
            latitude: (r['latitude'] as num?)?.toDouble() ?? 0.0,
            longitude: (r['longitude'] as num?)?.toDouble() ?? 0.0,
            source: MapSearchSource.poi,
            description: r['description'] as String? ?? '',
            websiteUrl: r['websiteUrl'] as String?,
          );
        })
        .where((r) => r.latitude != 0.0 && r.longitude != 0.0)
        .toList();
  }

  /// Identifies a building by performing a spatial intersection query at the given WGS84 coordinate.
  static Future<MapSearchResult?> identifyBuildingAtCoordinate(double lat, double lng) async {
    try {
      final uri = Uri.parse('https://admin-enterprise-gis.ucsd.edu/server/rest/services/Buildings/Buildings_Campus_Map/MapServer/2/query');
      final response = await http.get(uri.replace(queryParameters: {
        'geometry': '$lng,$lat',
        'geometryType': 'esriGeometryPoint',
        'inSR': '4326',
        'spatialRel': 'esriSpatialRelIntersects',
        'distance': '15',
        'units': 'esriSRUnit_Foot',
        'outFields': '*',
        'returnGeometry': 'true',
        'outSR': '4326',
        'f': 'json',
      }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List<dynamic>?;
        if (features != null && features.isNotEmpty) {
          final attr = features.first['attributes'] as Map<String, dynamic>;
          
          final longName = attr['GIS.facTririgaBuildingInfo.FacilityLongName'] as String?;
          final shortName = attr['GIS.facTririgaBuildingInfo.FacilityShortName'] as String?;
          String name = (longName != null && longName.isNotEmpty) ? longName : (shortName ?? 'Unknown Building');
          String address = attr['GIS.facTririgaBuildingInfo.StreetAddress'] as String? ?? '';
          
          // Try to extract center of geometry if it's returned, otherwise fallback to tap location
          double resLat = lat;
          double resLng = lng;
          Polygon? footprintPolygon;
          
          final geom = features.first['geometry'] as Map<String, dynamic>?;
          if (geom != null) {
            final rings = geom['rings'] as List<dynamic>?;
            if (rings != null && rings.isNotEmpty) {
              final firstRing = rings.first as List<dynamic>?;
              if (firstRing != null && firstRing.isNotEmpty) {
                double minX = double.infinity, maxX = double.negativeInfinity;
                double minY = double.infinity, maxY = double.negativeInfinity;
                for (final point in firstRing) {
                  final coords = point as List<dynamic>;
                  final x = (coords[0] as num).toDouble();
                  final y = (coords[1] as num).toDouble();
                  if (x < minX) minX = x;
                  if (x > maxX) maxX = x;
                  if (y < minY) minY = y;
                  if (y > maxY) maxY = y;
                }
                resLng = (minX + maxX) / 2;
                resLat = (minY + maxY) / 2;
              }
              
              try {
                final builder = PolygonBuilder(spatialReference: SpatialReference.wgs84);
                for (final ring in rings) {
                  final part = MutablePart(spatialReference: SpatialReference.wgs84);
                  final ringPoints = ring as List<dynamic>;
                  for (final point in ringPoints) {
                    final coords = point as List<dynamic>;
                    part.addPointXY(x: (coords[0] as num).toDouble(), y: (coords[1] as num).toDouble());
                  }
                  builder.parts.addPart(part);
                }
                footprintPolygon = builder.toGeometry() as Polygon?;
              } catch (e) {
                debugPrint('Failed to parse polygon geometry: $e');
              }
            }
          }
          
          if (name == 'Unknown Building') {
            final fallbackUrl = Uri.parse('https://admin-enterprise-gis.ucsd.edu/server/rest/services/Buildings/Buildings_Campus_Map/MapServer/0/query');
            try {
              final fallbackRes = await http.get(fallbackUrl.replace(queryParameters: {
                'geometry': '$resLng,$resLat',
                'geometryType': 'esriGeometryPoint',
                'inSR': '4326',
                'spatialRel': 'esriSpatialRelIntersects',
                'distance': '100', // 100 feet from center of footprint
                'units': 'esriSRUnit_Foot',
                'outFields': '*',
                'returnGeometry': 'false',
                'f': 'json',
              }));
              if (fallbackRes.statusCode == 200) {
                final fallbackData = jsonDecode(fallbackRes.body);
                final fallbackFeatures = fallbackData['features'] as List<dynamic>?;
                if (fallbackFeatures != null && fallbackFeatures.isNotEmpty) {
                  final fbAttr = fallbackFeatures.first['attributes'] as Map<String, dynamic>;
                  final fbLong = fbAttr['GIS.facTririgaBuildingInfo.FacilityLongName'] as String?;
                  final fbShort = fbAttr['GIS.facTririgaBuildingInfo.FacilityShortName'] as String?;
                  if (fbLong != null && fbLong.isNotEmpty) {
                    name = fbLong;
                  } else if (fbShort != null && fbShort.isNotEmpty) {
                    name = fbShort;
                  }
                  final fbAddr = fbAttr['GIS.facTririgaBuildingInfo.StreetAddress'] as String?;
                  if (fbAddr != null && fbAddr.isNotEmpty) {
                    address = fbAddr;
                  }
                }
              }
            } catch (_) {}
          }

          return MapSearchResult(
            name: name,
            subtitle: 'Building',
            latitude: resLat,
            longitude: resLng,
            source: MapSearchSource.building,
            address: address,
            footprint: footprintPolygon,
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to identify building at coordinate: $e');
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Viewport & Geographic Helpers
  // ---------------------------------------------------------------------------

  /// Filters a list of [results] down to those located within the specified [envelope].
  static List<MapSearchResult> filterToViewport(List<MapSearchResult> results, Envelope? envelope) {
    final isEnvelopeNull = envelope == null;
    if (isEnvelopeNull) return results;
    return results.where((r) {
      return r.latitude >= envelope.yMin &&
          r.latitude <= envelope.yMax &&
          r.longitude >= envelope.xMin &&
          r.longitude <= envelope.xMax;
    }).toList();
  }

  /// Calculates the Haversine distance in meters between two geographical WGS84 coordinates.
  static double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0; // Earth radius in meters
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) * math.sin(dLng / 2) * math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  // ---------------------------------------------------------------------------
  // Recent Searches Persistence
  // ---------------------------------------------------------------------------

  /// Loads stored recent searches from [SharedPreferences].
  static Future<List<MapSearchResult>> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(RECENT_SEARCHES_KEY);
    final hasJsonStr = jsonStr != null;
    if (hasJsonStr) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((e) => MapSearchResult.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        // Return empty on corrupt stored data
      }
    }
    return [];
  }

  /// Saves the current list of [searches] to [SharedPreferences].
  static Future<void> saveRecentSearches(List<MapSearchResult> searches) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(searches.map((r) => r.toJson()).toList());
    await prefs.setString(RECENT_SEARCHES_KEY, jsonStr);
  }
}
