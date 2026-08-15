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
/// Public ArcGIS tiled MapServer layers (e.g. World_Light_Gray_Base, World_Hillshade, World_Dark_Gray_Base)
/// provide the geographical base imagery (coastlines, islands, terrain, ocean) as a background.
///
/// To prevent the "Map data not yet available" raster watermark tiles from ever appearing when zooming in
/// closer than Level 16 (scale ~1:9,000), [NoDataTileBehavior.upSample] and [maxScale] = 0 are configured
/// on each tiled layer. This automatically stretches and resamples the coarser tiles smoothly in the background,
/// while the custom UCSD campus vector tile layer draws sharp building and street details on top.
Basemap buildBasemap(BasemapType type, EsriMapConfig config) {
  // 1. Satellite Basemap: Use global World Imagery layer with tile upsampling.
  if (type == BasemapType.satellite) {
    final basemap = Basemap();
    final tiledLayer = ArcGISTiledLayer.withUri(
      Uri.parse('https://services.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer'),
    );
    tiledLayer.noDataTileBehavior = NoDataTileBehavior.upSample;
    tiledLayer.maxScale = 0;
    basemap.baseLayers.add(tiledLayer);
    return basemap;
  }

  final entry = config.basemaps[basemapKey(type)];
  final isEntryNull = entry == null;
  if (isEntryNull) return Basemap();

  final basemap = Basemap();
  final portalUrl = config.portals['age'] ?? 'https://admin-enterprise-gis.ucsd.edu/portal';

  // 2. Iterate through configured base layers
  for (final layer in entry.baseLayers) {
    switch (layer.type) {
      case 'arcgisTiled':
        final hasServiceKey = layer.serviceKey != null;
        final url = hasServiceKey ? config.serviceUrls[layer.serviceKey!] : null;
        final isUrlNotNull = url != null;
        if (isUrlNotNull) {
          final tiledLayer = ArcGISTiledLayer.withUri(Uri.parse(url));
          // Key fix: Upsample coarser tiles instead of displaying "Map data not yet available" watermark
          tiledLayer.noDataTileBehavior = NoDataTileBehavior.upSample;
          tiledLayer.maxScale = 0;
          basemap.baseLayers.add(tiledLayer);
        }
        break;

      case 'arcgisVectorTiled':
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
        break;

      case 'arcgisMapImage':
        final hasServiceKey = layer.serviceKey != null;
        final url = hasServiceKey ? config.serviceUrls[layer.serviceKey!] : null;
        final isUrlNotNull = url != null;
        if (isUrlNotNull) {
          basemap.baseLayers.add(ArcGISMapImageLayer.withUri(Uri.parse(url)));
        }
        break;
    }
  }

  // 3. Fallback: If no vector layer was present in the config, append known UCSD vector layer
  final hasVectorLayer = basemap.baseLayers.any((l) => l is ArcGISVectorTiledLayer);
  if (!hasVectorLayer) {
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
