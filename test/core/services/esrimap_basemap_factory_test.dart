import 'dart:convert';
import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_basemaps.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EsriMapConfig & Vector Basemaps', () {
    test('mapConfig.json parses Living Atlas and UCSD vector tile basemap configurations correctly', () async {
      final configString = await rootBundle.loadString('assets/esri_map_assets/mapConfig.json');
      final jsonMap = jsonDecode(configString) as Map<String, dynamic>;
      final config = EsriMapConfig.fromJson(jsonMap);

      // Verify Default basemap includes Living Atlas Light Gray vector base and UCSD campus vector tile
      final defaultBasemap = config.basemaps['defaultMap'];
      expect(defaultBasemap, isNotNull);
      expect(defaultBasemap!.baseLayers.length, 2);
      expect(defaultBasemap.baseLayers.any((l) => l.itemId == '291da5eab3a0412593b66d384379f89f'), isTrue);
      expect(defaultBasemap.baseLayers.any((l) => l.itemId == 'e19f33d2c1f44967aef673306c483913'), isTrue);

      // Verify Light basemap includes Living Atlas Light Gray vector base and UCSD campus vector tile
      final lightBasemap = config.basemaps['light'];
      expect(lightBasemap, isNotNull);
      expect(lightBasemap!.baseLayers.length, 2);
      expect(lightBasemap.baseLayers.any((l) => l.itemId == '291da5eab3a0412593b66d384379f89f'), isTrue);
      expect(lightBasemap.baseLayers.any((l) => l.itemId == '6643ee62af494f5bafe7dfdb8eb3f857'), isTrue);

      // Verify Dark basemap includes Living Atlas Dark Gray vector base and UCSD campus vector tile
      final darkBasemap = config.basemaps['dark'];
      expect(darkBasemap, isNotNull);
      expect(darkBasemap!.baseLayers.length, 2);
      expect(darkBasemap.baseLayers.any((l) => l.itemId == '5e9b3685f4c24d8781073dd928ebda50'), isTrue);
      expect(darkBasemap.baseLayers.any((l) => l.itemId == '09d7b3934b6c4c2cad8380c04e08c1b1'), isTrue);

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
