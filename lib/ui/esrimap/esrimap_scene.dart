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
  }

  void _onSceneViewReady() {
    final portal = Portal(Uri.parse(widget.portalUri));
    final portalItem = PortalItem.withPortalAndItemId(
      portal: portal,
      itemId: widget.itemId,
    );
    _sceneViewController.arcGISScene = ArcGISScene.withItem(portalItem);
  }

  @override
  Widget build(BuildContext context) {
    return ArcGISSceneView(
      controllerProvider: () => _sceneViewController,
      onSceneViewReady: _onSceneViewReady,
    );
  }
}
