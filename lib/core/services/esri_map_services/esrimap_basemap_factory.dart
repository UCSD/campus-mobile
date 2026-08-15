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
/// To provide complete geographical background (coastlines, ocean, islands, regional streets)
/// without ever displaying "Map data not yet available" raster watermarks or requiring API keys:
/// 1. Public Esri Living Atlas Vector Tile base layers are used as the foundation (Light Gray / Dark Gray Canvas Base).
///    Vector tiles scale seamlessly to building/room level (Level 22+) without tile cutoff watermarks.
/// 2. Custom UC San Diego campus vector tile layers are layered directly on top to display campus-specific facilities.
Basemap buildBasemap(BasemapType type, EsriMapConfig config) {
  // 1. Satellite Basemap: Use modern BasemapStyle for optimized CDN routing and faster raster loading.
  if (type == BasemapType.satellite) return Basemap.withStyle(BasemapStyle.arcGISImagery);

  final basemap = Basemap();

  // 2. Global Public Vector Tile Base (Coastlines, ocean, off-campus streets, islands)
  // Living Atlas Item IDs (100% public, keyless vector tile services hosted by Esri):
  // - Light Gray Canvas Base: 291da5eab3a0412593b66d384379f89f
  // - Dark Gray Canvas Base:  5e9b3685f4c24d8781073dd928ebda50
  final globalBaseItemId = switch (type) {
    BasemapType.dark => '5e9b3685f4c24d8781073dd928ebda50',
    _ => '291da5eab3a0412593b66d384379f89f',
  };

  basemap.baseLayers.add(
    ArcGISVectorTiledLayer.withItem(
      PortalItem.withPortalAndItemId(portal: Portal.arcGISOnline(), itemId: globalBaseItemId),
    ),
  );

  // 3. Custom UC San Diego Campus Vector Tile Layer (campus buildings, walkways, landscaping)
  final entry = config.basemaps[basemapKey(type)];
  final portalUrl = config.portals['age'] ?? 'https://admin-enterprise-gis.ucsd.edu/portal';
  final vectorLayers = entry?.baseLayers.where((l) => l.type == 'arcgisVectorTiled').toList() ?? [];

  // Filter out any duplicate reference to the global base item ID
  final campusVectorLayers = vectorLayers.where((l) => l.itemId != globalBaseItemId).toList();

  if (campusVectorLayers.isNotEmpty) {
    for (final layer in campusVectorLayers) {
      final pUrl = layer.portalKey != null ? config.portals[layer.portalKey!] : portalUrl;
      if (pUrl != null && layer.itemId != null) {
        final portal = pUrl.contains('arcgis.com') ? Portal.arcGISOnline() : Portal(Uri.parse(pUrl));
        basemap.baseLayers.add(
          ArcGISVectorTiledLayer.withItem(PortalItem.withPortalAndItemId(portal: portal, itemId: layer.itemId!)),
        );
      }
    }
  } else {
    // Fallback: Append known UCSD campus vector tile layer IDs
    final fallbackItemId = switch (type) {
      BasemapType.light => '6643ee62af494f5bafe7dfdb8eb3f857',
      BasemapType.dark => '09d7b3934b6c4c2cad8380c04e08c1b1',
      _ => 'e19f33d2c1f44967aef673306c483913',
    };

    basemap.baseLayers.add(
      ArcGISVectorTiledLayer.withItem(
        PortalItem.withPortalAndItemId(portal: Portal(Uri.parse(portalUrl)), itemId: fallbackItemId),
      ),
    );
  }

  return basemap;
}
