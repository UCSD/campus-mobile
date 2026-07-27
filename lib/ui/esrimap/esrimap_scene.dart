import 'dart:async';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';

class EsriSceneWidget extends StatefulWidget {
  final String portalUri;
  final String itemId;
  final void Function(double heading)? onHeadingChanged;

  const EsriSceneWidget({super.key, required this.portalUri, required this.itemId, this.onHeadingChanged});

  @override
  State<EsriSceneWidget> createState() => EsriSceneWidgetState();
}

class EsriSceneWidgetState extends State<EsriSceneWidget> {
  late final ArcGISSceneViewController _sceneViewController;
  Camera? _initialCamera;
  double _camToTargetLatOffset = 0.0;
  StreamSubscription<void>? _viewpointSubscription;

  @override
  void initState() {
    super.initState();
    _sceneViewController = ArcGISSceneView.createController();
    _sceneViewController.interactionOptions.rotateEnabled = true;
    _sceneViewController.interactionOptions.panEnabled = true;
    _sceneViewController.interactionOptions.flingEnabled = true;
    _sceneViewController.interactionOptions.zoomFactor = 3.0;
    _sceneViewController.atmosphereEffect = AtmosphereEffect.none;
    _sceneViewController.spaceEffect = SpaceEffect.transparent;
  }

  void _onSceneViewReady() {
    final portal = Portal(Uri.parse(widget.portalUri));
    final portalItem = PortalItem.withPortalAndItemId(portal: portal, itemId: widget.itemId);
    final scene = ArcGISScene.withItem(portalItem);
    _sceneViewController.arcGISScene = scene;

    _initialCamera = Camera.withLatLong(
      latitude: 32.86872066,
      longitude: -117.23732235,
      altitude: 1062.871,
      heading: 0,
      pitch: 53.261,
      roll: 0,
    );
    _sceneViewController.setViewpointCamera(_initialCamera!);

    // Capture the lat offset between camera and look-at target once the
    // viewpoint stabilizes — used by snapToNorth to rotate around target.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final vp = _sceneViewController.getCurrentViewpoint(ViewpointType.centerAndScale);
      final pt = vp?.targetGeometry;
      if (pt is ArcGISPoint) _camToTargetLatOffset = pt.y - _initialCamera!.location.y;
    });

    _viewpointSubscription = _sceneViewController.onViewpointChanged.listen((_) {
      if (!mounted) return;
      final vp = _sceneViewController.getCurrentViewpoint(ViewpointType.centerAndScale);
      if (vp != null) widget.onHeadingChanged?.call(vp.rotation);
    });

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

  void resetCamera() {
    if (_initialCamera == null) return;
    _sceneViewController.setViewpointCamera(_initialCamera!);
  }

  /// Snaps heading to north by rotating the camera around the current
  /// look-at target so the building/point stays centered on screen.
  void snapToNorth() {
    if (_initialCamera == null) return;
    final vp = _sceneViewController.getCurrentViewpoint(ViewpointType.centerAndScale);
    final target = vp?.targetGeometry;
    if (target is! ArcGISPoint) {
      resetCamera();
      return;
    }

    // Position camera due south of the current target at the same distance
    // as the initial camera-to-target offset
    final pivotLat = target.y;
    final pivotLon = target.x;
    final camAlt = _initialCamera!.location.z ?? 1062.871;

    _sceneViewController.setViewpointCamera(
      Camera.withLatLong(
        latitude: pivotLat - _camToTargetLatOffset,
        longitude: pivotLon,
        altitude: camAlt,
        heading: 0,
        pitch: _initialCamera!.pitch,
        roll: 0,
      ),
    );
  }

  @override
  void dispose() {
    _viewpointSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ArcGISSceneView(controllerProvider: () => _sceneViewController, onSceneViewReady: _onSceneViewReady);
  }
}
