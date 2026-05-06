import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';

class EsriSceneWidget extends StatefulWidget {
  final String portalUri;
  final String itemId;

  const EsriSceneWidget({
    super.key,
    required this.portalUri,
    required this.itemId,
  });

  @override
  State<EsriSceneWidget> createState() => _EsriSceneWidgetState();
}

class _EsriSceneWidgetState extends State<EsriSceneWidget> {
  late final ArcGISSceneViewController _sceneViewController;

  @override
  void initState() {
    super.initState();
    _sceneViewController = ArcGISSceneView.createController();
    _sceneViewController.interactionOptions.rotateEnabled = true;
    _sceneViewController.interactionOptions.panEnabled = true;
    // Reduce GPU overhead: skip atmosphere and star-field rendering
    _sceneViewController.atmosphereEffect = AtmosphereEffect.none;
    _sceneViewController.spaceEffect = SpaceEffect.transparent;
  }

  void _onSceneViewReady() {
    final portal = Portal(Uri.parse(widget.portalUri));
    final portalItem = PortalItem.withPortalAndItemId(
      portal: portal,
      itemId: widget.itemId,
    );
    final scene = ArcGISScene.withItem(portalItem);
    _sceneViewController.arcGISScene = scene;
    _applyLabelScales(scene);
  }

  // Restrict building labels to only appear when zoomed in close (scale <= 4000)
  Future<void> _applyLabelScales(ArcGISScene scene) async {
    await scene.load();
    _applyLabelScalesToLayers(scene.operationalLayers);
  }

  void _applyLabelScalesToLayers(List<Layer> layers) {
    for (final layer in layers) {
      if (layer is FeatureLayer) {
        for (final labelDef in layer.labelDefinitions) {
          labelDef.minScale = 4000;
        }
      } else if (layer is GroupLayer) {
        _applyLabelScalesToLayers(layer.layers);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ArcGISSceneView(
      controllerProvider: () => _sceneViewController,
      onSceneViewReady: _onSceneViewReady,
    );
  }
}
