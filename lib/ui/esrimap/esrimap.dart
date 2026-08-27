/// ============================================================================
/// File: esrimap.dart
/// Description: Main campus Esri map screen widget. Integrates the 2D/3D map view,
///              location display, top search bar, floating action buttons,
///              basemap & operational layer controls, and bottom slide-over panels.
/// ============================================================================

import 'dart:async';
import 'dart:math' as math;

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_ai_search_model.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_basemaps.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_config.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/esrimap_search_category.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/map_search_result.dart';
import 'package:campus_mobile_experimental/core/services/esri_map_services/esrimap_auth_handler.dart';
import 'package:campus_mobile_experimental/core/services/esri_map_services/esrimap_basemap_factory.dart';
import 'package:campus_mobile_experimental/core/services/esri_map_services/esrimap_config_service.dart';
import 'package:campus_mobile_experimental/core/services/esri_map_services/esrimap_route_service.dart';
import 'package:campus_mobile_experimental/core/services/esri_map_services/esrimap_search_service.dart';
import 'package:campus_mobile_experimental/core/utils/esri_map_feature_flags.dart';
import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_ai_search_sheet.dart';
import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_category_list_panel.dart';
import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_detail_slide_over.dart';
import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_fab.dart';
import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_layers_panel.dart';
import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_scale_bar.dart';
import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_scene.dart';
import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_search_bar.dart';
import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_suggestions_panel.dart';
import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_callout_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/core/providers/dining.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/core/providers/availability.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:ui' as ui;

// Re-export MapSearchResult so callers importing esrimap.dart retain access
export 'package:campus_mobile_experimental/core/models/esri_map_models/map_search_result.dart'
    show MapSearchResult, MapSearchSource;

/// Primary StatefulWidget for the interactive Esri Campus Map screen.
class EsriMap extends StatefulWidget {
  /// Constructs an [EsriMap] instance.
  const EsriMap({Key? key}) : super(key: key);

  @override
  State<EsriMap> createState() => _EsriMapState();
}

class _EsriMapState extends State<EsriMap> with AutomaticKeepAliveClientMixin {
  // ---------------------------------------------------------------------------
  // Controllers & Overlay Graphics
  // ---------------------------------------------------------------------------
  final _mapViewController = ArcGISMapView.createController();
  late final ArcGISMap _map;
  final _graphicsOverlay = GraphicsOverlay();
  final _routeGraphicsOverlay = GraphicsOverlay();

  final _searchController = TextEditingController();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  final _focusNode = FocusNode();
  final _fromFocusNode = FocusNode();
  final _toFocusNode = FocusNode();

  final _categorySheetController = DraggableScrollableController();
  final _detailSheetMinimized = ValueNotifier<bool>(false);

  // ---------------------------------------------------------------------------
  // Map State & Services
  // ---------------------------------------------------------------------------
  EsriMapConfig? _config;
  var _locationDataSource = SystemLocationDataSource();

  // Search State
  static const _MINIMUM_SEARCH_LOADING_DURATION = Duration(milliseconds: 400);
  List<MapSearchResult> _searchResults = [];
  List<String> _allPoiClasses = [];
  List<String> _matchingPoiClasses = [];
  bool _showResults = false;
  bool _isSearching = false;
  bool _showSuggestions = false;
  List<MapSearchResult> _recentSearches = [];
  Timer? _searchDebounce;
  int _searchRequestId = 0;

  // Active Category & Pin Plotting State
  MapSearchResult? _selectedResultValue;
  MapSearchResult? get _selectedResult => _selectedResultValue;
  set _selectedResult(MapSearchResult? value) {
    _selectedResultValue = value;
    if (value != null) _detailSheetMinimized.value = false;
  }

  MapSearchResult? _lastSelectedResult;
  List<MapSearchResult> _mappedResults = [];
  List<MapSearchResult> _allCategoryResults = [];
  bool _showCategoryList = false;
  EsriSearchCategory? _activeCategory;

  // FAB & Viewpoint State
  // FAB & Viewpoint State
  bool _isLocatingUser = false;
  bool _isLocationActive = false;
  bool _isRecenterActive = false;
  bool _ignoreViewpointReset = false;
  double _mapRotation = 0.0;
  double _currentScale = 24000.0;
  bool _isDisposed = false;
  StreamSubscription<void>? _viewpointChangedSubscription;
  bool _hasNetworkError = false;

  // Routing State
  bool _isRouting = false;
  bool _hasRoute = false;
  bool _routeFailed = false;
  String _travelMode = 'Walking';
  double _routeTravelTimeMinutes = 0;
  List<DirectionManeuver> _routeManeuvers = [];
  bool _showRouteFields = false;
  String? _activeRouteField;
  (double, double)? _fromLatLng;
  MapSearchResult? _routeDestination;
  ArcGISPoint? _loadingLocation;

  // Basemaps & Operational Layers State
  BasemapType _currentBasemapType = BasemapType.defaultMap;
  final Map<BasemapType, Basemap> _basemaps = {};
  bool _showLayersPanel = false;
  final Map<String, bool> _layerVisible = {};
  final Map<String, bool> _layerLoading = {};
  final Map<String, List<Layer?>> _layerInstances = {};
  final Map<String, Timer> _layerTimers = {};

  // Legend State
  List<LegendInfo> _transitLegend = [];
  Map<String, ui.Image> _transitLegendSwatches = {};
  Map<String, List<dynamic>> _transitRouteLayers = {};
  Map<String, bool> _transitRouteVisibility = {};
  bool _isTransitLegendLoading = false;
  bool _isTransitLegendMinimized = false;

  // 3D Scene Widgets & Keys
  String _sceneMode = 'default';
  EsriSceneWidget? _scene3DWidget;
  EsriSceneWidget? _sceneDroneWidget;
  final _scene3DKey = GlobalKey<EsriSceneWidgetState>();
  final _sceneDroneKey = GlobalKey<EsriSceneWidgetState>();

  var _mapReadyCompleter = Completer<void>();

  /// Returns list of mapped search categories constructed from server configuration.
  List<EsriSearchCategory> get _categories {
    final isConfigNull = _config == null;
    if (isConfigNull) return [];
    return _config!.searchCategories
        .map(
          (c) => EsriSearchCategory(
            label: c.label,
            icon: iconDataForName(c.icon),
            poiClassValue: c.poiClass,
            color: colorFromHex(c.color),
          ),
        )
        .toList();
  }

  @override
  bool get wantKeepAlive => true;

