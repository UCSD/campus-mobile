/// ============================================================================
/// File: esrimap_boundary_service.dart
/// Description: Service providing UC San Diego campus boundary geometry loading
///              and constructing subtle off-campus vignette masks with feathered
///              perimeter highlighting to stylize non-campus map regions.
/// ============================================================================

import 'dart:convert';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_basemaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

/// Service managing campus boundary geometry and vignette overlay graphic generation.
class EsriMapBoundaryService {
  /// Singleton instance accessor.
  static final EsriMapBoundaryService instance = EsriMapBoundaryService._();
  EsriMapBoundaryService._();

  /// Asset bundle path for pre-packaged campus boundary JSON geometry.
  static const String BOUNDARY_ASSET_PATH = 'assets/esri_map_assets/ucsd_boundary.json';

  /// Live REST endpoint querying official UCSD campus boundary features (Layer 3).
  static const String BOUNDARY_SERVICE_URL =
      'https://admin-enterprise-gis.ucsd.edu/server/rest/services/AdministrationServices/Areas_and_Boundaries/MapServer/3/query?where=1%3D1&outFields=*&returnGeometry=true&outSR=4326&f=json';

  List<Polygon>? _cachedPolygons;

  /// Loads and caches UC San Diego campus boundary [Polygon] geometries.
  /// First attempts to read from bundled local asset, with live network fallback.
  Future<List<Polygon>> loadCampusBoundaries() async {
    if (_cachedPolygons != null && _cachedPolygons!.isNotEmpty) {
      return _cachedPolygons!;
    }

    String? jsonString;

    // 1. Attempt loading from bundled offline asset for instant startup
    try {
      jsonString = await rootBundle.loadString(BOUNDARY_ASSET_PATH);
    } catch (e) {
      debugPrint('Local boundary asset load failed ($e), falling back to remote endpoint...');
    }

    // 2. Fallback to live REST query if local asset was unavailable
    if (jsonString == null || jsonString.isEmpty) {
      try {
        final response = await http.get(Uri.parse(BOUNDARY_SERVICE_URL)).timeout(const Duration(seconds: 6));
        if (response.statusCode == 200) {
          jsonString = response.body;
        }
      } catch (e) {
        debugPrint('Remote boundary fetch failed: $e');
      }
    }

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    // 3. Deserialize JSON features into ArcGIS Polygon geometries
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? [];
      final polygons = <Polygon>[];

      for (final feature in features) {
        final geometryMap = feature['geometry'] as Map<String, dynamic>?;
        if (geometryMap != null && geometryMap['rings'] != null) {
          final poly = Geometry.fromJson({
            'rings': geometryMap['rings'],
            'spatialReference': {'wkid': 4326},
          });
          if (poly is Polygon) {
            polygons.add(poly);
          }
        }
      }

      _cachedPolygons = polygons;
      return polygons;
    } catch (e) {
      debugPrint('Failed to parse boundary geometries: $e');
      return [];
    }
  }

  /// Constructs vignette overlay graphics (inverted off-campus mask + feathered perimeter lines).
  ///
  /// The inverted mask covers the region outside the campus perimeter with a soft translucent
  /// tint, while multi-tiered feathered perimeter lines create a smooth aesthetic glow around
  /// UC San Diego.
  List<Graphic> createVignetteGraphics({
    required BasemapType basemapType,
    required List<Polygon> campusBoundaries,
  }) {
    if (campusBoundaries.isEmpty) return [];

    final graphics = <Graphic>[];

    // Theme-specific color configuration
    final (maskColor, primaryStrokeColor, glow1Color, glow2Color) = _getColorsForBasemap(basemapType);

    // -------------------------------------------------------------------------
    // 1. Inverted Mask (Dims off-campus areas, keeping campus 100% vibrant)
    // -------------------------------------------------------------------------
    try {
      // Large bounding box encompassing the world in WGS84
      final outerBox = Geometry.fromJson({
        'rings': [
          [
            [-180.0, -85.0],
            [-180.0, 85.0],
            [180.0, 85.0],
            [180.0, -85.0],
            [-180.0, -85.0],
          ],
        ],
        'spatialReference': {'wkid': 4326},
      });

      // Subtract all campus boundary polygons from the world box to create a cutout hole
      Geometry maskedArea = outerBox;
      for (final boundary in campusBoundaries) {
        final diff = GeometryEngine.difference(geometry1: maskedArea, geometry2: boundary);
        if (diff != null) {
          maskedArea = diff;
        }
      }

      final maskSymbol = SimpleFillSymbol(
        style: SimpleFillSymbolStyle.solid,
        color: maskColor,
        outline: null,
      );

      graphics.add(Graphic(geometry: maskedArea, symbol: maskSymbol));
    } catch (e) {
      debugPrint('Error constructing inverted vignette mask: $e');
    }

    // -------------------------------------------------------------------------
    // 2. Feathered Perimeter Highlighting (Soft glow rings around campus boundary)
    // -------------------------------------------------------------------------
    for (final boundary in campusBoundaries) {
      try {
        final polyline = boundary.toPolyline();

        // Outer glow layer 2 (Widest, most diffuse feather ring)
        graphics.add(
          Graphic(
            geometry: polyline,
            symbol: SimpleLineSymbol(
              style: SimpleLineSymbolStyle.solid,
              color: glow2Color,
              width: 8.0,
            ),
          ),
        );

        // Outer glow layer 1 (Medium feather ring)
        graphics.add(
          Graphic(
            geometry: polyline,
            symbol: SimpleLineSymbol(
              style: SimpleLineSymbolStyle.solid,
              color: glow1Color,
              width: 4.5,
            ),
          ),
        );

        // Crisp primary boundary stroke (UCSD Navy / Brand Accent)
        graphics.add(
          Graphic(
            geometry: polyline,
            symbol: SimpleLineSymbol(
              style: SimpleLineSymbolStyle.solid,
              color: primaryStrokeColor,
              width: 1.8,
            ),
          ),
        );
      } catch (e) {
        debugPrint('Error creating boundary perimeter lines: $e');
      }
    }

    return graphics;
  }

  /// Returns styling colors matched to the active [BasemapType].
  (Color mask, Color primaryStroke, Color glow1, Color glow2) _getColorsForBasemap(BasemapType type) {
    switch (type) {
      case BasemapType.dark:
        return (
          const Color(0x38000000), // ~22% dark dimming
          const Color(0xAA00629B), // Bright UCSD blue stroke
          const Color(0x3500629B), // Medium blue glow
          const Color(0x1500629B), // Diffuse blue glow
        );

      case BasemapType.satellite:
        return (
          const Color(0x22000000), // ~13% soft vignette
          const Color(0xCCFFCD00), // UCSD Gold stroke on satellite
          const Color(0x40FFCD00), // Medium gold glow
          const Color(0x18FFCD00), // Diffuse gold glow
        );

      case BasemapType.defaultMap:
      case BasemapType.light:
      default:
        return (
          const Color(0x1F000000), // ~12% soft neutral dimming
          const Color(0x9900629B), // UCSD Navy stroke
          const Color(0x3000629B), // Medium navy glow
          const Color(0x1200629B), // Diffuse navy glow
        );
    }
  }
}
