/// ============================================================================
/// File: esrimap_basemap_factory.dart
/// Description: Factory service constructing ArcGIS [Basemap] instances from
///              [EsriMapConfig] layer specifications.
/// ============================================================================

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_basemaps.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_config.dart';

/// Constructs an ArcGIS [Basemap] for the requested [type] using configuration settings in [config].
Basemap buildBasemap(BasemapType type, EsriMapConfig config) {
  final entry = config.basemaps[basemapKey(type)];
  final isEntryNull = entry == null;
  if (isEntryNull) return Basemap();

  final basemap = Basemap();
  for (final layer in entry.baseLayers) {
    switch (layer.type) {
      case 'arcgisTiled':
        final hasServiceKey = layer.serviceKey != null;
        final url = hasServiceKey ? config.serviceUrls[layer.serviceKey!] : null;
        final isUrlNotNull = url != null;
        if (isUrlNotNull) basemap.baseLayers.add(ArcGISTiledLayer.withUri(Uri.parse(url)));
        break;

      case 'arcgisVectorTiled':
        final hasPortalKey = layer.portalKey != null;
        final portalUrl = hasPortalKey ? config.portals[layer.portalKey!] : null;
        final hasPortalAndItem = portalUrl != null && layer.itemId != null;
        if (hasPortalAndItem) {
          basemap.baseLayers.add(
            ArcGISVectorTiledLayer.withItem(
              PortalItem.withPortalAndItemId(portal: Portal(Uri.parse(portalUrl)), itemId: layer.itemId!),
            ),
          );
        }
        break;

      case 'arcgisMapImage':
        final hasServiceKey = layer.serviceKey != null;
        final url = hasServiceKey ? config.serviceUrls[layer.serviceKey!] : null;
        final isUrlNotNull = url != null;
        if (isUrlNotNull) basemap.baseLayers.add(ArcGISMapImageLayer.withUri(Uri.parse(url)));
        break;
    }
  }
  return basemap;
}
