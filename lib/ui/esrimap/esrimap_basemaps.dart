/* Basemap config for campus map

There are three basemaps with three layers each.
1. World Hillshade shows terrain relief and adds depth to non campus areas
2. Esri world context fills off campus areas
3. UCSD Campus Vector Tile layer loaded from AGE
 */

import 'package:arcgis_maps/arcgis_maps.dart';

enum BasemapType { defaultMap, light, dark }

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

final _agePortal = Portal(
  Uri.parse('https://admin-enterprise-gis.ucsd.edu/portal'),
);

/// Build a basemap of the given type. Safe to call multiple times; each
/// call returns an independent Basemap instance with freshly constructed
/// layers.
Basemap buildBasemap(BasemapType type) {
  final hillshade = ArcGISTiledLayer.withUri(Uri.parse(_hillshadeUri));
  final esriContext = _esriContextLayer(type);
  final ucsdLayer = _ucsdCampusLayer(type);

  final basemap = Basemap();
  basemap.baseLayers.add(hillshade);
  basemap.baseLayers.add(esriContext);
  basemap.baseLayers.add(ucsdLayer);
  return basemap;
}

ArcGISTiledLayer _esriContextLayer(BasemapType type) {
  switch (type) {
    case BasemapType.defaultMap:
      return ArcGISTiledLayer.withUri(Uri.parse(_worldTopoUri));
    case BasemapType.light:
      return ArcGISTiledLayer.withUri(Uri.parse(_lightGrayBaseUri));
    case BasemapType.dark:
      return ArcGISTiledLayer.withUri(Uri.parse(_darkGrayBaseUri));
  }
}

ArcGISVectorTiledLayer _ucsdCampusLayer(BasemapType type) {
  final portalItem = PortalItem.withPortalAndItemId(
    portal: _agePortal,
    itemId: basemapOptions[type]!.itemId,
  );
  return ArcGISVectorTiledLayer.withItem(portalItem);
}