import 'dart:convert';
import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_basemaps.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EsriMapConfig & Vector Tile Basemaps', () {
    test('mapConfig.json parses vector tile basemap configurations correctly', () async {
      final configString = await rootBundle.loadString('assets/esri_map_assets/mapConfig.json');
      final jsonMap = jsonDecode(configString) as Map<String, dynamic>;
      final config = EsriMapConfig.fromJson(jsonMap);

      // Verify Default basemap uses vector tiled layer without legacy raster layers
      final defaultBasemap = config.basemaps['defaultMap'];
      expect(defaultBasemap, isNotNull);
      expect(defaultBasemap!.baseLayers.length, 1);
      expect(defaultBasemap.baseLayers.first.type, 'arcgisVectorTiled');
      expect(defaultBasemap.baseLayers.first.itemId, 'e19f33d2c1f44967aef673306c483913');

      // Verify Light basemap uses vector tiled layer
      final lightBasemap = config.basemaps['light'];
      expect(lightBasemap, isNotNull);
      expect(lightBasemap!.baseLayers.length, 1);
      expect(lightBasemap.baseLayers.first.type, 'arcgisVectorTiled');
      expect(lightBasemap.baseLayers.first.itemId, '6643ee62af494f5bafe7dfdb8eb3f857');

      // Verify Dark basemap uses vector tiled layer
      final darkBasemap = config.basemaps['dark'];
      expect(darkBasemap, isNotNull);
      expect(darkBasemap!.baseLayers.length, 1);
      expect(darkBasemap.baseLayers.first.type, 'arcgisVectorTiled');
      expect(darkBasemap.baseLayers.first.itemId, '09d7b3934b6c4c2cad8380c04e08c1b1');

      // Verify Satellite basemap uses worldImagery
      final satelliteBasemap = config.basemaps['satellite'];
      expect(satelliteBasemap, isNotNull);
      expect(satelliteBasemap!.baseLayers.any((l) => l.serviceKey == 'worldImagery'), isTrue);
    });

    test('basemapKey and basemapTypeFromKey mapping', () {
      expect(basemapKey(BasemapType.defaultMap), 'defaultMap');
      expect(basemapKey(BasemapType.light), 'light');
      expect(basemapKey(BasemapType.dark), 'dark');
      expect(basemapKey(BasemapType.satellite), 'satellite');

      expect(basemapTypeFromKey('defaultMap'), BasemapType.defaultMap);
      expect(basemapTypeFromKey('light'), BasemapType.light);
      expect(basemapTypeFromKey('dark'), BasemapType.dark);
      expect(basemapTypeFromKey('satellite'), BasemapType.satellite);
    });
  });
}
