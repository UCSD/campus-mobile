/// ============================================================================
/// File: esrimap_basemap_factory.dart
/// Description: Factory service constructing ArcGIS [Basemap] instances from
///              [EsriMapConfig] layer specifications.
/// ============================================================================

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_basemaps.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_config.dart';

/// Constructs an ArcGIS [Basemap] for the requested [type] using configuration settings in [config].
///
/// Vector Tile Basemaps ([BasemapStyle.arcGISLightGrayBase] and [BasemapStyle.arcGISDarkGrayBase])
/// are used as the foundation layer because they provide seamless worldwide vector coverage down
/// to room/building level (Level 22+) without triggering "Map data not yet available" raster tile cutoffs.
/// Custom UCSD campus vector tile layers are layered on top.
Basemap buildBasemap(BasemapType type, EsriMapConfig config) {
  // 1. Satellite Basemap: Use global World Imagery layer.
  if (type == BasemapType.satellite) {
    final basemap = Basemap();
    basemap.baseLayers.add(
      ArcGISTiledLayer.withUri(
        Uri.parse('https://services.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer'),
      ),
    );
    return basemap;
  }

  // 2. Vector Basemaps: Initialize with global vector tile base styles.
  // arcGISLightGrayBase for Default/Light, and arcGISDarkGrayBase for Dark mode.
  final basemap = switch (type) {
    BasemapType.dark => Basemap.withStyle(BasemapStyle.arcGISDarkGrayBase),
    _ => Basemap.withStyle(BasemapStyle.arcGISLightGrayBase),
  };

  // 3. Retrieve campus vector tile layer specifications from configuration.
  final entry = config.basemaps[basemapKey(type)];
  final portalUrl = config.portals['age'] ?? 'https://admin-enterprise-gis.ucsd.edu/portal';

  // Extract vector layers from config entry if present (ignoring legacy raster arcgisTiled layers)
  final vectorLayers = entry?.baseLayers.where((l) => l.type == 'arcgisVectorTiled').toList() ?? [];

  if (vectorLayers.isNotEmpty) {
    for (final layer in vectorLayers) {
      final pUrl = layer.portalKey != null ? config.portals[layer.portalKey!] : portalUrl;
      if (pUrl != null && layer.itemId != null) {
        basemap.baseLayers.add(
          ArcGISVectorTiledLayer.withItem(
            PortalItem.withPortalAndItemId(
              portal: Portal(Uri.parse(pUrl)),
              itemId: layer.itemId!,
            ),
          ),
        );
      }
    }
  } else {
    // Fallback: Use known default UCSD campus vector layer item IDs if config entry is missing
    final fallbackItemId = switch (type) {
      BasemapType.light => '6643ee62af494f5bafe7dfdb8eb3f857',
      BasemapType.dark => '09d7b3934b6c4c2cad8380c04e08c1b1',
      _ => 'e19f33d2c1f44967aef673306c483913',
    };

    basemap.baseLayers.add(
      ArcGISVectorTiledLayer.withItem(
        PortalItem.withPortalAndItemId(
          portal: Portal(Uri.parse(portalUrl)),
          itemId: fallbackItemId,
        ),
      ),
    );
  }

  return basemap;
}

