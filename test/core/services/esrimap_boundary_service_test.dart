import 'dart:convert';
import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_basemaps.dart';
import 'package:campus_mobile_experimental/core/services/esri_map_services/esrimap_boundary_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EsriMapBoundaryService & Campus Boundary Asset', () {
    test('ucsd_boundary.json asset is present and contains valid polygon rings', () async {
      final jsonString = await rootBundle.loadString(EsriMapBoundaryService.BOUNDARY_ASSET_PATH);
      expect(jsonString, isNotEmpty);

      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>?;
      expect(features, isNotNull);
      expect(features!.isNotEmpty, isTrue);

      // Verify that features contain geometry with coordinates / rings
      for (final feature in features) {
        final geometry = (feature as Map<String, dynamic>)['geometry'] as Map<String, dynamic>?;
        expect(geometry, isNotNull);
        final rings = geometry!['rings'] as List<dynamic>?;
        expect(rings, isNotNull);
        expect(rings!.isNotEmpty, isTrue);
      }
    });

    test('createVignetteGraphics returns empty list when given empty boundaries', () {
      final graphics = EsriMapBoundaryService.instance.createVignetteGraphics(
        basemapType: BasemapType.defaultMap,
        campusBoundaries: [],
      );
      expect(graphics, isEmpty);
    });

    test('Boundary service constants are configured properly', () {
      expect(EsriMapBoundaryService.BOUNDARY_ASSET_PATH, 'assets/esri_map_assets/ucsd_boundary.json');
      expect(
        EsriMapBoundaryService.BOUNDARY_SERVICE_URL,
        contains('Areas_and_Boundaries/MapServer/3'),
      );
    });
  });
}
