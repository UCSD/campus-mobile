/* Basemap config for campus map

There are three basemaps with three layers each.
1. World Hillshade shows terrain relief and adds depth to non campus areas
2. Esri world context fills off campus areas
3. UCSD Campus Vector Tile layer loaded from AGE
 */

import 'package:arcgis_maps/arcgis_maps.dart';

enum BasemapType { defaultMap, light, dark, satellite }

class BasemapOption {
  final String label;
  final String itemId;
  const BasemapOption({
    required this.label,
    required this.itemId,
  });
}

const basemapOptions = <BasemapType, BasemapOption>{
  BasemapType.defaultMap: BasemapOption(
    label: 'Default',
    itemId: 'e19f33d2c1f44967aef673306c483913',
  ),
  BasemapType.light: BasemapOption(
    label: 'Light',
    itemId: '6643ee62af494f5bafe7dfdb8eb3f857',
  ),
  BasemapType.dark: BasemapOption(
    label: 'Dark',
    itemId: '09d7b3934b6c4c2cad8380c04e08c1b1',
  ),
  BasemapType.satellite: BasemapOption(
    label: 'Satellite',
    itemId: '6643ee62af494f5bafe7dfdb8eb3f857',
  ),
};

// Esri world tile service URIs (raster).
const _hillshadeUri =
    'https://services.arcgisonline.com/arcgis/rest/services/'
    'Elevation/World_Hillshade/MapServer';

const _worldTopoUri =
    'https://services.arcgisonline.com/arcgis/rest/services/'
    'World_Topo_Map/MapServer';

const _lightGrayBaseUri =
    'https://services.arcgisonline.com/arcgis/rest/services/'
    'Canvas/World_Light_Gray_Base/MapServer';

const _darkGrayBaseUri =
    'https://services.arcgisonline.com/arcgis/rest/services/'
    'Canvas/World_Dark_Gray_Base/MapServer';

// Nearmap tile service
const _nearmapUri =
    'https://admin-enterprise-gis.ucsd.edu/server/rest/services/'
    'Campus_Imagery_Nearmap_9in_2025_0423_0514/MapServer';

// AGE portal for campus vector tiles
final _agePortal = Portal(
  Uri.parse('https://admin-enterprise-gis.ucsd.edu/portal'),
);

/// Build a basemap of the given type. Safe to call multiple times; each
/// call returns an independent Basemap instance with freshly constructed
/// layers.
Basemap buildBasemap(BasemapType type) {
  final basemap = Basemap();

  if (type == BasemapType.satellite) {
    // Light gray fallback + Nearmap imagery + campus vector
    basemap.baseLayers.add(ArcGISTiledLayer.withUri(Uri.parse(_lightGrayBaseUri)));
    basemap.baseLayers.add(ArcGISMapImageLayer.withUri(Uri.parse(_nearmapUri)));
  } else {
    basemap.baseLayers.add(ArcGISTiledLayer.withUri(Uri.parse(_hillshadeUri)));
    basemap.baseLayers.add(_esriContextLayer(type));
  }

  if (type != BasemapType.satellite) {
    basemap.baseLayers.add(_ucsdCampusLayer(type));
  }
  return basemap;
}

ArcGISTiledLayer _esriContextLayer(BasemapType type) {
  switch (type) {
    case BasemapType.defaultMap:
      return ArcGISTiledLayer.withUri(Uri.parse(_lightGrayBaseUri));
    case BasemapType.light:
      return ArcGISTiledLayer.withUri(Uri.parse(_lightGrayBaseUri));
    case BasemapType.dark:
      return ArcGISTiledLayer.withUri(Uri.parse(_darkGrayBaseUri));
    case BasemapType.satellite:
      return ArcGISTiledLayer.withUri(Uri.parse(_lightGrayBaseUri));
  }
}

ArcGISVectorTiledLayer _ucsdCampusLayer(BasemapType type) {
  final portalItem = PortalItem.withPortalAndItemId(
    portal: _agePortal,
    itemId: basemapOptions[type]!.itemId,
  );
  return ArcGISVectorTiledLayer.withItem(portalItem);
}