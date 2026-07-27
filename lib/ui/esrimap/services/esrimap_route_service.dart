/// ============================================================================
/// File: esrimap_route_service.dart
/// Description: Service handling route calculation via the ArcGIS Campus
///              Wayfinding Network NAServer.
/// ============================================================================

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:campus_mobile_experimental/ui/esrimap/models/map_search_result.dart';
import 'package:flutter/material.dart';

/// Result data structure holding the outcome of a solved route calculation.
class EsriRouteResult {
  /// Travel duration in minutes.
  final double travelTimeMinutes;

  /// List of direction maneuver instructions (turn-by-turn steps).
  final List<DirectionManeuver> directionManeuvers;

  /// Visual geometry polyline representing the calculated route.
  final Geometry? routeGeometry;

  /// Envelope bounding box centered with padding for map viewpoint framing.
  final Envelope? paddedExtent;

  /// Constructs an [EsriRouteResult] instance.
  const EsriRouteResult({
    required this.travelTimeMinutes,
    required this.directionManeuvers,
    this.routeGeometry,
    this.paddedExtent,
  });
}

/// Service class encapsulating ArcGIS Route Task execution.
class EsriMapRouteService {
  /// Endpoint URL for the UCSD Campus Wayfinding Network service.
  static const String ROUTE_SERVICE_URL =
      'https://admin-enterprise-gis.ucsd.edu/server/rest/services/'
      'Wayfinding/Campus_Wayfinding_Network/NAServer/Route';

  /// Solves a network route between [originLatLng] and [destination] for the given [travelMode].
  static Future<EsriRouteResult?> solveRoute({
    required (double lat, double lng) originLatLng,
    required MapSearchResult destination,
    required String travelMode,
  }) async {
    try {
      final routeTask = RouteTask.withUri(Uri.parse(ROUTE_SERVICE_URL));
      await routeTask.load();

      final params = await routeTask.createDefaultParameters();
      params.returnDirections = true;

      // Match requested travel mode ('Walking', 'Accessible', etc.)
      final taskInfo = routeTask.getRouteTaskInfo();
      final matchingMode = taskInfo.travelModes.where((m) => m.name == travelMode).firstOrNull;
      if (matchingMode != null) params.travelMode = matchingMode;

      // Configure origin and destination stops
      final origin = Stop(
        ArcGISPoint(x: originLatLng.$2, y: originLatLng.$1, spatialReference: SpatialReference.wgs84),
      );
      final dest = Stop(
        ArcGISPoint(x: destination.longitude, y: destination.latitude, spatialReference: SpatialReference.wgs84),
      );
      params.setStops([origin, dest]);

      // Solve route
      final result = await routeTask.solveRoute(params);
      final isResultEmpty = result.routes.isEmpty;
      if (isResultEmpty) return null;

      final route = result.routes.first;
      final routeGeometry = route.routeGeometry;
      final isGeometryNull = routeGeometry == null;
      if (isGeometryNull) return null;

      // Compute padded extent so the route line stays visible above bottom sheets
      final extent = routeGeometry.extent;
      final dx = extent.width * 0.2;
      final dyTop = extent.height * 0.5;
      final dyBottom = extent.height * 0.75;
      final paddedExtent = Envelope.fromXY(
        xMin: extent.xMin - dx,
        yMin: extent.yMin - dyBottom,
        xMax: extent.xMax + dx,
        yMax: extent.yMax + dyTop,
        spatialReference: extent.spatialReference,
      );

      return EsriRouteResult(
        travelTimeMinutes: route.totalTime,
        directionManeuvers: route.directionManeuvers,
        routeGeometry: routeGeometry,
        paddedExtent: paddedExtent,
      );
    } catch (e) {
      debugPrint('Route solve error: $e');
      return null;
    }
  }
}
