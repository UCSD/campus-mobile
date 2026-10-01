import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

List<Map<String, dynamic>>? _districts;

Future<void> loadCampusDistricts() async {
  if (_districts != null) return;
  final String jsonString = await rootBundle.loadString('assets/data/campus_districts.json');
  _districts = List<Map<String, dynamic>>.from(json.decode(jsonString));
}

/// Returns the campus district containing (lat, lon), or 'Other' if none match.
/// `rings` are stored as [lon, lat] pairs (ArcGIS/GeoJSON convention).
String districtForLocation(double lat, double lon) {
  final districts = _districts;
  if (districts == null) return 'Other';

  for (final feature in districts) {
    final rings = feature['rings'] as List<dynamic>;
    bool inside = false;
    for (final ring in rings) {
      if (_pointInRing(lat, lon, ring as List<dynamic>)) inside = !inside;
    }
    if (inside) return feature['district'] as String;
  }
  return 'Other';
}

/// Even-odd ray-casting test for a single ring of [lon, lat] points.
bool _pointInRing(double lat, double lon, List<dynamic> ring) {
  bool inside = false;
  for (int i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    final double lonI = ring[i][0].toDouble(), latI = ring[i][1].toDouble();
    final double lonJ = ring[j][0].toDouble(), latJ = ring[j][1].toDouble();

    final bool crosses = (latI > lat) != (latJ > lat);
    if (!crosses) continue;

    final double xIntersect = lonI + (lat - latI) * (lonJ - lonI) / (latJ - latI);
    if (lon < xIntersect) inside = !inside;
  }
  return inside;
}
