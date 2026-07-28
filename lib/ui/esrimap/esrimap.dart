/// ============================================================================
/// File: esrimap.dart
/// Description: Main campus Esri map screen widget. Integrates the 2D/3D map view,
///              location display, top search bar, floating action buttons,
///              basemap & operational layer controls, and bottom slide-over panels.
/// ============================================================================

import 'dart:async';
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
import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_scene.dart';
import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_search_bar.dart';
import 'package:campus_mobile_experimental/ui/esrimap/esri_map_widgets/esrimap_suggestions_panel.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final _detailSheetController = DraggableScrollableController();

  // ---------------------------------------------------------------------------
  // Map State & Services
  // ---------------------------------------------------------------------------
  EsriMapConfig? _config;
  final _locationDataSource = SystemLocationDataSource();

  // Search State
  List<MapSearchResult> _searchResults = [];
  List<String> _allPoiClasses = [];
  List<String> _matchingPoiClasses = [];
  bool _showResults = false;
  bool _isSearching = false;
  bool _showSuggestions = false;
  List<MapSearchResult> _recentSearches = [];

  // Active Category & Pin Plotting State
  MapSearchResult? _selectedResult;
  MapSearchResult? _lastSelectedResult;
  List<MapSearchResult> _mappedResults = [];
  List<MapSearchResult> _allCategoryResults = [];
  bool _showCategoryList = false;
  EsriSearchCategory? _activeCategory;

  // FAB & Viewpoint State
  bool _isLocationActive = false;
  bool _isRecenterActive = false;
  bool _ignoreViewpointReset = false;
  double _mapRotation = 0.0;
  StreamSubscription<void>? _viewpointChangedSubscription;

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

  // Basemaps & Operational Layers State
  BasemapType _currentBasemapType = BasemapType.defaultMap;
  final Map<BasemapType, Basemap> _basemaps = {};
  bool _showLayersPanel = false;
  final Map<String, bool> _layerVisible = {};
  final Map<String, bool> _layerLoading = {};
  final Map<String, List<Layer?>> _layerInstances = {};
  final Map<String, Timer> _layerTimers = {};

  // 3D Scene Widgets & Keys
  String _sceneMode = 'default';
  EsriSceneWidget? _scene3DWidget;
  EsriSceneWidget? _sceneDroneWidget;
  final _scene3DKey = GlobalKey<EsriSceneWidgetState>();
  final _sceneDroneKey = GlobalKey<EsriSceneWidgetState>();

  final _mapReadyCompleter = Completer<void>();

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

  /// Fetches remote configuration JSON before initializing the map.
  Future<void> _fetchConfigThenInit() async {
    try {
      final config = await EsriMapConfigService.instance.fetch();
      final isNotMounted = !mounted;
      if (isNotMounted) return;
      setState(() => _config = config);
      _initMap(config);
      _fetchAllPoiClasses();
    } catch (e) {
      debugPrint('Config fetch failed: $e');
      _mapReadyCompleter.completeError(e);
    }
  }

  /// Constructs initial basemaps and sets initial campus viewpoint.
  void _initMap(EsriMapConfig config) {
    for (final type in BasemapType.values) {
      if (!FeatureFlags.mapAlternateBasemapsEnabled && (type == BasemapType.light || type == BasemapType.dark))
        continue;
      _basemaps[type] = buildBasemap(type, config);
    }

    _map = ArcGISMap.withBasemap(_basemaps[_currentBasemapType]!);
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
    _mapViewController.interactionOptions.rotateEnabled = true;

    final isGraphicsOverlayMissing = !_mapViewController.graphicsOverlays.contains(_graphicsOverlay);
    if (isGraphicsOverlayMissing) _mapViewController.graphicsOverlays.add(_graphicsOverlay);
    final isRouteOverlayMissing = !_mapViewController.graphicsOverlays.contains(_routeGraphicsOverlay);
    if (isRouteOverlayMissing) _mapViewController.graphicsOverlays.add(_routeGraphicsOverlay);

    // Configure location display settings
    _mapViewController.locationDisplay.dataSource = _locationDataSource;
    _mapViewController.locationDisplay.autoPanMode = LocationDisplayAutoPanMode.off;

    _startLocationDisplay();
    _preloadAlternateBasemaps();

    // Track map heading rotation changes
    _viewpointChangedSubscription = _mapViewController.onViewpointChanged.listen((_) {
      final vp = _mapViewController.getCurrentViewpoint(ViewpointType.centerAndScale);
      final isVpValid = vp != null && mounted;
      if (isVpValid) {
        setState(() {
          _mapRotation = vp.rotation;
          final shouldResetVP = !_ignoreViewpointReset && (_isLocationActive || _isRecenterActive);
          if (shouldResetVP) {
            _isLocationActive = false;
            _isRecenterActive = false;
          }
        });
      }
    });
  }

  /// Sets authentication manager challenge handler for Enterprise token retrieval.
  void _setupAgeAuthChallengeHandler() {
    ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler = AgeAuthChallengeHandler(
      EsriMapConfigService.instance.tokensUrl,
    );
  }

  @override
  void dispose() {
    _categorySheetController.dispose();
    _detailSheetController.dispose();
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

  /// Starts the device location data source.
  Future<void> _startLocationDisplay() async {
    if (!FeatureFlags.mapLocationTrackingEnabled) return;
    try {
      await _locationDataSource.start();
    } on ArcGISException catch (e) {
      debugPrint('Location error: ${e.message}');
    } catch (e) {
      debugPrint('Location error: $e');
    }
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
      for (final layer in _layerInstances[key] ?? []) {
        final isLayerNotNull = layer != null;
        if (isLayerNotNull) _map.operationalLayers.remove(layer);
      }
      _layerInstances.remove(key);
      setState(() => _layerVisible[key] = false);
      return;
    }

    setState(() => _layerLoading[key] = true);
    final instances = _buildLayerInstances(entry);
    _layerInstances[key] = instances;

    for (final layer in instances) {
      final isLayerNotNull = layer != null;
      if (isLayerNotNull) _map.operationalLayers.add(layer);
    }

    try {
      await Future.wait(instances.whereType<Layer>().map((l) => l.load()));
      _applyLayerSpecialCases(key, instances);
    } catch (e) {
      debugPrint('Layer $key load error: $e');
    }

    _startLayerRefreshTimer(key, entry);

    setState(() {
      _layerVisible[key] = true;
      _layerLoading[key] = false;
    });
  }

  List<Layer?> _buildLayerInstances(LayerEntry entry) {
    if (entry.hasSublayers) return entry.sublayers!.map(_layerFromSublayer).toList();
    return [_layerFromEntry(entry)];
  }

  Layer? _layerFromSublayer(SublayerEntry sub) {
    final isUrlSub = sub.source == 'url' && sub.url != null;
    if (isUrlSub) {
      final isFeatureServer = sub.url!.contains('FeatureServer');
      return isFeatureServer
          ? FeatureLayer.withFeatureTable(ServiceFeatureTable.withUri(Uri.parse(sub.url!)))
          : ArcGISMapImageLayer.withUri(Uri.parse(sub.url!));
    }
    return null;
  }

  Layer? _layerFromEntry(LayerEntry entry) {
    final isUrlEntry = entry.source == 'url' && entry.url != null;
    if (isUrlEntry) {
      final isFeatureServer = entry.url!.contains('FeatureServer');
      return isFeatureServer
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

  Future<void> _fetchAllPoiClasses() async {
    final classes = await EsriMapSearchService.fetchAllPoiClasses();
    if (mounted) setState(() => _allPoiClasses = classes);
  }

  /// Text search: queries buildings and POIs concurrently.
  Future<void> _performSearch(String query) async {
    final isQueryEmpty = query.trim().isEmpty;
    if (isQueryEmpty) return;

    final q = query.toLowerCase();
    final matched = _allPoiClasses.where((c) => c.toLowerCase().contains(q)).toList();

    for (final cat in _categories) {
      final matchesCat = cat.poiClassValue.toLowerCase().contains(q) && !matched.contains(cat.poiClassValue);
      if (matchesCat) matched.insert(0, cat.poiClassValue);
    }

    setState(() {
      _isSearching = true;
      _showResults = true;
      _showSuggestions = false;
      _selectedResult = null;
      _matchingPoiClasses = matched;
    });

    try {
      final results = await Future.wait([
        EsriMapSearchService.queryBuildings(query),
        EsriMapSearchService.queryPOIs(query),
      ]);
      final merged = <MapSearchResult>[...results[0], ...results[1]];
      if (mounted) {
        setState(() {
          _searchResults = merged;
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  /// Category search: queries POIs filtered by class and plots pins on the map.
  Future<void> _performCategorySearch(EsriSearchCategory category) async {
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
      final allResults = await EsriMapSearchService.queryPOIsByClass(category.poiClassValue);
      _plotResultsOnMap(allResults);

      setState(() {
        _allCategoryResults = allResults;
        _showCategoryList = allResults.isNotEmpty;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Category search error: $e');
      setState(() {
        _mappedResults = [];
        _allCategoryResults = [];
        _isSearching = false;
      });
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
    _graphicsOverlay.graphics.clear();
    _mappedResults = results;
    for (int i = 0; i < results.length; i++) {
      final result = results[i];
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
          scale: 5000,
        ),
      );
      return;
    }

    double minLat = results.map((r) => r.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = results.map((r) => r.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = results.map((r) => r.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = results.map((r) => r.longitude).reduce((a, b) => a > b ? a : b);

    const padding = 0.005;
    final envelope = Envelope.fromXY(
      xMin: minLng - padding,
      yMin: minLat - padding,
      xMax: maxLng + padding,
      yMax: maxLat + padding,
      spatialReference: SpatialReference.wgs84,
    );
    _mapViewController.setViewpointAnimated(Viewpoint.fromTargetExtent(envelope));
  }

  void _seeAllCategoryResults() {
    final isAllCategoryResultsEmpty = _allCategoryResults.isEmpty;
    if (isAllCategoryResultsEmpty) return;
    _zoomToResults(_allCategoryResults);
  }

  void _selectResult(MapSearchResult result) {
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
    final isDropdownVisible = _showSuggestions || _showResults;
    if (isDropdownVisible) {
      setState(() {
        _showSuggestions = false;
        _showResults = false;
      });
      _focusNode.unfocus();
      return;
    }

    final isMappedResultsEmpty = _mappedResults.isEmpty;
    if (isMappedResultsEmpty) {
      final isSelectedResultNotNull = _selectedResult != null;
      if (isSelectedResultNotNull) _closeDetail();
      return;
    }

    try {
      final identifyResult = await _mapViewController.identifyGraphicsOverlay(
        _graphicsOverlay,
        screenPoint: screenPoint,
        tolerance: 12.0,
        maximumResults: 1,
      );

      final hasGraphics = identifyResult.graphics.isNotEmpty;
      if (hasGraphics) {
        final tappedGraphic = identifyResult.graphics.first;
        final index = tappedGraphic.attributes['resultIndex'] as int?;
        final isValidResultIndex = index != null && index >= 0 && index < _mappedResults.length;
        if (isValidResultIndex) _selectResultFromPin(_mappedResults[index]);
      } else {
        final isSelectedResultNotNull = _selectedResult != null;
        if (isSelectedResultNotNull) _closeDetail();
      }
    } catch (e) {
      debugPrint('Identify error: $e');
    }
  }

  void _selectResultFromPin(MapSearchResult result) {
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
      _searchController.text = result.name;
      _showResults = false;
      _showSuggestions = false;
      _showCategoryList = false;
    });
    _focusNode.unfocus();
    _addToRecentSearches(result);
  }

  void _closeDetail() {
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
    try {
      final location = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: Duration(seconds: 10)),
      );
      if (!mounted) return;

      _ignoreViewpointReset = true;
      setState(() => _isLocationActive = true);
      _mapViewController.setViewpointAnimated(
        Viewpoint.fromCenter(
          ArcGISPoint(x: location.longitude, y: location.latitude, spatialReference: SpatialReference.wgs84),
          scale: 10000,
        ),
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) _ignoreViewpointReset = false;
      });
    } catch (e) {
      debugPrint('Location error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to get your current location.')));
    }
  }

  void _recenterOnView() {
    _ignoreViewpointReset = true;
    setState(() => _isRecenterActive = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _ignoreViewpointReset = false;
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

  void _clearSearch() {
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
    if (!FeatureFlags.mapRoutingEnabled) return;
    final userLatLng = originLatLng ?? _getUserLatLng();
    final isUserLatLngNull = userLatLng == null;
    if (isUserLatLngNull) {
      setState(() => _isRouting = false);
      return;
    }

    final mode = travelMode ?? _travelMode;
    setState(() {
      _isRouting = true;
      _routeFailed = false;
      _travelMode = mode;
    });

    final routeRes = await EsriMapRouteService.solveRoute(
      originLatLng: userLatLng,
      destination: destination,
      travelMode: mode,
    );

    final isRouteResNull = routeRes == null;
    if (isRouteResNull) {
      if (mounted) {
        setState(() {
          _isRouting = false;
          _routeFailed = true;
        });
      }
      return;
    }

    _routeTravelTimeMinutes = routeRes.travelTimeMinutes;
    _routeManeuvers = routeRes.directionManeuvers;

    _routeGraphicsOverlay.graphics.clear();
    final hasRouteGeometry = routeRes.routeGeometry != null;
    if (hasRouteGeometry) {
      _routeGraphicsOverlay.graphics.add(
        Graphic(
          geometry: routeRes.routeGeometry!,
          symbol: SimpleLineSymbol(style: SimpleLineSymbolStyle.solid, color: Colors.blue, width: 4),
        ),
      );
    }

    final whiteOutline = SimpleLineSymbol(style: SimpleLineSymbolStyle.solid, color: Colors.white, width: 2);
    _routeGraphicsOverlay.graphics.add(
      Graphic(
        geometry: ArcGISPoint(
          x: destination.longitude,
          y: destination.latitude,
          spatialReference: SpatialReference.wgs84,
        ),
        symbol: SimpleMarkerSymbol(style: SimpleMarkerSymbolStyle.circle, color: Colors.red, size: 12)
          ..outline = whiteOutline,
      ),
    );

    final hasOriginLatLng = originLatLng != null;
    if (hasOriginLatLng) {
      _routeGraphicsOverlay.graphics.add(
        Graphic(
          geometry: ArcGISPoint(x: originLatLng.$2, y: originLatLng.$1, spatialReference: SpatialReference.wgs84),
          symbol: SimpleMarkerSymbol(style: SimpleMarkerSymbolStyle.circle, color: Colors.blue, size: 12)
            ..outline = whiteOutline,
        ),
      );
    }

    final hasPaddedExtent = routeRes.paddedExtent != null;
    if (hasPaddedExtent) _mapViewController.setViewpointAnimated(Viewpoint.fromTargetExtent(routeRes.paddedExtent!));

    _graphicsOverlay.graphics.clear();
    _mappedResults = [];
    _allCategoryResults = [];

    setState(() {
      _isRouting = false;
      _hasRoute = true;
      _showCategoryList = false;
      _activeCategory = null;
      _selectedResult = destination;
      _lastSelectedResult = destination;
    });
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
    final isSearchFocusEmpty = _focusNode.hasFocus && _searchController.text.isEmpty;
    if (isSearchFocusEmpty) {
      setState(() {
        _showSuggestions = true;
        _showResults = false;
      });
    }
  }

  void _onFromFocusChanged() {
    final hasFromFocus = _fromFocusNode.hasFocus;
    if (hasFromFocus) {
      setState(() {
        _activeRouteField = 'from';
        final isFromEmpty = _fromController.text.isEmpty;
        if (isFromEmpty) {
          _showSuggestions = true;
          _showResults = false;
        }
      });
      final isAttached = _detailSheetController.isAttached;
      if (isAttached)
        _detailSheetController.animateTo(0.15, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  void _onToFocusChanged() {
    final hasToFocus = _toFocusNode.hasFocus;
    if (hasToFocus) {
      setState(() {
        _activeRouteField = 'to';
        final isToEmpty = _toController.text.isEmpty;
        if (isToEmpty) {
          _showSuggestions = true;
          _showResults = false;
        }
      });
      final isAttached = _detailSheetController.isAttached;
      if (isAttached)
        _detailSheetController.animateTo(0.15, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
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
    if (isSelectedResultOpen) {
      final isAttached = _detailSheetController.isAttached;
      if (isAttached)
        _detailSheetController.animateTo(0.15, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  // ---------------------------------------------------------------------------
  // Build Method
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final shouldShowCatListPanel = _showCategoryList && _selectedResult == null && _allCategoryResults.isNotEmpty;

    final isDefaultScene = _sceneMode == 'default';
    final isBuilding3dScene = _sceneMode == 'building3d';
    final isDroneViewScene = _sceneMode == 'droneView';

    final indexedStackIndex = isBuilding3dScene ? 1 : (isDroneViewScene ? 2 : 0);

    final isFabVisible =
        !keyboardVisible &&
        !_focusNode.hasFocus &&
        !_fromFocusNode.hasFocus &&
        !_toFocusNode.hasFocus &&
        !_showLayersPanel;

    final isLayersPanelVisible = _showLayersPanel && _config != null;

    return Scaffold(
      body: Stack(
        children: [
          // Map View Stack (2D Map View vs 3D Scene View)
          Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: indexedStackIndex,
                  children: [
                    Listener(
                      onPointerDown: _onMapPointerDown,
                      child: ArcGISMapView(
                        controllerProvider: () => _mapViewController,
                        onMapViewReady: _onMapViewReady,
                        onTap: _onMapTap,
                      ),
                    ),
                    _scene3DWidget ?? const SizedBox.shrink(),
                    _sceneDroneWidget ?? const SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),

          // Floating top search bar & suggestion panel
          if (FeatureFlags.mapSearchEnabled && isDefaultScene)
            Positioned(
              top: 8,
              left: 12,
              right: 12,
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
                    onPerformSearch: _performSearch,
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
                        _performSearch(text);
                      } else if (isTextEmpty) {
                        setState(() {
                          _showResults = false;
                          _showSuggestions = true;
                        });
                      } else {
                        setState(() {
                          _showResults = false;
                          _showSuggestions = false;
                        });
                      }
                    },
                    onChangedToField: (text) {
                      final isLongEnough = text.length >= 3;
                      final isTextEmpty = text.isEmpty;
                      if (isLongEnough) {
                        _performSearch(text);
                      } else if (isTextEmpty) {
                        setState(() {
                          _showResults = false;
                          _showSuggestions = true;
                        });
                      } else {
                        setState(() {
                          _showResults = false;
                          _showSuggestions = false;
                        });
                      }
                    },
                    onClearFromField: () {
                      _fromController.clear();
                      _fromLatLng = null;
                      setState(() => _showSuggestions = true);
                    },
                    onClearToField: () {
                      _toController.clear();
                      setState(() => _showSuggestions = true);
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
                        onSelectCurrentLocation: () {
                          final gps = _getUserLatLng();
                          final isGpsNull = gps == null;
                          if (isGpsNull) return;
                          _fromController.text = 'My Location';
                          _fromLatLng = gps;
                          setState(() {
                            _showSuggestions = false;
                            _showResults = false;
                          });
                          _fromFocusNode.unfocus();
                          final hasRouteDestination = _routeDestination != null;
                          if (hasRouteDestination) _solveRoute(_routeDestination!, originLatLng: _fromLatLng);
                        },
                        onSelectCategory: _performCategorySearch,
                        onSelectRecent: _selectResult,
                        onRemoveRecent: _removeFromRecentSearches,
                      ),
                    ),
                ],
              ),
            ),

          // Category results list panel
          if (shouldShowCatListPanel)
            EsriMapCategoryListPanel(
              controller: _categorySheetController,
              activeCategory: _activeCategory,
              allCategoryResults: _allCategoryResults,
              viewportResults: EsriMapSearchService.filterToViewport(_allCategoryResults, _getViewportEnvelopeWGS84()),
              userLocation: _getUserLatLng(),
              onClearSearch: _clearSearch,
              onSeeAllResults: _seeAllCategoryResults,
              onSelectResult: _selectResultFromPin,
              iconForResult: _iconForResult,
            ),

          // Selected Result Detail Slide-over
          if (_selectedResult != null)
            EsriMapDetailSlideOver(
              controller: _detailSheetController,
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
                  _selectedResult = null;
                  _mappedResults = [];
                  _allCategoryResults = [];
                  _showCategoryList = false;
                  _activeCategory = null;
                });
                _solveRoute(res);
              },
              onTravelModeChanged: (mode) {
                final hasSelectedResult = _selectedResult != null;
                if (hasSelectedResult) _solveRoute(_selectedResult!, travelMode: mode, originLatLng: _fromLatLng);
              },
              onLaunchWebsite: _launchWebsite,
              onClose: _closeDetail,
              onClearRoute: _clearRoute,
            ),

          // Top-right FAB cluster (Compass, Recenter, Location, Layers)
          if (isFabVisible)
            Positioned(
              top: MediaQuery.of(context).padding.top + 68,
              right: 16,
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
              ),
            ),

          // Basemap & Operational Layer Selector Panel
          if (isLayersPanelVisible)
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
      ),
    );
  }
}