  // ---------------------------------------------------------------------------
  // Lifecycle & Initialization
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _fetchConfigThenInit();
    _loadRecentSearches();
    _focusNode.addListener(_onFocusChanged);
    _fromFocusNode.addListener(_onFromFocusChanged);
    _toFocusNode.addListener(_onToFocusChanged);
  }

  Future<void> _fetchConfigThenInit() async {
    setState(() => _hasNetworkError = false);
    if (_mapReadyCompleter.isCompleted) _mapReadyCompleter = Completer<void>();
    try {
      final config = await EsriMapConfigService.instance.fetch();
      if (!mounted) return;
      setState(() => _config = config);
      _initMap(config);
      _fetchAllPoiClasses();
    } catch (e) {
      debugPrint('Config fetch failed: $e');
      if (mounted) setState(() => _hasNetworkError = true);
      if (!_mapReadyCompleter.isCompleted) _mapReadyCompleter.completeError(e);
    }
  }

  /// Constructs initial basemaps and sets initial campus viewpoint.
  void _initMap(EsriMapConfig config) {
    for (final type in BasemapType.values) {
      var shouldSkipBasemap =
          !FeatureFlags.MAP_ALTERNATE_BASEMAPS_ENABLED && (type == BasemapType.light || type == BasemapType.dark);
      if (shouldSkipBasemap) continue;
      _basemaps[type] = buildBasemap(type, config);
    }

    _map = ArcGISMap.withBasemap(_basemaps[_currentBasemapType]!);
    _map.maxScale = 38.4; // Limit zoom in to scale 1:38.4 (~23.88 max zoom level)
    _map.minScale = 70000000.0; // Limit zoom out to scale 1:70000000.0 (~3.08 min zoom level)
    _map.maxExtent = Envelope.fromXY(
      xMin: -180.0,
      yMin: -55.0,
      xMax: 180.0,
      yMax: 55.0,
      spatialReference: SpatialReference.wgs84,
    );
    _map.initialViewpoint = Viewpoint.fromCenter(
      ArcGISPoint(x: -117.2340, y: 32.8801, spatialReference: SpatialReference.wgs84),
      scale: 24000,
    );
    _mapReadyCompleter.complete();
  }

  /// Configures map view controller, auth handlers, graphics overlays, and viewpoint listeners when ready.
  void _onMapViewReady() async {
    await _mapReadyCompleter.future;
    _setupAgeAuthChallengeHandler();
    _mapViewController.arcGISMap = _map;
    _mapViewController.selectionProperties = SelectionProperties(color: const Color(0xFF34C759));
    _mapViewController.interactionOptions.rotateEnabled = true;

    final isGraphicsOverlayMissing = !_mapViewController.graphicsOverlays.contains(_graphicsOverlay);
    if (isGraphicsOverlayMissing) _mapViewController.graphicsOverlays.add(_graphicsOverlay);
    final isRouteOverlayMissing = !_mapViewController.graphicsOverlays.contains(_routeGraphicsOverlay);
    if (isRouteOverlayMissing) _mapViewController.graphicsOverlays.add(_routeGraphicsOverlay);

    // Configure location display settings
    _mapViewController.locationDisplay.dataSource = _locationDataSource;
    _mapViewController.locationDisplay.autoPanMode = LocationDisplayAutoPanMode.off;
    _mapViewController.locationDisplay.showLocation = true;

    _startLocationDisplay();
    _mapViewController.locationDisplay.onLocationChanged.listen((event) {
      final pos = event.position;
      final wgs = GeometryEngine.project(pos, outputSpatialReference: SpatialReference.wgs84) as ArcGISPoint?;
      final isValidWgs = wgs != null && !wgs.x.isNaN && !wgs.y.isNaN;
      if (isValidWgs) _saveLocationToHive(wgs.y, wgs.x);
    });

    _preloadAlternateBasemaps();
    _preloadHeavyLayers();

    // Track map heading rotation and zoom level changes
    DateTime? lastUpdateTime;

    _viewpointChangedSubscription = _mapViewController.onViewpointChanged.listen((_) {
      final now = DateTime.now();
      var isRecentUpdate = lastUpdateTime != null && now.difference(lastUpdateTime!).inMilliseconds < 32;
      if (isRecentUpdate) return; // Throttle to ~30 FPS to prevent heavy jitter
      lastUpdateTime = now;

      final vp = _mapViewController.getCurrentViewpoint(ViewpointType.centerAndScale);
      final isVpValid = vp != null && mounted;
      if (isVpValid) {
        final scale = vp.targetScale;
        final centerPoint = vp.targetGeometry as ArcGISPoint?;

        setState(() {
          _mapRotation = vp.rotation.isNaN ? 0.0 : vp.rotation;
          _currentScale = scale;
          final shouldResetVP = !_ignoreViewpointReset && (_isLocationActive || _isRecenterActive);
          if (shouldResetVP) {
            _isLocationActive = false;
            _isRecenterActive = false;
          }
        });
      }
    });
  }

  /// Silently preloads computationally expensive operational layers (e.g. portalItem Web Maps)
  /// in the background to ensure instantaneous layer toggling later.
  void _preloadHeavyLayers() async {
    if (_config == null) return;
    for (final entry in _config!.layers.entries) {
      var needsPreload = entry.value.source == 'portalItem' && !_layerInstances.containsKey(entry.key);
      if (needsPreload) {
        final instances = await _buildLayerInstances(entry.key, entry.value);
        _layerInstances[entry.key] = instances;
        for (final layer in instances) {
          if (layer != null) {
            layer.isVisible = false;
            _map.operationalLayers.add(layer);
          }
        }
        try {
          await Future.wait(instances.whereType<Layer>().map((l) => l.load()));
          _applyLayerSpecialCases(entry.key, instances);
        } catch (e) {
          debugPrint('Preload layer error: $e');
        }
      }
    }
  }

  /// Sets authentication manager challenge handler for Enterprise token retrieval.
  void _setupAgeAuthChallengeHandler() {
    ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler = AgeAuthChallengeHandler(
      EsriMapConfigService.instance.tokensUrl,
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _categorySheetController.dispose();
    _detailSheetMinimized.dispose();
    _searchController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    _focusNode.dispose();
    for (final timer in _layerTimers.values) {
      timer.cancel();
    }
    _viewpointChangedSubscription?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Location & Basemaps Helpers
  // ---------------------------------------------------------------------------
  bool _isStartingLocationDataSource = false;

  /// Starts the device location data source.
  Future<void> _startLocationDisplay() async {
    if (!FeatureFlags.MAP_LOCATION_TRACKING_ENABLED) return;
    if (_isStartingLocationDataSource) return;
    _isStartingLocationDataSource = true;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return;
      }

      await _locationDataSource.start().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Location DataSource Start Error: $e');
      final isTimeoutOrFail = e is TimeoutException || e.toString().toLowerCase().contains('fail');
      if (isTimeoutOrFail) {
        _locationDataSource = SystemLocationDataSource();
        _mapViewController.locationDisplay.dataSource = _locationDataSource;
        _locationDataSource.start().catchError((_) {});
      }
    } finally {
      _isStartingLocationDataSource = false;
    }
  }

  /// Efficiently fetches device location falling back from fastest to slowest
  Future<(double, double)?> _getDeviceLocationEfficiently() async {
    _startLocationDisplay();

    // 1. Try internal ArcGIS cached position first
    var gps = _getUserLatLng();
    if (gps != null) return gps;

    // 2. Try Fallback to Geolocator last known position
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) return (lastKnown.latitude, lastKnown.longitude);
    } catch (_) {}

    // 3. Try Hive cached location
    final hiveLocation = await _loadLocationFromHive();
    if (hiveLocation != null) return hiveLocation;

    // 4. Fallback to a fresh fetch
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: Duration(seconds: 5)),
      );
      return (pos.latitude, pos.longitude);
    } catch (_) {}

    return null;
  }

  /// Preloads non-active basemaps into memory.
  void _preloadAlternateBasemaps() {
    for (final entry in _basemaps.entries) {
      final isCurrent = entry.key == _currentBasemapType;
      if (isCurrent) continue;
      entry.value.load().catchError((Object e) {
        debugPrint('Failed to preload basemap ${entry.key}: $e');
      });
    }
  }

  /// Switches active basemap without resetting viewpoint frame.
  void _switchBasemap(BasemapType newType) {
    final isSameType = newType == _currentBasemapType;
    if (isSameType) return;
    final newBasemap = _basemaps[newType];
    final isBasemapNull = newBasemap == null;
    if (isBasemapNull) return;

    setState(() {
      _map.basemap = newBasemap;
      _map.maxScale = 38.4;
      _map.minScale = 70000000.0;
      _map.maxExtent = Envelope.fromXY(
        xMin: -180.0,
        yMin: -55.0,
        xMax: 180.0,
        yMax: 55.0,
        spatialReference: SpatialReference.wgs84,
      );
      _currentBasemapType = newType;
    });
  }

  /// Switches between 2D map view and 3D portal scene views.
  void _setSceneMode(String key) {
    final isSameMode = key == _sceneMode;
    if (isSameMode) return;
    setState(() {
      _sceneMode = key;
      final isNotDefault = key != 'default';
      if (isNotDefault) _showLayersPanel = false;
      final isConfigNull = _config == null;
      if (isConfigNull) return;

      final scene = _config!.scenes[key];
      final isInvalidScene = scene == null || scene.type != 'scene';
      if (isInvalidScene) return;

      final portalUrl = scene.portalKey != null ? _config!.portals[scene.portalKey!] : null;
      final isMissingPortalItem = portalUrl == null || scene.itemId == null;
      if (isMissingPortalItem) return;

      final isBuilding3DMode = key == 'building3d' && _scene3DWidget == null;
      final isDroneViewMode = key == 'droneView' && _sceneDroneWidget == null;

      if (isBuilding3DMode) {
        _scene3DWidget = EsriSceneWidget(
          key: _scene3DKey,
          portalUri: portalUrl,
          itemId: scene.itemId!,
          onHeadingChanged: (h) => setState(() {
            _mapRotation = h;
            final shouldResetVP3D = !_ignoreViewpointReset && (_isLocationActive || _isRecenterActive);
            if (shouldResetVP3D) {
              _isLocationActive = false;
              _isRecenterActive = false;
            }
          }),
        );
      } else if (isDroneViewMode) {
        _sceneDroneWidget = EsriSceneWidget(
          key: _sceneDroneKey,
          portalUri: portalUrl,
          itemId: scene.itemId!,
          onHeadingChanged: (h) => setState(() {
            _mapRotation = h;
            final shouldResetVPDrone = !_ignoreViewpointReset && (_isLocationActive || _isRecenterActive);
            if (shouldResetVPDrone) {
              _isLocationActive = false;
              _isRecenterActive = false;
            }
          }),
        );
      }
    });
  }

  /// Toggles visibility of operational layers configured in map settings.
  void _toggleLayer(String key) async {
    final entry = _config?.layers[key];
    final isEntryNull = entry == null;
    if (isEntryNull) return;

    final isAlreadyVisible = _layerVisible[key] == true;
    if (isAlreadyVisible) {
      _layerTimers[key]?.cancel();
      _layerTimers.remove(key);

      // Hide layers instead of destroying them to cache their loaded state
      for (final layer in _layerInstances[key] ?? []) {
        if (layer != null) layer.isVisible = false;
      }

      setState(() => _layerVisible[key] = false);
      return;
    }

    setState(() => _layerLoading[key] = true);

    // Retrieve cached layers, or build them if they don't exist yet
    List<Layer?> instances = _layerInstances[key] ?? [];

    if (instances.isEmpty) {
      instances = await _buildLayerInstances(key, entry);
      _layerInstances[key] = instances;

      for (final layer in instances) {
        if (layer != null) _map.operationalLayers.add(layer);
      }

      try {
        await Future.wait(instances.whereType<Layer>().map((l) => l.load()));
        _applyLayerSpecialCases(key, instances);
      } catch (e) {
        debugPrint('Layer $key load error: $e');
      }
    } else {
      // Re-enable visibility for cached layers
      for (final layer in instances) {
        if (layer != null) layer.isVisible = true;
      }
    }

    _startLayerRefreshTimer(key, entry);

    if (key == 'tritonTransit') _fetchTransitLegendInfos(instances);

    setState(() {
      _layerVisible[key] = true;
      _layerLoading[key] = false;
    });
  }

  void _toggleTransitRoute(String routeName, bool isVisible) {
    setState(() {
      _transitRouteVisibility[routeName] = isVisible;
    });

    final layers = _transitRouteLayers[routeName] ?? [];
    for (final layer in layers) {
      final allRoutesForLayer = _transitRouteLayers.entries
          .where((e) => e.value.contains(layer))
          .map((e) => e.key)
          .toList();

      if (allRoutesForLayer.length <= 1) {
        layer.isVisible = isVisible;
      } else {
        final visibleRoutes = allRoutesForLayer
            .where((r) => _transitRouteVisibility[r] ?? true)
            .toList();

        if (visibleRoutes.isEmpty) {
          layer.isVisible = false;
          try {
            layer.definitionExpression = '';
          } catch (_) {}
        } else if (visibleRoutes.length == allRoutesForLayer.length) {
          layer.isVisible = true;
          try {
            layer.definitionExpression = '';
          } catch (_) {}
        } else {
          layer.isVisible = true;
          try {
            final renderer = layer.renderer;
            if (renderer != null && renderer is UniqueValueRenderer) {
              final fieldNames = renderer.fieldNames;
              if (fieldNames.isNotEmpty) {
                final fieldName = fieldNames.first;
                final visibleValues = <String>[];

                for (final uv in renderer.uniqueValues) {
                  String name = uv.label.trim();
                  name = name.replaceAll('Institute of', 'Institution of');
                  if (visibleRoutes.contains(name) && uv.values.isNotEmpty) {
                    final val = uv.values.first;
                    if (val is String) {
                      visibleValues.add("'$val'");
                    } else {
                      visibleValues.add("$val");
                    }
                  }
                }

                if (visibleValues.isNotEmpty) {
                  layer.definitionExpression = "$fieldName IN (${visibleValues.join(',')})";
                }
              }
            }
          } catch (e) {
            debugPrint('Failed to set definitionExpression: $e');
          }
        }
      }
    }
  }

  Future<void> _fetchTransitLegendInfos(List<Layer?> instances) async {
    if (_transitLegend.isNotEmpty) return;
    if (mounted) setState(() => _isTransitLegendLoading = true);

    try {
      final uniqueInfosMap = <String, LegendInfo>{};
      final routeLayers = <String, List<dynamic>>{};

      Future<void> processContent(dynamic content) async {
        if (content is Loadable) {
          try {
            await (content as Loadable).load();
          } catch (_) {}
        }
        
        bool processedSublayers = false;

        if (content is GroupLayer && content.layers.isNotEmpty) {
          for (final sub in content.layers) {
            await processContent(sub);
          }
          processedSublayers = true;
        } else if (content is ArcGISMapImageLayer && content.mapImageSublayers.isNotEmpty) {
          for (final sub in content.mapImageSublayers) {
            await processContent(sub);
          }
          processedSublayers = true;
        } else if (content is ArcGISSublayer && content.sublayers.isNotEmpty) {
          for (final sub in content.sublayers) {
            await processContent(sub);
          }
          processedSublayers = true;
        } else if (content is LayerContent && content.subLayerContents.isNotEmpty) {
          for (final sub in content.subLayerContents) {
            await processContent(sub);
          }
          processedSublayers = true;
        }

        if (!processedSublayers && content is LayerContent) {
          try {
            final layerInfos = await content.fetchLegendInfos();
            for (final info in layerInfos) {
              String name = info.name.trim();
              if (name.isEmpty) continue;
              name = name.replaceAll('Institute of', 'Institution of');
              uniqueInfosMap[name] = info;
              routeLayers.putIfAbsent(name, () => []).add(content);
            }
          } catch (e) {
            debugPrint('Failed to fetch legend info for sub-content: $e');
          }
        }
      }

      for (final layer in instances.whereType<Layer>()) {
        await processContent(layer);
      }

      final uniqueInfos = uniqueInfosMap.values.toList();

      final swatches = <String, ui.Image>{};
      for (final info in uniqueInfos) {
        final swatchImage = await info.symbol?.createSwatch(screenScale: 2.0);
        if (swatchImage != null) swatches[info.name] = await swatchImage.toImage();
      }

      if (mounted) {
        setState(() {
          _transitLegend = uniqueInfos.where((info) => swatches.containsKey(info.name)).toList();
          _transitLegendSwatches = swatches;
          _transitRouteLayers = routeLayers;
          _transitRouteVisibility = {for (var info in _transitLegend) info.name: true};
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch transit legend: $e');
    } finally {
      if (mounted) setState(() => _isTransitLegendLoading = false);
    }
  }

  Future<List<Layer?>> _buildLayerInstances(String key, LayerEntry entry) async {
    // Intercept specific layers to forcefully inject vector sublayers, bypassing
    // the remote backend config which still requests slow MapImageLayers.
    if (key == 'campusDistricts')
      return [
        FeatureLayer.withFeatureTable(
          ServiceFeatureTable.withUri(
            Uri.parse(
              'https://admin-enterprise-gis.ucsd.edu/server/rest/services/AdministrationServices/Areas_and_Boundaries/MapServer/4',
            ),
          ),
        ),
      ];
    if (key == 'construction') {
      return [
        FeatureLayer.withFeatureTable(
          ServiceFeatureTable.withUri(
            Uri.parse(
              'https://admin-enterprise-gis.ucsd.edu/server/rest/services/Construction/Construction_Alert_Approved/MapServer/2',
            ),
          ),
        ),
        FeatureLayer.withFeatureTable(
          ServiceFeatureTable.withUri(
            Uri.parse(
              'https://admin-enterprise-gis.ucsd.edu/server/rest/services/Construction/Construction_Alert_Approved/MapServer/1',
            ),
          ),
        ),
        FeatureLayer.withFeatureTable(
          ServiceFeatureTable.withUri(
            Uri.parse(
              'https://admin-enterprise-gis.ucsd.edu/server/rest/services/Construction/Construction_Alert_Approved/MapServer/0',
            ),
          ),
        ),
      ];
    }

    var isPortalItem = entry.source == 'portalItem' && entry.portalKey != null && entry.itemId != null;
    if (isPortalItem) {
      final portalUrl = _config?.portals[entry.portalKey!];
      if (portalUrl != null) {
        final portalItem = PortalItem.withPortalAndItemId(portal: Portal(Uri.parse(portalUrl)), itemId: entry.itemId!);
        try {
          await portalItem.load();
          if (portalItem.type == PortalItemType.webMap) {
            final tempMap = ArcGISMap.withItem(portalItem);
            await tempMap.load();
            final layers = tempMap.operationalLayers.toList();
            tempMap.operationalLayers.clear(); // Un-own the layers so they can be added to the main map
            return layers;
          } else {
            return [FeatureLayer.withItem(item: portalItem, layerId: 0)];
          }
        } catch (e) {
          debugPrint('Portal item load error: $e');
        }
      }
    }

    var hasSub = entry.hasSublayers;
    if (hasSub) return entry.sublayers!.map(_layerFromSublayer).toList();
    return [_layerFromEntry(entry)];
  }

  Layer? _layerFromSublayer(SublayerEntry sub) {
    final isUrlSub = sub.source == 'url' && sub.url != null;
    if (isUrlSub) {
      final isVectorSource = sub.url!.contains('FeatureServer') || RegExp(r'MapServer\/\d+').hasMatch(sub.url!);
      return isVectorSource
          ? FeatureLayer.withFeatureTable(ServiceFeatureTable.withUri(Uri.parse(sub.url!)))
          : ArcGISMapImageLayer.withUri(Uri.parse(sub.url!));
    }
    return null;
  }

  Layer? _layerFromEntry(LayerEntry entry) {
    final isUrlEntry = entry.source == 'url' && entry.url != null;
    if (isUrlEntry) {
      final isVectorSource = entry.url!.contains('FeatureServer') || RegExp(r'MapServer\/\d+').hasMatch(entry.url!);
      return isVectorSource
          ? FeatureLayer.withFeatureTable(ServiceFeatureTable.withUri(Uri.parse(entry.url!)))
          : ArcGISMapImageLayer.withUri(Uri.parse(entry.url!));
    }
    return null;
  }

  void _applyLayerSpecialCases(String key, List<Layer?> instances) {
    final isCampusDistricts =
        key == 'campusDistricts' && instances.isNotEmpty && instances.first is ArcGISMapImageLayer;
    if (isCampusDistricts) {
      final imageLayer = instances.first as ArcGISMapImageLayer;
      for (final sub in imageLayer.mapImageSublayers) {
        final isSublayerFour = sub.id == 4;
        sub.isVisible = isSublayerFour;
      }
    }
  }

  void _startLayerRefreshTimer(String key, LayerEntry entry) {
    final subs = entry.sublayers;
    final isSubsNull = subs == null;
    if (isSubsNull) return;

    int? capturedIdx;
    int? interval;
    for (int i = 0; i < subs.length; i++) {
      final hasRefresh = subs[i].refreshInterval > 0;
      if (hasRefresh) {
        capturedIdx = i;
        interval = subs[i].refreshInterval;
        break;
      }
    }
    final isInvalidRefreshConfig = capturedIdx == null || interval == null;
    if (isInvalidRefreshConfig) return;

    final idx = capturedIdx;
    final sub = subs[idx];

    _layerTimers[key] = Timer.periodic(Duration(seconds: interval), (_) async {
      final isNotMounted = !mounted;
      if (isNotMounted) return;
      final instances = _layerInstances[key];
      final isInvalidInstances = instances == null || idx >= instances.length;
      if (isInvalidInstances) return;

      final oldLayer = instances[idx];
      final isOldLayerNotNull = oldLayer != null;
      if (isOldLayerNotNull) _map.operationalLayers.remove(oldLayer);

      final newLayer = _layerFromSublayer(sub);
      instances[idx] = newLayer;
      final isNewLayerNotNull = newLayer != null;
      if (isNewLayerNotNull) {
        _map.operationalLayers.add(newLayer);
        try {
          await newLayer.load();
        } catch (e) {
          debugPrint('Refresh error $key[$idx]: $e');
        }
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Search & Recent History Operations
  // ---------------------------------------------------------------------------

  Future<void> _loadRecentSearches() async {
    await EsriMapSearchService.loadCachedBuildings();
    final searches = await EsriMapSearchService.loadRecentSearches();
    if (mounted) setState(() => _recentSearches = searches);
  }

  void _addToRecentSearches(MapSearchResult result) {
    _recentSearches.removeWhere((r) => r.name == result.name && r.source == result.source);
    _recentSearches.insert(0, result);
    final isExceedingMax = _recentSearches.length > EsriMapSearchService.MAX_RECENT_SEARCHES;
    if (isExceedingMax) _recentSearches = _recentSearches.sublist(0, EsriMapSearchService.MAX_RECENT_SEARCHES);
    EsriMapSearchService.saveRecentSearches(_recentSearches);
  }

  void _removeFromRecentSearches(int index) {
    setState(() => _recentSearches.removeAt(index));
    EsriMapSearchService.saveRecentSearches(_recentSearches);
  }

  void _clearRecentSearches() {
    setState(_recentSearches.clear);
    EsriMapSearchService.saveRecentSearches(_recentSearches);
  }

  Future<void> _fetchAllPoiClasses() async {
    final classes = await EsriMapSearchService.fetchAllPoiClasses();
    if (mounted) setState(() => _allPoiClasses = classes);
  }

  void _queueSearch(String query) {
    _searchDebounce?.cancel();
    final requestId = ++_searchRequestId;
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      _searchDebounce = null;
      _performSearch(trimmedQuery, requestId);
    });
  }

  void _cancelPendingSearch() {
    _searchDebounce?.cancel();
    _searchDebounce = null;
    _searchRequestId++;
  }

  Future<void> _waitForMinimumSearchLoadingTime(Stopwatch stopwatch) async {
    final remaining = _MINIMUM_SEARCH_LOADING_DURATION - stopwatch.elapsed;
    if (remaining > Duration.zero) await Future.delayed(remaining);
  }

  /// Text search: queries buildings and POIs concurrently.
  Future<void> _performSearch(String query, int requestId) async {
    final loadingStopwatch = Stopwatch()..start();
    final q = query.toLowerCase();
    final matched = _allPoiClasses.where((c) => c.toLowerCase().contains(q)).toList();

    for (final cat in _categories) {
      final matchesCat = cat.poiClassValue.toLowerCase().contains(q) && !matched.contains(cat.poiClassValue);
      if (matchesCat) matched.insert(0, cat.poiClassValue);
    }

    setState(() {
      _isSearching = true;
      _showResults = _showRouteFields;
      _showSuggestions = false;
      _selectedResult = null;
      _matchingPoiClasses = matched;
    });

    var merged = <MapSearchResult>[];
    try {
      final results = await Future.wait([
        EsriMapSearchService.queryBuildings(query),
        EsriMapSearchService.queryPOIs(query),
      ]);
      merged = [...results[0], ...results[1]];
    } catch (e) {
      debugPrint('Search error: $e');
    }
    await _waitForMinimumSearchLoadingTime(loadingStopwatch);
    final isStale = !mounted || requestId != _searchRequestId;
    if (isStale) return;

    if (_showRouteFields) {
      setState(() {
        _searchResults = merged;
        _isSearching = false;
      });
    } else {
      final userLoc = _getUserLatLng();
      if (userLoc != null) {
        merged.sort((a, b) {
          final distA = EsriMapSearchService.distanceMeters(userLoc.$1, userLoc.$2, a.latitude, a.longitude);
          final distB = EsriMapSearchService.distanceMeters(userLoc.$1, userLoc.$2, b.latitude, b.longitude);
          return distA.compareTo(distB);
        });
      } else {
        merged.sort((a, b) => a.name.compareTo(b.name));
      }

      _plotResultsOnMap(merged);

      setState(() {
        _searchResults = [];
        _allCategoryResults = merged;
        _showCategoryList = merged.isNotEmpty;
        _showResults = false;
        _activeCategory = null;
        _isSearching = false;
      });

      final isSearchEmpty = merged.isEmpty && query.isNotEmpty;
      if (isSearchEmpty)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No locations found.')));
    }
  }

  /// Category search: queries matching locations and plots pins on the map.
  Future<void> _performCategorySearch(EsriSearchCategory category) async {
    _cancelPendingSearch();
    final loadingStopwatch = Stopwatch()..start();
    final requestId = _searchRequestId;
    setState(() {
      _isSearching = true;
      _showResults = false;
      _showSuggestions = false;
      _matchingPoiClasses = [];
      _selectedResult = null;
      _showCategoryList = false;
      _activeCategory = category;
      _searchController.text = category.label;
    });
    _focusNode.unfocus();
    _fromFocusNode.unfocus();
    _toFocusNode.unfocus();

    try {
      var isRec = category.poiClassValue == 'Recreation Facilities';
      var allResults = <MapSearchResult>[];

      if (isRec) {
        final baseSearch = EsriMapSearchService.queryPOIsByClass(category.poiClassValue);
        final extraSearches = <Future<List<MapSearchResult>>>[
          EsriMapSearchService.queryBuildings('gym'),
          EsriMapSearchService.queryBuildings('rimac'),
          EsriMapSearchService.queryBuildings('track'),
          EsriMapSearchService.queryBuildings('canyonview'),
          EsriMapSearchService.queryBuildings('pool'),
          EsriMapSearchService.queryBuildings('natatorium'),
          EsriMapSearchService.queryPOIs('park'),
          EsriMapSearchService.queryPOIs('beach'),
          EsriMapSearchService.queryPOIs('amphitheater'),
          EsriMapSearchService.queryPOIs('amphitheatre'),
          EsriMapSearchService.queryBuildings('amphitheater'),
          EsriMapSearchService.queryBuildings('arena'),
          EsriMapSearchService.queryPOIs('field'),
          EsriMapSearchService.queryPOIs('court'),
          EsriMapSearchService.queryBuildings('fitness'),
          EsriMapSearchService.queryBuildings('athletic'),
          EsriMapSearchService.queryBuildings('aquatic'),
          EsriMapSearchService.queryBuildings('rec'),
          EsriMapSearchService.queryBuildings('theater'),
          EsriMapSearchService.queryPOIs('theater'),
          EsriMapSearchService.queryBuildings('theatre'),
          EsriMapSearchService.queryPOIs('theatre'),
          EsriMapSearchService.queryBuildings('wellness'),
        ];

        final baseResults = await baseSearch;
        final extraResultsLists = await Future.wait(extraSearches);

        final validTerms = [
          'gym',
          'rimac',
          'track',
          'canyonview',
          'pool',
          'natatorium',
          'park',
          'beach',
          'amphitheater',
          'amphitheatre',
          'arena',
          'field',
          'court',
          'fitness',
          'athletic',
          'aquatic',
          'rec',
          'theater',
          'theatre',
          'wellness',
        ];

        final validExtraResults = extraResultsLists.expand((r) => r).where((r) {
          final textLower = '${r.name} ${r.subtitle} ${r.description}'.toLowerCase();
          for (final term in validTerms) {
            // Match word boundary to avoid substring matches (e.g. field in Gusfield)
            if (RegExp(r'\b' + term).hasMatch(textLower)) return true;
          }
          return false;
        });

        allResults = [...baseResults, ...validExtraResults];
      } else {
        allResults = await EsriMapSearchService.queryPOIsByClass(category.poiClassValue);
      }

      // Deduplicate results by name to avoid showing the same place twice
      final uniqueNames = <String>{};
      allResults = allResults.where((r) {
        if (!uniqueNames.add(r.name)) return false;

        // Filter out false positives for Recreation
        if (isRec) {
          final textLower = '${r.name} ${r.subtitle} ${r.description}'.toLowerCase();
          final excluded = [
            'emergency',
            'restroom',
            'parking',
            'call box',
            'office',
            'elevator',
            'atm ',
            ' atm',
            'conference',
            'room ',
            ' room',
            'reception',
            'director',
            'academic',
            'admin',
            'lecture',
            'institute',
          ];
          for (final term in excluded) {
            if (textLower.contains(term)) return false;
          }
        }
        return true;
      }).toList();

      await _waitForMinimumSearchLoadingTime(loadingStopwatch);
      final isStale = !mounted || requestId != _searchRequestId;
      if (isStale) return;

      final userLoc = _getUserLatLng();
      if (userLoc != null) {
        allResults.sort((a, b) {
          final distA = EsriMapSearchService.distanceMeters(userLoc.$1, userLoc.$2, a.latitude, a.longitude);
          final distB = EsriMapSearchService.distanceMeters(userLoc.$1, userLoc.$2, b.latitude, b.longitude);
          return distA.compareTo(distB);
        });
        _plotResultsOnMap(allResults);
        if (allResults.isNotEmpty) {
          final closest = allResults.first;
          final p = ArcGISPoint(x: closest.longitude, y: closest.latitude, spatialReference: SpatialReference.wgs84);
          _showCalloutForGraphic(closest, _graphicsOverlay.graphics.first);
          _mapViewController.setViewpointAnimated(Viewpoint.fromCenter(p, scale: 18000));
        }
      } else {
        allResults.sort((a, b) => a.name.compareTo(b.name));
        _plotResultsOnMap(allResults);
        _zoomToResults(allResults);
      }

      setState(() {
        _allCategoryResults = allResults;
        _showCategoryList = allResults.isNotEmpty;
        _isSearching = false;
      });
      if (allResults.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('No ${category.label.toLowerCase()} locations found.')));
      }
    } catch (e) {
      debugPrint('Category search error: $e');
      await _waitForMinimumSearchLoadingTime(loadingStopwatch);
      final isStale = !mounted || requestId != _searchRequestId;
      if (isStale) return;
      setState(() {
        _mappedResults = [];
        _allCategoryResults = [];
        _isSearching = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Couldn't load ${category.label.toLowerCase()} locations.")));
    }
  }

  Future<void> _performClassSearch(String classValue) async {
    final category = EsriSearchCategory(
      label: _labelForClass(classValue),
      icon: _iconForClass(classValue),
      poiClassValue: classValue,
    );
    await _performCategorySearch(category);
  }

  // ---------------------------------------------------------------------------
  // Map Graphics & Pin Plotting
  // ---------------------------------------------------------------------------

  void _plotResultsOnMap(List<MapSearchResult> results) {
    _dismissCallout();
    _graphicsOverlay.graphics.clear();
    _mappedResults = results;
    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      final isBuilding = result.source == MapSearchSource.building;

      if (result.footprint is Polygon) {
        final footprintGraphic = Graphic(
          geometry: result.footprint as Polygon,
          symbol: SimpleFillSymbol(
            style: SimpleFillSymbolStyle.solid,
            color: Colors.blue.withOpacity(0.3),
            outline: SimpleLineSymbol(style: SimpleLineSymbolStyle.solid, color: Colors.blue, width: 2),
          ),
        );
        footprintGraphic.attributes['resultIndex'] = i;
        _graphicsOverlay.graphics.add(footprintGraphic);
      }

      final point = ArcGISPoint(x: result.longitude, y: result.latitude, spatialReference: SpatialReference.wgs84);
      final graphic = Graphic(
        geometry: point,
        symbol: SimpleMarkerSymbol(
          style: SimpleMarkerSymbolStyle.circle,
          color: isBuilding ? Colors.blue : Colors.red,
          size: 14,
        ),
      );
      graphic.attributes['resultIndex'] = i;
      _graphicsOverlay.graphics.add(graphic);
    }
  }

  void _zoomToResults(List<MapSearchResult> results) {
    final isResultsEmpty = results.isEmpty;
    if (isResultsEmpty) return;

    final isSingleResult = results.length == 1;
    if (isSingleResult) {
      final r = results.first;
      _mapViewController.setViewpointAnimated(
        Viewpoint.fromCenter(
          ArcGISPoint(x: r.longitude, y: r.latitude, spatialReference: SpatialReference.wgs84),
          scale: 18000,
        ),
      );
      return;
    }

    // Find the median coordinate to locate the densest cluster, ignoring outliers
    final lats = results.map((r) => r.latitude).toList()..sort();
    final lngs = results.map((r) => r.longitude).toList()..sort();

    final medianLat = lats[lats.length ~/ 2];
    final medianLng = lngs[lngs.length ~/ 2];

    _mapViewController.setViewpointAnimated(
      Viewpoint.fromCenter(
        ArcGISPoint(x: medianLng, y: medianLat, spatialReference: SpatialReference.wgs84),
        scale: 24000,
      ),
    );
  }

  /// Dismisses the active map pin callout, if any.
  void _dismissCallout() {
    _mapViewController.callout.dismiss();
    _graphicsOverlay.clearSelection();
  }

  void _seeAllCategoryResults() {
    final isAllCategoryResultsEmpty = _allCategoryResults.isEmpty;
    if (isAllCategoryResultsEmpty) return;
    _zoomToResults(_allCategoryResults);
  }

  void _selectResult(MapSearchResult result) {
    _cancelPendingSearch();
    _dismissCallout();
    final isRouteModeActive = _showRouteFields && _activeRouteField != null;
    if (isRouteModeActive) {
      final isFromActive = _activeRouteField == 'from';
      final isToActive = _activeRouteField == 'to';
      if (isFromActive) {
        _fromController.text = result.name;
        _fromLatLng = (result.latitude, result.longitude);
        _graphicsOverlay.graphics.clear();
        setState(() {
          _showResults = false;
          _showSuggestions = false;
          _mappedResults = [];
          _allCategoryResults = [];
          _showCategoryList = false;
          _activeCategory = null;
        });
        _fromFocusNode.unfocus();
        final hasRouteDestination = _routeDestination != null;
        if (hasRouteDestination) _solveRoute(_routeDestination!, originLatLng: _fromLatLng);
      } else if (isToActive) {
        _toController.text = result.name;
        _routeDestination = result;
        _graphicsOverlay.graphics.clear();
        setState(() {
          _selectedResult = result;
          _lastSelectedResult = result;
          _showResults = false;
          _showSuggestions = false;
          _mappedResults = [];
          _allCategoryResults = [];
          _showCategoryList = false;
          _activeCategory = null;
        });
        _toFocusNode.unfocus();
        _solveRoute(result, originLatLng: _fromLatLng);
      }
      _addToRecentSearches(result);
      return;
    }

    _graphicsOverlay.graphics.clear();
    final point = ArcGISPoint(x: result.longitude, y: result.latitude, spatialReference: SpatialReference.wgs84);
    final isBuilding = result.source == MapSearchSource.building;
    final graphic = Graphic(
      geometry: point,
      symbol: SimpleMarkerSymbol(
        style: SimpleMarkerSymbolStyle.circle,
        color: isBuilding ? Colors.blue : Colors.red,
        size: 14,
      ),
    );
    _graphicsOverlay.graphics.add(graphic);
    _showCalloutForGraphic(result, graphic);
    _mapViewController.setViewpointAnimated(Viewpoint.fromCenter(point, scale: 5000));

    setState(() {
      _showResults = false;
      _showSuggestions = false;
      _searchController.text = result.name;
      _selectedResult = result;
      _lastSelectedResult = result;
    });
    _focusNode.unfocus();
    _addToRecentSearches(result);
  }

  Future<void> _onMapTap(Offset screenPoint) async {
    final hasClassMatches = _matchingPoiClasses.isNotEmpty && _searchController.text.isNotEmpty;
    final isDropdownVisible = _showSuggestions || _showResults || hasClassMatches;
    if (isDropdownVisible) {
      setState(() {
        _showSuggestions = false;
        _showResults = false;
        _matchingPoiClasses = [];
      });
      _focusNode.unfocus();
      return;
    }

    final mapPoint = _mapViewController.screenToLocation(screen: screenPoint);

    // Delay the loading indicator so fast responses (like empty taps) don't flash it
    bool isRequestFinished = false;
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!isRequestFinished && mounted) {
        setState(() {
          _loadingLocation = mapPoint;
        });
      }
    });

    try {
      final identifyResult = await _mapViewController.identifyGraphicsOverlay(
        _graphicsOverlay,
        screenPoint: screenPoint,
        tolerance: 12.0,
        maximumResults: 1,
      );

      final hasGraphics = identifyResult.graphics.isNotEmpty;
      if (hasGraphics) {
        isRequestFinished = true;
        if (mounted)
          setState(() {
            _loadingLocation = null;
          });
        final tappedGraphic = identifyResult.graphics.first;
        final index = tappedGraphic.attributes['resultIndex'] as int?;
        final isValidResultIndex = index != null && index >= 0 && index < _mappedResults.length;
        if (isValidResultIndex) _handlePinTap(_mappedResults[index], tappedGraphic);
        return;
      }
    } catch (e) {
      debugPrint('Identify error: $e');
    }

    if (mapPoint != null) {
      final wgs84Point =
          GeometryEngine.project(mapPoint, outputSpatialReference: SpatialReference.wgs84) as ArcGISPoint?;
      final isValidPoint = wgs84Point != null && !wgs84Point.x.isNaN && !wgs84Point.y.isNaN;
      if (isValidPoint) {
        final buildingResult = await EsriMapSearchService.identifyBuildingAtCoordinate(wgs84Point.y, wgs84Point.x);
        isRequestFinished = true;
        if (mounted)
          setState(() {
            _loadingLocation = null;
          });
        if (buildingResult != null) {
          if (_allCategoryResults.isNotEmpty) _clearSearch();
          _plotResultsOnMap([buildingResult]);
          final hasGraphics = _graphicsOverlay.graphics.isNotEmpty;
          if (hasGraphics) _handlePinTap(buildingResult, _graphicsOverlay.graphics.last);
          return;
        } else {
          _dismissCallout();
        }
      }
    }

    isRequestFinished = true;
    if (mounted)
      setState(() {
        _loadingLocation = null;
      });
    _dismissCallout();
    final isSelectedResultNotNull = _selectedResult != null;
    if (isSelectedResultNotNull) _closeDetail();
  }

  /// Shows a place name above a plotted map pin without changing the search.

  void _showCalloutForGraphic(MapSearchResult result, Graphic graphic) {
    final isBuilding = result.source == MapSearchSource.building;
    final detail = (isBuilding && result.address.isNotEmpty) ? result.address : result.subtitle;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final diningProvider = Provider.of<DiningDataProvider>(context, listen: false);
    final parkingProvider = Provider.of<ParkingDataProvider>(context, listen: false);
    final availabilityProvider = Provider.of<AvailabilityDataProvider>(context, listen: false);

    _graphicsOverlay.clearSelection();
    graphic.isSelected = true;
    _mapViewController.callout.showCalloutForGeoElement(
      graphic,
      leaderPosition: LeaderPosition.bottom,
      style: CalloutStyle(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        borderColor: isDark ? Colors.white24 : Colors.black26,
        borderRadius: 12,
        borderWidth: 0.5,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        minWidth: 96,
        // Removed maxWidth to allow the callout to size dynamically based on contextual data without clipping
        offset: const Offset(0, -10),
      ),
      contentBuilder: (_, __) => EsriMapCalloutContent(
        result: result,
        detail: detail,
        isDark: isDark,
        diningModels: diningProvider.diningModels,
        parkingModels: parkingProvider.parkingModels,
        availabilityModels: availabilityProvider.availabilityModels,
      ),
    );
  }

  void _handlePinTap(MapSearchResult result, Graphic graphic) {
    if (_showRouteFields) {
      _selectResultFromPin(result);
      return;
    }

    // Always show the callout when a pin is tapped, even if multiple results exist
    _showCalloutForGraphic(result, graphic);

    _selectResultFromPin(result, updateSearchText: false);
  }

  void _selectResultFromList(MapSearchResult result) {
    final index = _mappedResults.indexOf(result);
    var isOutOfBounds = index < 0 || index >= _graphicsOverlay.graphics.length;
    if (isOutOfBounds) {
      _selectResultFromPin(result);
      return;
    }
    _handlePinTap(result, _graphicsOverlay.graphics[index]);
  }

  void _selectResultFromPin(MapSearchResult result, {bool updateSearchText = true}) {
    if (_showRouteFields) {
      final isFromActive = _activeRouteField == 'from';
      if (isFromActive) {
        _fromController.text = result.name;
        _fromLatLng = (result.latitude, result.longitude);
        _graphicsOverlay.graphics.clear();
        setState(() {
          _showResults = false;
          _showSuggestions = false;
          _mappedResults = [];
          _allCategoryResults = [];
          _showCategoryList = false;
          _activeCategory = null;
        });
        _fromFocusNode.unfocus();
        final hasRouteDestination = _routeDestination != null;
        if (hasRouteDestination) _solveRoute(_routeDestination!, originLatLng: _fromLatLng);
      } else {
        _toController.text = result.name;
        _routeDestination = result;
        _graphicsOverlay.graphics.clear();
        setState(() {
          _selectedResult = result;
          _lastSelectedResult = result;
          _showResults = false;
          _showSuggestions = false;
          _mappedResults = [];
          _allCategoryResults = [];
          _showCategoryList = false;
          _activeCategory = null;
        });
        _toFocusNode.unfocus();
        _solveRoute(result, originLatLng: _fromLatLng);
      }
      _addToRecentSearches(result);
      return;
    }

    final point = ArcGISPoint(x: result.longitude, y: result.latitude, spatialReference: SpatialReference.wgs84);
    _mapViewController.setViewpointAnimated(Viewpoint.fromCenter(point, scale: 5000));

    setState(() {
      _selectedResult = result;
      _lastSelectedResult = result;
      if (updateSearchText) _searchController.text = result.name;
      _showResults = false;
      _showSuggestions = false;
      _showCategoryList = false;
    });
    _focusNode.unfocus();
    _addToRecentSearches(result);
  }

  void _closeDetail() {
    _dismissCallout();
    final canShowCategoryResults = _allCategoryResults.isNotEmpty && !_showRouteFields && !_hasRoute && !_routeFailed;
    if (canShowCategoryResults) {
      setState(() {
        _selectedResult = null;
        _showCategoryList = true;
      });
    } else {
      _clearSearch();
    }
  }

  Future<void> _recenterOnUser() async {
    if (_isLocatingUser) return;
    setState(() => _isLocatingUser = true);

    try {
      final gps = await _getDeviceLocationEfficiently();
      if (gps == null) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Unable to get your current location.')));
        }
        return;
      }
      debugPrint('\x1B[32m[Center on Me] Coordinates obtained: Lat: ${gps.$1}, Lng: ${gps.$2}\x1B[0m');
      if (!mounted) return;

      _ignoreViewpointReset = true;
      setState(() => _isLocationActive = true);

      // Do not await the animation, as it can occasionally hang and stall the UI spinner
      _mapViewController
          .setViewpointAnimated(
            Viewpoint.fromCenter(
              ArcGISPoint(x: gps.$2, y: gps.$1, spatialReference: SpatialReference.wgs84),
              scale: 10000,
            ),
          )
          .then((_) {
            if (mounted) {
              setState(() {
                _ignoreViewpointReset = false;
              });
            }
          });
    } catch (e) {
      debugPrint('Location error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to get your current location.')));
    } finally {
      if (mounted) setState(() => _isLocatingUser = false);
    }
  }

  void _recenterOnView() {
    _ignoreViewpointReset = true;
    setState(() {
      _isRecenterActive = true;
      _isLocationActive = false;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _ignoreViewpointReset = false;
          _isRecenterActive = false;
        });
      }
    });

    final isNotDefaultScene = _sceneMode != 'default';
    if (isNotDefaultScene) {
      final isBuilding3D = _sceneMode == 'building3d';
      if (isBuilding3D) {
        _scene3DKey.currentState?.snapToNorth();
      } else {
        _sceneDroneKey.currentState?.snapToNorth();
      }
      return;
    }

    final isSelectedResultNotNull = _selectedResult != null;
    final hasLastResultNoMapped = _lastSelectedResult != null && _mappedResults.isEmpty;
    final hasMappedResults = _mappedResults.isNotEmpty;

    if (isSelectedResultNotNull) {
      _mapViewController.setViewpointAnimated(
        Viewpoint.fromCenter(
          ArcGISPoint(
            x: _selectedResult!.longitude,
            y: _selectedResult!.latitude,
            spatialReference: SpatialReference.wgs84,
          ),
          scale: 5000,
        ),
      );
    } else if (hasLastResultNoMapped) {
      _mapViewController.setViewpointAnimated(
        Viewpoint.fromCenter(
          ArcGISPoint(
            x: _lastSelectedResult!.longitude,
            y: _lastSelectedResult!.latitude,
            spatialReference: SpatialReference.wgs84,
          ),
          scale: 5000,
        ),
      );
    } else if (hasMappedResults) {
      _zoomToResults(_mappedResults);
    } else {
      _mapViewController.setViewpointAnimated(
        Viewpoint.fromCenter(
          ArcGISPoint(x: -117.2340, y: 32.8801, spatialReference: SpatialReference.wgs84),
          scale: 24000,
        ),
      );
    }
  }

  void _snapToNorth() {
    final isNotDefaultScene = _sceneMode != 'default';
    if (isNotDefaultScene) {
      final isBuilding3D = _sceneMode == 'building3d';
      if (isBuilding3D) {
        _scene3DKey.currentState?.snapToNorth();
      } else {
        _sceneDroneKey.currentState?.snapToNorth();
      }
      return;
    }
    _mapViewController.setViewpointRotation(angleDegrees: 0);
  }

  void _zoomIn() {
    if (_sceneMode != 'default') return; // Not implemented for 3D yet
    final vp = _mapViewController.getCurrentViewpoint(ViewpointType.centerAndScale);
    final isValidPoint = vp != null && vp.targetGeometry is ArcGISPoint;
    if (isValidPoint) {
      _mapViewController.setViewpointAnimated(
        Viewpoint.fromCenter(vp!.targetGeometry as ArcGISPoint, scale: _currentScale / 2.0),
      );
    }
  }

  void _zoomOut() {
    if (_sceneMode != 'default') return; // Not implemented for 3D yet
    final vp = _mapViewController.getCurrentViewpoint(ViewpointType.centerAndScale);
    final isValidPoint = vp != null && vp.targetGeometry is ArcGISPoint;
    if (isValidPoint) {
      _mapViewController.setViewpointAnimated(
        Viewpoint.fromCenter(vp!.targetGeometry as ArcGISPoint, scale: _currentScale * 2.0),
      );
    }
  }

  void _clearSearch() {
    _cancelPendingSearch();
    _dismissCallout();
    _searchController.clear();
    _fromController.clear();
    _toController.clear();
    _graphicsOverlay.graphics.clear();
    _routeGraphicsOverlay.graphics.clear();
    setState(() {
      _hasRoute = false;
      _routeFailed = false;
      _travelMode = 'Walking';
      _routeTravelTimeMinutes = 0;
      _routeManeuvers = [];
      _showRouteFields = false;
      _searchResults = [];
      _matchingPoiClasses = [];
      _mappedResults = [];
      _allCategoryResults = [];
      _showResults = false;
      _isSearching = false;
      _showSuggestions = false;
      _showCategoryList = false;
      _activeCategory = null;
      _selectedResult = null;
      _lastSelectedResult = null;
      _activeRouteField = null;
      _fromLatLng = null;
      _routeDestination = null;
    });
  }

  void _clearRoute() {
    _cancelPendingSearch();
    _dismissCallout();
    _routeGraphicsOverlay.graphics.clear();
    final destination = _selectedResult;
    final isDestinationNotNull = destination != null;
    if (isDestinationNotNull) {
      final point = ArcGISPoint(
        x: destination.longitude,
        y: destination.latitude,
        spatialReference: SpatialReference.wgs84,
      );
      final isBuilding = destination.source == MapSearchSource.building;
      _graphicsOverlay.graphics.clear();
      _graphicsOverlay.graphics.add(
        Graphic(
          geometry: point,
          symbol: SimpleMarkerSymbol(
            style: SimpleMarkerSymbolStyle.circle,
            color: isBuilding ? Colors.blue : Colors.red,
            size: 14,
          ),
        ),
      );
      _mapViewController.setViewpointAnimated(Viewpoint.fromCenter(point, scale: 5000));
    }

    setState(() {
      _isSearching = false;
      _hasRoute = false;
      _routeFailed = false;
      _travelMode = 'Walking';
      _routeTravelTimeMinutes = 0;
      _routeManeuvers = [];
      _showRouteFields = false;
      _activeRouteField = null;
      _fromLatLng = null;
      _routeDestination = null;
    });
  }

  // ---------------------------------------------------------------------------
  // Route Navigation Solver
  // ---------------------------------------------------------------------------

  Future<void> _solveRoute(MapSearchResult destination, {String? travelMode, (double, double)? originLatLng}) async {
    if (!FeatureFlags.MAP_ROUTING_ENABLED) return;

    final mode = travelMode ?? _travelMode;
    setState(() {
      _isRouting = true;
      _routeFailed = false;
      _travelMode = mode;
    });

    var userLatLng = originLatLng;
    if (userLatLng == null) userLatLng = await _getDeviceLocationEfficiently();

    final isUserLatLngNull = userLatLng == null;
    if (isUserLatLngNull) {
      setState(() => _isRouting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable location or manually enter starting location'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    final routeRes = await EsriMapRouteService.solveRoute(
      originLatLng: userLatLng,
      destination: destination,
      travelMode: mode,
    );

    final isRouteResNull = routeRes == null;
    if (!isRouteResNull) {
      _routeTravelTimeMinutes = routeRes.travelTimeMinutes;
      _routeManeuvers = routeRes.directionManeuvers;
    }

    _routeGraphicsOverlay.graphics.clear();

    if (isRouteResNull) {
      final builder = PolylineBuilder(spatialReference: SpatialReference.wgs84);
      builder.addPoint(ArcGISPoint(x: userLatLng.$2, y: userLatLng.$1, spatialReference: SpatialReference.wgs84));
      builder.addPoint(
        ArcGISPoint(x: destination.longitude, y: destination.latitude, spatialReference: SpatialReference.wgs84),
      );

      _routeGraphicsOverlay.graphics.add(
        Graphic(
          geometry: builder.toGeometry(),
          symbol: SimpleLineSymbol(style: SimpleLineSymbolStyle.dash, color: Colors.blue, width: 3),
        ),
      );
    } else {
      final hasRouteGeometry = routeRes.routeGeometry != null;
      if (hasRouteGeometry) {
        _routeGraphicsOverlay.graphics.add(
          Graphic(
            geometry: routeRes.routeGeometry!,
            symbol: SimpleLineSymbol(style: SimpleLineSymbolStyle.solid, color: Colors.blue, width: 4),
          ),
        );
      }
    }

    final whiteOutline = SimpleLineSymbol(style: SimpleLineSymbolStyle.solid, color: Colors.white, width: 2);
    final destPoint = ArcGISPoint(
      x: destination.longitude,
      y: destination.latitude,
      spatialReference: SpatialReference.wgs84,
    );
    _routeGraphicsOverlay.graphics.add(
      Graphic(
        geometry: destPoint,
        symbol: SimpleMarkerSymbol(style: SimpleMarkerSymbolStyle.circle, color: Colors.red, size: 12)
          ..outline = whiteOutline,
      ),
    );
    _routeGraphicsOverlay.graphics.add(
      Graphic(
        geometry: destPoint,
        symbol: TextSymbol(text: 'Destination', color: Colors.black, size: 14)
          ..haloColor = Colors.white
          ..haloWidth = 2
          ..offsetY = -15,
      ),
    );

    final originPoint = ArcGISPoint(x: userLatLng.$2, y: userLatLng.$1, spatialReference: SpatialReference.wgs84);
    _routeGraphicsOverlay.graphics.add(
      Graphic(
        geometry: originPoint,
        symbol: SimpleMarkerSymbol(style: SimpleMarkerSymbolStyle.circle, color: Colors.green, size: 12)
          ..outline = whiteOutline,
      ),
    );
    _routeGraphicsOverlay.graphics.add(
      Graphic(
        geometry: originPoint,
        symbol: TextSymbol(text: 'Start', color: Colors.black, size: 14)
          ..haloColor = Colors.white
          ..haloWidth = 2
          ..offsetY = -15,
      ),
    );

    if (isRouteResNull) {
      final builder = PolylineBuilder(spatialReference: SpatialReference.wgs84);
      builder.addPoint(originPoint);
      builder.addPoint(destPoint);
      final extent = builder.toGeometry().extent;
      final padded = Envelope.fromXY(
        xMin: extent.xMin - 0.005,
        yMin: extent.yMin - 0.005,
        xMax: extent.xMax + 0.005,
        yMax: extent.yMax + 0.005,
        spatialReference: SpatialReference.wgs84,
      );
      _mapViewController.setViewpointAnimated(Viewpoint.fromTargetExtent(padded));
    } else {
      final hasPaddedExtent = routeRes.paddedExtent != null;
      if (hasPaddedExtent) _mapViewController.setViewpointAnimated(Viewpoint.fromTargetExtent(routeRes.paddedExtent!));
    }

    _graphicsOverlay.graphics.clear();
    _mappedResults = [];
    _allCategoryResults = [];

    if (mounted) {
      setState(() {
        _isRouting = false;
        _routeFailed = isRouteResNull;
        _hasRoute = !isRouteResNull;
        _showRouteFields = true;
        _showCategoryList = false;
        _activeCategory = null;
        _selectedResult = destination;
        _lastSelectedResult = destination;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Helper getters & AI callbacks
  // ---------------------------------------------------------------------------

  (double lat, double lng)? _getUserLatLng() {
    final pos = _mapViewController.locationDisplay.location?.position;
    final isPosNull = pos == null;
    if (isPosNull) return null;
    final wgs = GeometryEngine.project(pos, outputSpatialReference: SpatialReference.wgs84) as ArcGISPoint?;
    final isWgsNull = wgs == null;
    if (isWgsNull) return null;
    final isWgsNaN = wgs.x.isNaN || wgs.y.isNaN;
    if (isWgsNaN) return null;
    return (wgs.y, wgs.x);
  }

  Envelope? _getViewportEnvelopeWGS84() {
    final vp = _mapViewController.getCurrentViewpoint(ViewpointType.boundingGeometry);
    final geom = vp?.targetGeometry;
    final isGeomNull = geom == null;
    if (isGeomNull) return null;
    final projected = GeometryEngine.project(geom, outputSpatialReference: SpatialReference.wgs84);
    return projected as Envelope?;
  }

  Future<void> _saveLocationToHive(double lat, double lng) async {
    try {
      final box = await Hive.openBox('mapLocationCache');
      await box.put('lat', lat);
      await box.put('lng', lng);
    } catch (_) {}
  }

  Future<(double, double)?> _loadLocationFromHive() async {
    try {
      final box = await Hive.openBox('mapLocationCache');
      final lat = box.get('lat') as double?;
      final lng = box.get('lng') as double?;
      if (lat != null && lng != null) return (lat, lng);
    } catch (_) {}
    return null;
  }

  IconData _iconForResult(MapSearchResult result) {
    final isBuilding = result.source == MapSearchSource.building;
    return isBuilding ? Icons.business : Icons.place;
  }

  IconData _iconForClass(String classValue) {
    return _categories
        .firstWhere(
          (c) => c.poiClassValue.toLowerCase() == classValue.toLowerCase(),
          orElse: () => const EsriSearchCategory(label: '', icon: Icons.place, poiClassValue: ''),
        )
        .icon;
  }

  String _labelForClass(String classValue) {
    final match = _categories.where((c) => c.poiClassValue.toLowerCase() == classValue.toLowerCase());
    final hasMatch = match.isNotEmpty;
    return hasMatch ? match.first.label : classValue;
  }

  Future<void> _launchWebsite(String url) async {
    final uri = Uri.parse(url);
    final canLaunch = await canLaunchUrl(uri);
    if (canLaunch) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _onAiLocationSelected(AiSearchResult result) {
    _searchController.text = result.name;
    final point = ArcGISPoint(x: result.longitude, y: result.latitude, spatialReference: SpatialReference.wgs84);
    _graphicsOverlay.graphics.clear();
    _graphicsOverlay.graphics.add(
      Graphic(
        geometry: point,
        symbol: SimpleMarkerSymbol(style: SimpleMarkerSymbolStyle.circle, color: Colors.red, size: 14),
      ),
    );
    _mapViewController.setViewpointAnimated(Viewpoint.fromCenter(point, scale: 5000));
    final mapResult = MapSearchResult(
      name: result.name,
      subtitle: result.subtitle,
      latitude: result.latitude,
      longitude: result.longitude,
      source: MapSearchSource.poi,
      address: result.address,
    );
    setState(() {
      _showResults = false;
      _showSuggestions = false;
      _selectedResult = mapResult;
      _lastSelectedResult = mapResult;
    });
    _addToRecentSearches(mapResult);
  }

  void _onAiRouteRequested(List<AiSearchResult> stops) {
    final isStopsEmpty = stops.isEmpty;
    if (isStopsEmpty) return;

    final AiSearchResult destination = stops.last;
    final hasMultipleStops = stops.length >= 2;
    final AiSearchResult? origin = hasMultipleStops ? stops.first : null;

    final destResult = MapSearchResult(
      name: destination.name,
      subtitle: destination.subtitle,
      latitude: destination.latitude,
      longitude: destination.longitude,
      source: MapSearchSource.poi,
      address: destination.address,
    );

    final hasOrigin = origin != null;
    if (hasOrigin) {
      _fromController.text = origin.name;
      _fromLatLng = (origin.latitude, origin.longitude);
    } else {
      final gps = _getUserLatLng();
      final hasGps = gps != null;
      _fromController.text = hasGps ? 'My Location' : '';
      _fromLatLng = gps;
    }

    _toController.text = destination.name;
    _routeDestination = destResult;
    _graphicsOverlay.graphics.clear();
    setState(() {
      _showRouteFields = true;
      _selectedResult = null;
      _mappedResults = [];
      _allCategoryResults = [];
      _showCategoryList = false;
      _activeCategory = null;
    });
    _solveRoute(destResult, originLatLng: _fromLatLng);
  }

  void _onFocusChanged() {
    _hideSearchOverlayWhenUnfocused();
    if (_focusNode.hasFocus) {
      _dismissCallout();
      setState(() {
        _showLayersPanel = false;
        _isTransitLegendMinimized = true;
      });
      final isSearchFocusEmpty = _searchController.text.isEmpty;
      if (isSearchFocusEmpty) {
        setState(() {
          _showSuggestions = true;
          _showResults = false;
        });
      }
    }
  }

  void _onFromFocusChanged() {
    _hideSearchOverlayWhenUnfocused();
    final hasFromFocus = _fromFocusNode.hasFocus;
    if (hasFromFocus) {
      setState(() {
        _showLayersPanel = false;
        _isTransitLegendMinimized = true;
        _activeRouteField = 'from';
        final isFromEmpty = _fromController.text.isEmpty;
        if (isFromEmpty) {
          _showSuggestions = true;
          _showResults = false;
        }
      });
      _detailSheetMinimized.value = true;
    }
  }

  void _onToFocusChanged() {
    _hideSearchOverlayWhenUnfocused();
    final hasToFocus = _toFocusNode.hasFocus;
    if (hasToFocus) {
      setState(() {
        _showLayersPanel = false;
        _isTransitLegendMinimized = true;
        _activeRouteField = 'to';
        final isToEmpty = _toController.text.isEmpty;
        if (isToEmpty) {
          _showSuggestions = true;
          _showResults = false;
        }
      });
      _detailSheetMinimized.value = true;
    }
  }

  void _hideSearchOverlayWhenUnfocused() {
    var hasFocus = _focusNode.hasFocus || _fromFocusNode.hasFocus || _toFocusNode.hasFocus;
    if (hasFocus) return;
    setState(() {
      _showSuggestions = false;
      _showResults = false;
      _matchingPoiClasses = [];
    });
  }

  void _onMapPointerDown(PointerDownEvent _) {
    if (_showLayersPanel) {
      setState(() => _showLayersPanel = false);
      return;
    }
    final isCategoryListOpen = _showCategoryList && _selectedResult == null;
    if (isCategoryListOpen) {
      final isAttached = _categorySheetController.isAttached;
      if (isAttached)
        _categorySheetController.animateTo(0.15, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
    final isSelectedResultOpen = _selectedResult != null;
    if (isSelectedResultOpen) _detailSheetMinimized.value = true;
  }

  // ---------------------------------------------------------------------------
  // Build Method
  // ---------------------------------------------------------------------------

  Widget _buildTransitLegend() {
    if (_isTransitLegendLoading) {
      return Card(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    if (_transitLegend.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              button: true,
              label: _isTransitLegendMinimized ? 'Expand transit routes legend' : 'Collapse transit routes legend',
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => setState(() => _isTransitLegendMinimized = !_isTransitLegendMinimized),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ExcludeSemantics(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Transit Routes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(width: 8),
                        Icon(_isTransitLegendMinimized ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (!_isTransitLegendMinimized) ...[
              const SizedBox(height: 6),
              for (final info in _transitLegend)
                InkWell(
                  onTap: () {
                    final isVisible = _transitRouteVisibility[info.name] ?? true;
                    _toggleTransitRoute(info.name, !isVisible);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Opacity(
                      opacity: (_transitRouteVisibility[info.name] ?? true) ? 1.0 : 0.5,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            (_transitRouteVisibility[info.name] ?? true)
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          if (_transitLegendSwatches[info.name] != null)
                            ExcludeSemantics(
                              child: RawImage(image: _transitLegendSwatches[info.name], width: 16, height: 16),
                            ),
                          const SizedBox(width: 8),
                          Text('${info.name} route', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final shouldShowCatListPanel = _showCategoryList && _allCategoryResults.isNotEmpty;

    final isDefaultScene = _sceneMode == 'default';
    final isBuilding3dScene = _sceneMode == 'building3d';
    final isDroneViewScene = _sceneMode == 'droneView';

    final indexedStackIndex = isBuilding3dScene ? 1 : (isDroneViewScene ? 2 : 0);

    final shouldShowScaleBar = _sceneMode == 'default' && _selectedResult == null && !shouldShowCatListPanel;
    final isFabVisible =
        !_hasNetworkError &&
        !keyboardVisible &&
        !_showLayersPanel &&
        _selectedResult == null &&
        !shouldShowCatListPanel &&
        !_showSuggestions &&
        !_showResults;
    final isLayersPanelVisible = _showLayersPanel && _config != null;
    final isSearchEnabledAndDefault = FeatureFlags.MAP_SEARCH_ENABLED && isDefaultScene && !_hasNetworkError;
    final hasValidResults = _mappedResults.isNotEmpty && !_hasNetworkError;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Map View Stack (2D Map View vs 3D Scene View)
              Semantics(
                sortKey: const OrdinalSortKey(3.0),
                child: Column(
                  children: [
                    Expanded(
                      child: _hasNetworkError
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const ExcludeSemantics(child: Icon(Icons.wifi_off, size: 48, color: Colors.grey)),
                                  const SizedBox(height: 16),
                                  const Text('Network error. Please try again.', style: TextStyle(fontSize: 16)),
                                  const SizedBox(height: 16),
                                  ElevatedButton(onPressed: _fetchConfigThenInit, child: const Text('Reload')),
                                ],
                              ),
                            )
                          : IndexedStack(
                              index: indexedStackIndex,
                              children: [
                                Semantics(
                                  label: 'Interactive 2D Campus Map',
                                  hint: 'Double tap and hold, then drag to pan. Pinch to zoom.',
                                  child: Listener(
                                    onPointerDown: _onMapPointerDown,
                                    child: ArcGISMapView(
                                      controllerProvider: () => _mapViewController,
                                      onMapViewReady: _onMapViewReady,
                                      onTap: _onMapTap,
                                    ),
                                  ),
                                ),
                                Semantics(
                                  label: 'Interactive 3D Campus Scene',
                                  hint: 'Double tap and hold, then drag to pan. Pinch to zoom.',
                                  child: _scene3DWidget ?? const SizedBox.shrink(),
                                ),
                                Semantics(
                                  label: 'Interactive 3D Drone Scene',
                                  hint: 'Double tap and hold, then drag to pan. Pinch to zoom.',
                                  child: _sceneDroneWidget ?? const SizedBox.shrink(),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),

              // Hidden Semantics nodes for Map Pins / Graphics
              if (hasValidResults && isDefaultScene)
                Builder(
                  builder: (context) {
                    final List<Widget> semanticsNodes = [];
                    final vp = _mapViewController.getCurrentViewpoint(ViewpointType.boundingGeometry);
                    final mapSr = vp?.targetGeometry.spatialReference;

                    for (int i = 0; i < _mappedResults.length; i++) {
                      final result = _mappedResults[i];
                      var mapPoint = ArcGISPoint(
                        x: result.longitude,
                        y: result.latitude,
                        spatialReference: SpatialReference.wgs84,
                      );
                      final hasValidSpatialReference = mapSr != null && mapPoint.spatialReference != null;
                      if (hasValidSpatialReference) {
                        try {
                          final proj = GeometryEngine.project(mapPoint, outputSpatialReference: mapSr);
                          mapPoint = proj as ArcGISPoint;
                        } catch (_) {}
                      }

                      final screenPt = _mapViewController.locationToScreen(mapPoint: mapPoint);
                      // Keep within visible bounds roughly
                      final isWithinHorizontalBounds = screenPt.dx >= -50 && screenPt.dx <= constraints.maxWidth + 50;
                      final isWithinVerticalBounds = screenPt.dy >= -50 && screenPt.dy <= constraints.maxHeight + 50;
                      if (isWithinHorizontalBounds && isWithinVerticalBounds) {
                        semanticsNodes.add(
                          Positioned(
                            left: screenPt.dx - 24,
                            top: screenPt.dy - 48,
                            child: Semantics(
                              label: 'Map pin: ${result.name}',
                              hint: 'Double tap to view details.',
                              button: true,
                              onTap: () {
                                if (i < _graphicsOverlay.graphics.length) {
                                  _handlePinTap(result, _graphicsOverlay.graphics[i]);
                                } else {
                                  _selectResultFromPin(result);
                                }
                              },
                              child: const SizedBox(width: 48, height: 48),
                            ),
                          ),
                        );
                      }
                    }
                    return Semantics(
                      sortKey: const OrdinalSortKey(4.0),
                      child: Stack(children: semanticsNodes),
                    );
                  },
                ),

              // Map controls stay behind search and slide-over panels.
              if (isFabVisible)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 68,
                  right: 16,
                  child: Semantics(
                    sortKey: const OrdinalSortKey(5.0),
                    child: EsriMapFabCluster(
                      isDark: isDark,
                      is3D: _sceneMode != 'default',
                      mapRotation: _mapRotation,
                      isLocationActive: _isLocationActive,
                      isRecenterActive: _isRecenterActive,
                      onShowLayersPanel: () => setState(() => _showLayersPanel = true),
                      onRecenterOnView: _recenterOnView,
                      onRecenterOnUser: _recenterOnUser,
                      onSnapToNorth: _snapToNorth,
                      onZoomIn: _zoomIn,
                      onZoomOut: _zoomOut,
                    ),
                  ),
                ),

              // Bottom-right center-on-me button
              if (isFabVisible && _sceneMode == 'default')
                Builder(
                  builder: (context) {
                    double? screenAngle;
                    bool isUserVisible = false;

                    if (!_isLocationActive) {
                      try {
                        final pos = _mapViewController.locationDisplay.location?.position;
                        final vp = _mapViewController.getCurrentViewpoint(ViewpointType.boundingGeometry);
                        final geom = vp?.targetGeometry;
                        if (pos != null && geom != null) {
                          final projectedPos = GeometryEngine.project(
                            pos,
                            outputSpatialReference: geom.spatialReference!,
                          );
                          isUserVisible = GeometryEngine.intersects(geometry1: projectedPos, geometry2: geom);

                          if (!isUserVisible) {
                            final screenPoint = _mapViewController.locationToScreen(
                              mapPoint: projectedPos as ArcGISPoint,
                            );
                            // FAB center is bottom: 100, right: 16, size: 48x48 -> center is 24px inwards
                            final fabX = constraints.maxWidth - 16 - 24;
                            final fabY = constraints.maxHeight - 100 - 24;

                            final dx = screenPoint.dx - fabX;
                            final dy = screenPoint.dy - fabY;
                            // angle from UP (negative Y)
                            screenAngle = math.atan2(dx, -dy);
                          }
                        }
                      } catch (_) {}
                    }

                    return Positioned(
                      bottom: 100,
                      right: 16,
                      child: Semantics(
                        sortKey: const OrdinalSortKey(6.0),
                        child: EsriMapLocationFab(
                          isDark: isDark,
                          isLocationActive: _isLocationActive,
                          isUserVisible: isUserVisible,
                          isLoading: _isLocatingUser,
                          bearingToUser: screenAngle,
                          mapRotation: _mapRotation,
                          onRecenterOnUser: _recenterOnUser,
                        ),
                      ),
                    );
                  },
                ),

              if (_loadingLocation != null)
                Builder(
                  builder: (context) {
                    final screenPt = _mapViewController.locationToScreen(mapPoint: _loadingLocation!);
                    return Positioned(
                      left: screenPt.dx - 12,
                      top: screenPt.dy - 12,
                      child: Semantics(
                        sortKey: const OrdinalSortKey(7.0),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            shape: BoxShape.circle,
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          padding: const EdgeInsets.all(4),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? Colors.white : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Floating top search bar & suggestion panel
              if (isSearchEnabledAndDefault)
                Positioned(
                  top: 8,
                  left: 12,
                  right: 12,
                  child: Semantics(
                    sortKey: const OrdinalSortKey(1.0),
                    child: Column(
                      children: [
                        EsriMapSearchBar(
                          config: _config,
                          showRouteFields: _showRouteFields,
                          searchController: _searchController,
                          focusNode: _focusNode,
                          fromController: _fromController,
                          fromFocusNode: _fromFocusNode,
                          toController: _toController,
                          toFocusNode: _toFocusNode,
                          showSuggestions: _showSuggestions,
                          showResults: _showResults,
                          isSearching: _isSearching,
                          searchResults: _searchResults,
                          matchingPoiClasses: _matchingPoiClasses,
                          onPerformSearch: _queueSearch,
                          onPerformClassSearch: _performClassSearch,
                          onSelectResult: _selectResult,
                          onClearSearch: _clearSearch,
                          onClearRoute: _clearRoute,
                          onSwapRouteFields: () {
                            final tmpText = _fromController.text;
                            final tmpLatLng = _fromLatLng;
                            _fromController.text = _toController.text;
                            _toController.text = tmpText;
                            setState(() {
                              final hasRouteDestination = _routeDestination != null;
                              _fromLatLng = hasRouteDestination
                                  ? (_routeDestination!.latitude, _routeDestination!.longitude)
                                  : null;
                              final hasTmpLatLng = tmpLatLng != null;
                              _routeDestination = hasTmpLatLng
                                  ? MapSearchResult(
                                      name: tmpText,
                                      subtitle: '',
                                      latitude: tmpLatLng.$1,
                                      longitude: tmpLatLng.$2,
                                      source: MapSearchSource.building,
                                    )
                                  : null;
                            });
                            final canSolveRoute = _routeDestination != null && _fromLatLng != null;
                            if (canSolveRoute) _solveRoute(_routeDestination!, originLatLng: _fromLatLng);
                          },
                          onTapSearchField: () {
                            final hasSelectedResult = _selectedResult != null;
                            if (hasSelectedResult) setState(() => _selectedResult = null);
                            final isSearchTextEmpty = _searchController.text.isEmpty;
                            if (isSearchTextEmpty) {
                              setState(() {
                                _showSuggestions = true;
                                _showResults = false;
                              });
                            }
                          },
                          onTapFromField: () {
                            setState(() {
                              _activeRouteField = 'from';
                              _showSuggestions = true;
                              _showResults = false;
                            });
                          },
                          onTapToField: () {
                            setState(() {
                              _activeRouteField = 'to';
                              _showSuggestions = true;
                              _showResults = false;
                            });
                          },
                          onChangedFromField: (text) {
                            _fromLatLng = null;
                            final isLongEnough = text.length >= 3;
                            final isTextEmpty = text.isEmpty;
                            if (isLongEnough) {
                              _queueSearch(text);
                            } else if (isTextEmpty) {
                              _cancelPendingSearch();
                              setState(() {
                                _isSearching = false;
                                _showResults = false;
                                _showSuggestions = true;
                              });
                            } else {
                              _cancelPendingSearch();
                              setState(() {
                                _isSearching = false;
                                _showResults = false;
                                _showSuggestions = false;
                              });
                            }
                          },
                          onChangedToField: (text) {
                            final isLongEnough = text.length >= 3;
                            final isTextEmpty = text.isEmpty;
                            if (isLongEnough) {
                              _queueSearch(text);
                            } else if (isTextEmpty) {
                              _cancelPendingSearch();
                              setState(() {
                                _isSearching = false;
                                _showResults = false;
                                _showSuggestions = true;
                              });
                            } else {
                              _cancelPendingSearch();
                              setState(() {
                                _isSearching = false;
                                _showResults = false;
                                _showSuggestions = false;
                              });
                            }
                          },
                          onClearFromField: () {
                            _cancelPendingSearch();
                            _fromController.clear();
                            _fromLatLng = null;
                            setState(() {
                              _isSearching = false;
                              _showResults = false;
                              _showSuggestions = true;
                            });
                          },
                          onClearToField: () {
                            _cancelPendingSearch();
                            _toController.clear();
                            setState(() {
                              _isSearching = false;
                              _showResults = false;
                              _showSuggestions = true;
                            });
                          },
                          onOpenAiSearch: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => EsriAiSearchSheet(
                              userLat: _getUserLatLng()?.$1,
                              userLon: _getUserLatLng()?.$2,
                              onLocationSelected: _onAiLocationSelected,
                              onRouteRequested: _onAiRouteRequested,
                            ),
                          ),
                          iconForClass: _iconForClass,
                          labelForClass: _labelForClass,
                          iconForResult: _iconForResult,
                        ),

                        // Suggestions panel (Category icons + Recent Search History)
                        if (_showSuggestions && !_showResults)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: EsriMapSuggestionsPanel(
                              categories: _categories,
                              recentSearches: _recentSearches,
                              showRouteFields: _showRouteFields,
                              activeRouteField: _activeRouteField,
                              onSelectCurrentLocation: () async {
                                (double, double)? gps = await _getDeviceLocationEfficiently();
                                if (gps == null) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Unable to get your current location.')),
                                    );
                                  }
                                  return;
                                }
                                _fromController.text = 'My Location';
                                _fromLatLng = gps;
                                if (mounted) {
                                  setState(() {
                                    _showSuggestions = false;
                                    _showResults = false;
                                  });
                                }
                                _fromFocusNode.unfocus();
                                final hasRouteDestination = _routeDestination != null;
                                if (hasRouteDestination) _solveRoute(_routeDestination!, originLatLng: _fromLatLng);
                              },
                              onSelectCategory: _performCategorySearch,
                              onSelectRecent: _selectResult,
                              onRemoveRecent: _removeFromRecentSearches,
                              onClearRecent: _clearRecentSearches,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              // Category results list panel
              if (shouldShowCatListPanel)
                Semantics(
                  sortKey: const OrdinalSortKey(1.5),
                  child: EsriMapCategoryListPanel(
                    key: const Key('category_list_panel'),
                    controller: _categorySheetController,
                    activeCategory: _activeCategory,
                    allCategoryResults: _allCategoryResults,
                    viewportResults: EsriMapSearchService.filterToViewport(
                      _allCategoryResults,
                      _getViewportEnvelopeWGS84(),
                    ),
                    userLocation: _getUserLatLng(),
                    onClearSearch: _clearSearch,
                    onSeeAllResults: _seeAllCategoryResults,
                    onSelectResult: _selectResultFromList,
                    iconForResult: _iconForResult,
                  ),
                ),

              // Dynamic Google Maps-style Scale Bar Indicator
              if (shouldShowScaleBar)
                Positioned(
                  bottom: 24,
                  right: 16,
                  child: Semantics(
                    sortKey: const OrdinalSortKey(8.0),
                    child: EsriMapScaleBar(scale: _currentScale, isDark: isDark),
                  ),
                ),

              // Transit Legend
              if (_layerVisible['tritonTransit'] == true && isFabVisible)
                Positioned(
                  bottom: 24,
                  left: 16,
                  child: Semantics(sortKey: const OrdinalSortKey(9.0), child: _buildTransitLegend()),
                ),

              // Selected Result Detail Slide-over
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutQuart,
                switchOutCurve: Curves.easeInQuart,
                transitionBuilder: (child, animation) {
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(position: offsetAnimation, child: child);
                },
                child: _selectedResult != null
                    ? Semantics(
                        key: ValueKey(_selectedResult!.name),
                        sortKey: const OrdinalSortKey(1.6),
                        child: LayoutBuilder(
                          builder: (context, constraints) => EsriMapDetailSlideOver(
                            minimizedNotifier: _detailSheetMinimized,
                            availableHeight: constraints.maxHeight,
                            result: _selectedResult!,
                            resultIcon: _iconForResult(_selectedResult!),
                            isRoutingMode: _isRouting,
                            hasRoute: _hasRoute,
                            routeFailed: _routeFailed,
                            travelMode: _travelMode,
                            routeTravelTimeMinutes: _routeTravelTimeMinutes,
                            routeManeuvers: _routeManeuvers,
                            fromLatLng: _fromLatLng,
                            onGetDirections: (res) {
                              final gps = _getUserLatLng();
                              final hasGps = gps != null;
                              _fromController.text = hasGps ? 'My Location' : '';
                              _toController.text = res.name;
                              _routeDestination = res;
                              _graphicsOverlay.graphics.clear();
                              setState(() {
                                _showRouteFields = true;
                                _mappedResults = [];
                                _allCategoryResults = [];
                                _showCategoryList = false;
                                _activeCategory = null;
                              });
                              _solveRoute(res);
                            },
                            onTravelModeChanged: (mode) {
                              final hasSelectedResult = _selectedResult != null;
                              if (hasSelectedResult)
                                _solveRoute(_selectedResult!, travelMode: mode, originLatLng: _fromLatLng);
                            },
                            onLaunchWebsite: _launchWebsite,
                            onClose: _closeDetail,
                            onClearRoute: _clearRoute,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty_detail')),
              ),

              // Basemap & Operational Layer Selector Panel
              if (isLayersPanelVisible) ...[
                Positioned.fill(
                  child: Semantics(
                    sortKey: const OrdinalSortKey(1.7),
                    button: true,
                    label: 'Close map displays menu',
                    child: GestureDetector(
                      onTap: () => setState(() => _showLayersPanel = false),
                      child: Container(color: const Color(0x80000000)),
                    ),
                  ),
                ),
                EsriMapLayersPanel(
                  config: _config!,
                  currentBasemapType: _currentBasemapType,
                  currentSceneKey: _sceneMode,
                  layerVisible: _layerVisible,
                  layerLoading: _layerLoading,
                  hideSceneSwitcher: _selectedResult != null || _showCategoryList,
                  onSwitchBasemap: _switchBasemap,
                  onSetSceneMode: _setSceneMode,
                  onToggleLayer: _toggleLayer,
                  onClose: () => setState(() => _showLayersPanel = false),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
