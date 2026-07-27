import 'package:arcgis_maps/arcgis_maps.dart';
import 'esrimap_config.dart';

enum BasemapType { defaultMap, light, dark, satellite }

String basemapKey(BasemapType type) {
  switch (type) {
    case BasemapType.defaultMap: return 'defaultMap';
    case BasemapType.light:      return 'light';
    case BasemapType.dark:       return 'dark';
    case BasemapType.satellite:  return 'satellite';
  }
}

BasemapType? basemapTypeFromKey(String key) {
  switch (key) {
    case 'defaultMap': return BasemapType.defaultMap;
    case 'light':      return BasemapType.light;
    case 'dark':       return BasemapType.dark;
    case 'satellite':  return BasemapType.satellite;
    default:           return null;
  }
}

Basemap buildBasemap(BasemapType type, EsriMapConfig config) {
  final entry = config.basemaps[basemapKey(type)];
  if (entry == null) return Basemap();

  final basemap = Basemap();
  for (final layer in entry.baseLayers) {
    switch (layer.type) {
      case 'arcgisTiled':
        final url = layer.serviceKey != null
            ? config.serviceUrls[layer.serviceKey!]
            : null;
        if (url != null) basemap.baseLayers.add(ArcGISTiledLayer.withUri(Uri.parse(url)));
        break;

      case 'arcgisVectorTiled':
        final portalUrl = layer.portalKey != null
            ? config.portals[layer.portalKey!]
            : null;
        final hasPortalAndItem = portalUrl != null && layer.itemId != null;
        if (hasPortalAndItem) {
          basemap.baseLayers.add(
            ArcGISVectorTiledLayer.withItem(
              PortalItem.withPortalAndItemId(
                portal: Portal(Uri.parse(portalUrl)),
                itemId: layer.itemId!,
              ),
            ),
          );
        }
        break;

      case 'arcgisMapImage':
        final url = layer.serviceKey != null
            ? config.serviceUrls[layer.serviceKey!]
            : null;
        if (url != null) basemap.baseLayers.add(ArcGISMapImageLayer.withUri(Uri.parse(url)));
        break;
    }
  }
  return basemap;
