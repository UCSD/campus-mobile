import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';

import 'esrimap_basemaps.dart';

class EsriSceneWidget extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;

  const EsriSceneWidget({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
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
    _sceneViewController.interactionOptions.rotateEnabled = false;
  }

  SimpleRenderer _makeExtrusionRenderer(String heightField) {
    final symbol = SimpleFillSymbol(
      style: SimpleFillSymbolStyle.solid,
      color: const Color(0xFFD3D3D3),
    );
    final renderer = SimpleRenderer(symbol: symbol);
    renderer.sceneProperties = RendererSceneProperties.withExtrusionProperties(
      extrusionExpression: '[$heightField] * 0.3048',
      extrusionMode: ExtrusionMode.maximum,
    );
    return renderer;
  }

  void _onSceneViewReady() {
    final scene = ArcGISScene.withBasemap(buildBasemap(BasemapType.defaultMap));

    final elevationSource = ArcGISTiledElevationSource.withUri(
      Uri.parse('https://elevation3d.arcgis.com/arcgis/rest/services/'
          'WorldElevation3D/Terrain3D/ImageServer'),
    );
    scene.baseSurface.elevationSources.add(elevationSource);
    scene.baseSurface.isEnabled = true;

    final layerDefs = [
      (
        url: 'https://admin-enterprise-gis.ucsd.edu/server/rest/services/'
            'Hosted/LRT/FeatureServer/0',
        heightField: 'Height',
        placement: SurfacePlacement.relative,
      ),
      (
        url: 'https://admin-enterprise-gis.ucsd.edu/server/rest/services/'
            'Hosted/GeiselLibrary/FeatureServer/0',
        heightField: 'Height',
        placement: SurfacePlacement.absolute,
      ),
      (
        url: 'https://admin-enterprise-gis.ucsd.edu/server/rest/services/'
            'Hosted/Building_Extrusions/FeatureServer/0',
        heightField: 'bldght',
        placement: SurfacePlacement.relative,
      ),
      (
        url: 'https://admin-enterprise-gis.ucsd.edu/server/rest/services/'
            'Hosted/Building_Extrusions/FeatureServer/1',
        heightField: 'bldght',
        placement: SurfacePlacement.relative,
      ),
      (
        url: 'https://admin-enterprise-gis.ucsd.edu/server/rest/services/'
            'Hosted/Building_Extrusions/FeatureServer/2',
        heightField: 'bldght',
        placement: SurfacePlacement.relative,
      ),
    ];

    for (final def in layerDefs) {
      final table = ServiceFeatureTable.withUri(Uri.parse(def.url));
      final layer = FeatureLayer.withFeatureTable(table);
      layer.renderer = _makeExtrusionRenderer(def.heightField);
      layer.sceneProperties.surfacePlacement = def.placement;
      scene.operationalLayers.add(layer);
    }

    final camera = Camera.withLatLong(
      latitude: widget.initialLatitude,
      longitude: widget.initialLongitude,
      altitude: 600.0,
      heading: 0.0,
      pitch: 65.0,
      roll: 0.0,
    );
    scene.initialViewpoint = Viewpoint.withLatLongScaleCamera(
      latitude: widget.initialLatitude,
      longitude: widget.initialLongitude,
      scale: 10000.0,
      camera: camera,
    );

    _sceneViewController.arcGISScene = scene;
  }

  @override
  Widget build(BuildContext context) {
    return ArcGISSceneView(
      controllerProvider: () => _sceneViewController,
      onSceneViewReady: _onSceneViewReady,
    );
  }
}
