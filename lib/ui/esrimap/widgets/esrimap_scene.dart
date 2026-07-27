/// ============================================================================
/// File: esrimap_scene.dart
/// Description: Widget wrapper for rendering 3D ArcGIS WebScene portals,
///              handling camera viewpoint controls, label scaling, and snap-to-north.
/// ============================================================================

import 'dart:async';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';

/// Stateful widget encapsulating an [ArcGISSceneView] for 3D building and drone scene layers.
class EsriSceneWidget extends StatefulWidget {
  /// Portal URI key.
  final String portalUri;

  /// WebScene Portal Item ID.
  final String itemId;

  /// Callback when camera rotation heading changes.
  final void Function(double heading)? onHeadingChanged;

  /// Constructs an [EsriSceneWidget] instance.
  const EsriSceneWidget({
    super.key,
    required this.portalUri,
    required this.itemId,
    this.onHeadingChanged,
  });

  @override
  State<EsriSceneWidget> createState() => EsriSceneWidgetState();
}

/// State object managing 3D camera controls and scene initialization.
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

    // Capture camera to target offset once viewpoint stabilizes
    Future.delayed(const Duration(milliseconds: 500), () {
      final isNotMounted = !mounted;
      if (isNotMounted) return;
      final vp = _sceneViewController.getCurrentViewpoint(ViewpointType.centerAndScale);
      final pt = vp?.targetGeometry;
      final isPoint = pt is ArcGISPoint;
      if (isPoint) _camToTargetLatOffset = pt.y - _initialCamera!.location.y;
    });

    _viewpointSubscription = _sceneViewController.onViewpointChanged.listen((_) {
      final isNotMounted = !mounted;
      if (isNotMounted) return;
      final vp = _sceneViewController.getCurrentViewpoint(ViewpointType.centerAndScale);
      final isVpNotNull = vp != null;
      if (isVpNotNull) widget.onHeadingChanged?.call(vp.rotation);
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
      final isFeatureLayer = layer is FeatureLayer;
      final isGroupLayer = layer is GroupLayer;
      if (isFeatureLayer) {
        for (final labelDef in layer.labelDefinitions) {
          labelDef.minScale = 4000;
        }
      } else if (isGroupLayer) {
        _applyLabelScalesToLayers(layer.layers);
      }
    }
  }

  /// Resets 3D camera to initial campus view coordinates.
  void resetCamera() {
    final isInitialCameraNull = _initialCamera == null;
    if (isInitialCameraNull) return;
    _sceneViewController.setViewpointCamera(_initialCamera!);
  }

  /// Snaps heading to north by rotating camera around current look-at target.
  void snapToNorth() {
    final isInitialCameraNull = _initialCamera == null;
    if (isInitialCameraNull) return;
    final vp = _sceneViewController.getCurrentViewpoint(ViewpointType.centerAndScale);
    final target = vp?.targetGeometry;
    final isNotPoint = target is! ArcGISPoint;
    if (isNotPoint) {
      resetCamera();
      return;
    }

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
  Widget build(BuildContext context) =>
      ArcGISSceneView(controllerProvider: () => _sceneViewController, onSceneViewReady: _onSceneViewReady);
}
