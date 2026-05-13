import 'package:arcgis_maps/arcgis_maps.dart';
import 'esrimap_config.dart';

enum BasemapType { defaultMap, light, dark, satellite }

// Label lookup -- used by the layers panel
const basemapLabels = <BasemapType, String>{
  BasemapType.defaultMap: 'Default',
  BasemapType.light:      'Light',
  BasemapType.dark:       'Dark',
  BasemapType.satellite:  'Satellite',
};

String _typeKey(BasemapType type) {
  switch (type) {
    case BasemapType.defaultMap: return 'defaultMap';
    case BasemapType.light:      return 'light';
    case BasemapType.dark:       return 'dark';
    case BasemapType.satellite:  return 'satellite';
  }
}

Basemap buildBasemap(BasemapType type, EsriMapConfig config) {
  final basemap = Basemap();
  final agePortal = Portal(Uri.parse(config.agePortalUrl));

  if (type == BasemapType.satellite) {
    basemap.baseLayers.add(
      ArcGISTiledLayer.withUri(Uri.parse(config.esriTileUrls.lightGrayBase)),
    );
    basemap.baseLayers.add(
      ArcGISMapImageLayer.withUri(Uri.parse(config.nearmapUrl)),
    );
  } else {
    basemap.baseLayers.add(
      ArcGISTiledLayer.withUri(Uri.parse(config.esriTileUrls.hillshade)),
    );
    final contextUrl = type == BasemapType.dark
        ? config.esriTileUrls.darkGrayBase
        : config.esriTileUrls.lightGrayBase;
    basemap.baseLayers.add(
      ArcGISTiledLayer.withUri(Uri.parse(contextUrl)),
    );
    final itemId = config.basemaps[_typeKey(type)]?.itemId;
    if (itemId != null) {
      basemap.baseLayers.add(
        ArcGISVectorTiledLayer.withItem(
          PortalItem.withPortalAndItemId(portal: agePortal, itemId: itemId),
        ),
      );
    }
  }

  return basemap;
}