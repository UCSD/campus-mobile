import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'esrimap_basemaps.dart';
import 'esrimap_fab.dart';
import 'esrimap_layers_panel.dart';
import 'esrimap_scene.dart';

// -----------------------------------------------------------------------------
// Model
// -----------------------------------------------------------------------------

/// Unified search result model for both Buildings and POIs.
class MapSearchResult {
  final String name;
  final String subtitle;
  final double latitude;
  final double longitude;
  final MapSearchSource source;
  final String address;
  final String description;
  final String? websiteUrl;

  const MapSearchResult({
    required this.name,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
    required this.source,
    this.address = '',
    this.description = '',
    this.websiteUrl,
  });

  /// Serialize to JSON for SharedPreferences storage.
  Map<String, dynamic> toJson() => {
        'name': name,
        'subtitle': subtitle,
        'latitude': latitude,
        'longitude': longitude,
        'source': source.index,
        'address': address,
        'description': description,
        'websiteUrl': websiteUrl,
      };

  /// Deserialize from JSON.
  factory MapSearchResult.fromJson(Map<String, dynamic> json) {
    return MapSearchResult(
      name: json['name'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      source: MapSearchSource.values[json['source'] as int? ?? 0],
      address: json['address'] as String? ?? '',
      description: json['description'] as String? ?? '',
      websiteUrl: json['websiteUrl'] as String?,
    );
  }
}

enum MapSearchSource { building, poi }

// -----------------------------------------------------------------------------
// Category definitions
// -----------------------------------------------------------------------------

class _SearchCategory {
  final String label;
  final IconData icon;
  final String poiClassValue;

  const _SearchCategory({
    required this.label,
    required this.icon,
    required this.poiClassValue,
  });
}

const _categories = [
  _SearchCategory(
    label: 'Parking',
    icon: Icons.local_parking,
    poiClassValue: 'Parking',
  ),
  _SearchCategory(
    label: 'Dining',
    icon: Icons.restaurant,
    poiClassValue: 'Dining and Beverage',
  ),
  _SearchCategory(
    label: 'Recreation',
    icon: Icons.fitness_center,
    poiClassValue: 'Athletic Facilities',
  ),
  _SearchCategory(
    label: 'Transit',
    icon: Icons.directions_bus,
    poiClassValue: 'Transit',
  ),
];

// -----------------------------------------------------------------------------
// Slide-over header delegate
// -----------------------------------------------------------------------------

class _SlideOverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  final Color backgroundColor;

  _SlideOverHeaderDelegate({
    required this.child,
    required this.height,
    required this.backgroundColor,
  });

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: shrinkOffset == 0
            ? const BorderRadius.vertical(top: Radius.circular(16))
            : null,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SlideOverHeaderDelegate oldDelegate) {
    return child != oldDelegate.child ||
        height != oldDelegate.height ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

// -----------------------------------------------------------------------------
// Widget
// -----------------------------------------------------------------------------

class EsriMap extends StatefulWidget {
  const EsriMap({Key? key}) : super(key: key);

  @override
  State<EsriMap> createState() => _EsriMapState();
}

class _EsriMapState extends State<EsriMap> with AutomaticKeepAliveClientMixin {
  final _mapViewController = ArcGISMapView.createController();
  late final ArcGISMap _map;
  final _graphicsOverlay = GraphicsOverlay();
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  // Slide-over controllers
  final _categorySheetController = DraggableScrollableController();
  final _detailSheetController = DraggableScrollableController();

  // Service endpoints
  static const _lambdaUrl = "https://i0slpyw2gb.execute-api.us-west-2.amazonaws.com/default/ArcGIS-Map";

  // SharedPreferences key for recent searches
  static const _recentSearchesKey = 'esri_map_recent_searches';
  static const _maxRecentSearches = 5;

  // Search state
  List<MapSearchResult> _searchResults = [];
  List<String> _allPoiClasses = [];        // all distinct Class values from the server
  List<String> _matchingPoiClasses = [];   // live-filtered subset while typing
  bool _showResults = false;
  bool _isSearching = false;
  bool _showSuggestions = false;

  // Recent searches
  List<MapSearchResult> _recentSearches = [];

  // Detail slide-over state
  MapSearchResult? _selectedResult;
  MapSearchResult? _lastSelectedResult;

  // Results currently plotted as pins on the map (from category search)
  List<MapSearchResult> _mappedResults = [];

  // Full unfiltered result set for the active category (used by "See All")
  List<MapSearchResult> _allCategoryResults = [];

  // Whether to show the "See All" pill button
  bool _showSeeAll = false;

  // Whether to show the full category list panel
  bool _showCategoryList = false;

  // The active category (for display in the "See All" label)
  _SearchCategory? _activeCategory;

  // Location display
  final _locationDataSource = SystemLocationDataSource();
  bool _locationStarted = false;

  // Routing
  final _routeGraphicsOverlay = GraphicsOverlay();
  bool _isRouting = false;
  bool _hasRoute = false;
  Envelope? _routePaddedExtent;
  bool _routeFailed = false;
  String _travelMode = 'Walking';
  double _routeTravelTimeMinutes = 0;
  List<DirectionManeuver> _routeManeuvers = [];
  bool _showRouteFields = false;
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _fromFocusNode = FocusNode();
  final _toFocusNode = FocusNode();
  String? _activeRouteField;
  (double, double)? _fromLatLng;
  MapSearchResult? _routeDestination;

  // Basemap switcher
  BasemapType _currentBasemapType = BasemapType.defaultMap;
  final Map<BasemapType, Basemap> _basemaps = {};
  bool _showLayersPanel = false;

  // Operational layers
  bool _showCampusDistricts = false;
  ArcGISMapImageLayer? _campusDistrictsLayer;
  bool _showConstruction = false;
  ArcGISMapImageLayer? _constructionLayer;
  bool _loadingConstruction = false;
  bool _showAssemblyAreas = false;
  ArcGISMapImageLayer? _assemblyAreasLayer;
  bool _loadingAssemblyAreas = false;
  bool _showTransitLayer = false;
  FeatureLayer? _transitShuttlesLayer;
  FeatureLayer? _transitRoutesLayer;
  bool _loadingTransitLayer = false;
  Timer? _transitRefreshTimer;

  // Compass
  double _mapRotation = 0.0;
  StreamSubscription<void>? _viewpointChangedSubscription;

  final _mapReadyCompleter = Completer<void>();

  // Scene mode: 'Default' | '3D Building' | 'Drone View'
  String _sceneMode = 'Default';
  EsriSceneWidget? _scene3DWidget;
  EsriSceneWidget? _sceneDroneWidget;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initMap();
    _loadRecentSearches();
    _fetchAllPoiClasses();
    _focusNode.addListener(_onFocusChanged);
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
    _transitRefreshTimer?.cancel();
    _viewpointChangedSubscription?.cancel();
    super.dispose();
  }

  void _setupAgeAuthChallengeHandler() {
    ArcGISEnvironment
        .authenticationManager
        .arcGISAuthenticationChallengeHandler = _AgeAuthChallengeHandler(_callLambda);
  }

  void _initMap() {
    for (final type in BasemapType.values) {
      _basemaps[type] = buildBasemap(type);
    }

    _map = ArcGISMap.withBasemap(_basemaps[_currentBasemapType]!);
    _map.initialViewpoint = Viewpoint.fromCenter(
      ArcGISPoint(
        x: -117.2340,
        y: 32.8801,
        spatialReference: SpatialReference.wgs84,
      ),
      scale: 24000,
    );
    _mapReadyCompleter.complete();
  }

  void _onMapViewReady() async {
    await _mapReadyCompleter.future;
    _setupAgeAuthChallengeHandler();
    _mapViewController.arcGISMap = _map;
    _mapViewController.interactionOptions.rotateEnabled = true;
    if (!_mapViewController.graphicsOverlays.contains(_graphicsOverlay)) {
      _mapViewController.graphicsOverlays.add(_graphicsOverlay);
    }
    if (!_mapViewController.graphicsOverlays.contains(_routeGraphicsOverlay)) {
      _mapViewController.graphicsOverlays.add(_routeGraphicsOverlay);
    }

    // Wire up location display — blue dot, no auto-pan on start
    _mapViewController.locationDisplay.dataSource = _locationDataSource;
    _mapViewController.locationDisplay.autoPanMode =
        LocationDisplayAutoPanMode.off;

    _startLocationDisplay();
    _preloadAlternateBasemaps();

    _viewpointChangedSubscription =
        _mapViewController.onViewpointChanged.listen((_) {
      final vp = _mapViewController.getCurrentViewpoint(
        ViewpointType.centerAndScale,
      );
      if (vp != null && mounted) {
        setState(() => _mapRotation = vp.rotation);
      }
    });
  }

  void _snapToNorth() {
    _mapViewController.setViewpointRotation(angleDegrees: 0);
  }

  ///Loads metadata and style sheets; tile content still fetches lazily once the basemap is applied to the MapView.
  void _preloadAlternateBasemaps() {
    for (final entry in _basemaps.entries) {
      if (entry.key == _currentBasemapType) continue;
      entry.value.load().catchError((Object e) {
        debugPrint('Failed to preload basemap ${entry.key}: $e');
      });
    }
  }

  void _switchBasemap(BasemapType newType) {
    if (newType == _currentBasemapType) return;
    final newBasemap = _basemaps[newType];
    if (newBasemap == null) return;

    // Setting Map.basemap swaps the underlying layers without changing the current Viewpoint, so the user's view frame is preserved.
    setState(() {
      _map.basemap = newBasemap;
      _currentBasemapType = newType;
    });
  }

  void _setSceneMode(String mode) {
    if (mode == _sceneMode) return;
    setState(() {
      _sceneMode = mode;
      if (mode != 'Default') _showLayersPanel = false;
      if (mode == '3D Building' && _scene3DWidget == null) {
        _scene3DWidget = const EsriSceneWidget(
          portalUri: 'https://ucsd-admin.maps.arcgis.com',
          itemId: 'a0a255ad97534836aa9e159d4a546bfc',
        );
      } else if (mode == 'Drone View' && _sceneDroneWidget == null) {
        _sceneDroneWidget = const EsriSceneWidget(
          portalUri: 'https://admin-enterprise-gis.ucsd.edu/portal',
          itemId: '0ffe293479844ce49ff5c30ffc0a0b67',
        );
      }
    });
  }

  void _toggleTransitLayer() async {
    if (_showTransitLayer) {
      _transitRefreshTimer?.cancel();
      _transitRefreshTimer = null;
      if (_transitShuttlesLayer != null) {
        _map.operationalLayers.remove(_transitShuttlesLayer!);
      }
      if (_transitRoutesLayer != null) {
        _map.operationalLayers.remove(_transitRoutesLayer!);
      }
      setState(() => _showTransitLayer = false);
    } else {
      setState(() => _loadingTransitLayer = true);
      if (_transitRoutesLayer == null) {
        _transitRoutesLayer = FeatureLayer.withFeatureTable(
          ServiceFeatureTable.withUri(Uri.parse(
            'https://services9.arcgis.com/mXNwDpiENQiMIzRv/arcgis/rest/services/'
            'Triton_Transit_Route_Lines/FeatureServer/0',
          )),
        );
      }
      if (_transitShuttlesLayer == null) {
        _transitShuttlesLayer = FeatureLayer.withFeatureTable(
          ServiceFeatureTable.withUri(Uri.parse(
            'https://services9.arcgis.com/mXNwDpiENQiMIzRv/arcgis/rest/services/'
            'Triton_Transit_Shuttle_Positions/FeatureServer/0',
          )),
        );
      }
      _map.operationalLayers.add(_transitRoutesLayer!);
      _map.operationalLayers.add(_transitShuttlesLayer!);
      try {
        await Future.wait([
          _transitRoutesLayer!.load(),
          _transitShuttlesLayer!.load(),
        ]);
      } catch (e) {
        debugPrint('Transit layer load error: $e');
      }
      setState(() {
        _showTransitLayer = true;
        _loadingTransitLayer = false;
      });
      _transitRefreshTimer = Timer.periodic(
        const Duration(seconds: 15),
        (_) async {
          if (!mounted || _transitShuttlesLayer == null) return;
          _map.operationalLayers.remove(_transitShuttlesLayer!);
          _transitShuttlesLayer = FeatureLayer.withFeatureTable(
            ServiceFeatureTable.withUri(Uri.parse(
              'https://services9.arcgis.com/mXNwDpiENQiMIzRv/arcgis/rest/services/'
              'Triton_Transit_Shuttle_Positions/FeatureServer/0',
            )),
          );
          _map.operationalLayers.add(_transitShuttlesLayer!);
          try {
            await _transitShuttlesLayer!.load();
          } catch (e) {
            debugPrint('Transit shuttle refresh error: $e');
          }
        },
      );
    }
  }

  void _toggleCampusDistricts() {
    if (_showCampusDistricts) {
      if (_campusDistrictsLayer != null) {
        _map.operationalLayers.remove(_campusDistrictsLayer!);
      }
      setState(() => _showCampusDistricts = false);
    } else {
        if (_campusDistrictsLayer == null) {
          _campusDistrictsLayer = ArcGISMapImageLayer.withUri(Uri.parse(
            'https://admin-enterprise-gis.ucsd.edu/server/rest/services/'
            'AdministrationServices/Areas_and_Boundaries/MapServer',
        ));
        // Show only sublayer 4 (Campus Districts)
        for (final sublayer in _campusDistrictsLayer!.mapImageSublayers) {
          sublayer.isVisible = sublayer.id == 4;
        }
      }
      _map.operationalLayers.add(_campusDistrictsLayer!);
      setState(() => _showCampusDistricts = true);
    }
  }

  void _toggleConstruction() async {
    if (_showConstruction) {
      if (_constructionLayer != null) {
        _map.operationalLayers.remove(_constructionLayer!);
      }
      setState(() => _showConstruction = false);
    } else {
      setState(() => _loadingConstruction = true);
      if (_constructionLayer == null) {
        _constructionLayer = ArcGISMapImageLayer.withUri(Uri.parse(
          'https://admin-enterprise-gis.ucsd.edu/server/rest/services/'
          'Construction/Construction_Alert_Approved/MapServer',
        ));
      }
      _map.operationalLayers.add(_constructionLayer!);
      try {
        await _constructionLayer!.load();
      } catch (e) {
        debugPrint('Construction layer load error: $e');
      }
      setState(() {
        _showConstruction = true;
        _loadingConstruction = false;
      });
    }
  }

  void _toggleAssemblyAreas() async {
    if (_showAssemblyAreas) {
      if (_assemblyAreasLayer != null) {
        _map.operationalLayers.remove(_assemblyAreasLayer!);
      }
      setState(() => _showAssemblyAreas = false);
    } else {
      setState(() => _loadingAssemblyAreas = true);
      if (_assemblyAreasLayer == null) {
        _assemblyAreasLayer = ArcGISMapImageLayer.withUri(Uri.parse(
          // TODO: replace with the real AGE assembly areas layer URL
          'https://admin-enterprise-gis.ucsd.edu/server/rest/services/'
          'CampusServices/Assembly_Areas/MapServer',
        ));
      }
      _map.operationalLayers.add(_assemblyAreasLayer!);
      try {
        await _assemblyAreasLayer!.load();
      } catch (e) {
        debugPrint('Assembly areas layer load error: $e');
      }
      setState(() {
        _showAssemblyAreas = true;
        _loadingAssemblyAreas = false;
      });
    }
  }

  Future<void> _startLocationDisplay() async {
    try {
      await _locationDataSource.start();
      setState(() => _locationStarted = true);
    } on ArcGISException catch (e) {
      debugPrint('Location error: ${e.message}');
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _searchController.text.isEmpty) {
      setState(() {
        _showSuggestions = true;
        _showResults = false;
      });
    }
  }

  void _onFromFocusChanged() {
    if (_fromFocusNode.hasFocus) {
      setState(() {
        _activeRouteField = 'from';
        if (_fromController.text.isEmpty) {
          _showSuggestions = true;
          _showResults = false;
        }
      });
      if (_detailSheetController.isAttached) {
        _detailSheetController.animateTo(
          0.15,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _onToFocusChanged() {
    if (_toFocusNode.hasFocus) {
      setState(() {
        _activeRouteField = 'to';
        if (_toController.text.isEmpty) {
          _showSuggestions = true;
          _showResults = false;
        }
      });
      if (_detailSheetController.isAttached) {
        _detailSheetController.animateTo(
          0.15,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Recent searches persistence
  // ---------------------------------------------------------------------------

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_recentSearchesKey);
    if (jsonStr != null) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        setState(() {
          _recentSearches = list
              .map((e) =>
                  MapSearchResult.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      } catch (_) {
        // ignore corrupted data
      }
    }
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr =
        jsonEncode(_recentSearches.map((r) => r.toJson()).toList());
    await prefs.setString(_recentSearchesKey, jsonStr);
  }

  void _addToRecentSearches(MapSearchResult result) {
    // Remove duplicate if exists (match by name + source)
    _recentSearches.removeWhere(
        (r) => r.name == result.name && r.source == result.source);
    // Insert at front
    _recentSearches.insert(0, result);
    // Trim to max
    if (_recentSearches.length > _maxRecentSearches) {
      _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
    }
    _saveRecentSearches();
  }

  void _removeFromRecentSearches(int index) {
    setState(() {
      _recentSearches.removeAt(index);
    });
    _saveRecentSearches();
  }

  // ---------------------------------------------------------------------------
  // Query helpers
  // ---------------------------------------------------------------------------

  /// POST to the Lambda map handler.
  Future<Map<String, dynamic>> _callLambda(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse(_lambdaUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Lambda error ${response.statusCode}: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<MapSearchResult>> _queryBuildings(String query) async {
    final data = await _callLambda({'action': 'searchBuildings', 'query': query});
    return (data['results'] as List<dynamic>? ?? []).map<MapSearchResult>((r) {
      return MapSearchResult(
        name: r['name'] as String? ?? 'Unknown Building',
        subtitle: r['subtitle'] as String? ?? 'Building',
        latitude: (r['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (r['longitude'] as num?)?.toDouble() ?? 0.0,
        source: MapSearchSource.building,
        address: r['address'] as String? ?? '',
      );
    }).where((r) => r.latitude != 0.0 && r.longitude != 0.0).toList();
  }

  Future<void> _fetchAllPoiClasses() async {
    try {
      final data = await _callLambda({'action': 'fetchAllPoiClasses'});
      final classes = (data['classes'] as List<dynamic>? ?? [])
          .map((c) => c as String)
          .toList();
      setState(() => _allPoiClasses = classes);
    } catch (e) {
      debugPrint('Failed to fetch POI classes: $e');
    }
  }

  Future<List<MapSearchResult>> _queryPOIs(String query) async {
    final data = await _callLambda({'action': 'searchPOI', 'query': query});
    return _parsePOIResults(data);
  }

  Future<List<MapSearchResult>> _queryPOIsByClass(String classValue) async {
    final data = await _callLambda({
      'action': 'searchPOIByClass',
      'classValue': classValue,
      'maxResults': 100,
    });
    return _parsePOIResults(data);
  }

  List<MapSearchResult> _parsePOIResults(Map<String, dynamic> data) {
    return (data['results'] as List<dynamic>? ?? []).map<MapSearchResult>((r) {
      return MapSearchResult(
        name: r['name'] as String? ?? 'Unknown POI',
        subtitle: r['subtitle'] as String? ?? '',
        latitude: (r['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (r['longitude'] as num?)?.toDouble() ?? 0.0,
        source: MapSearchSource.poi,
        description: r['description'] as String? ?? '',
        websiteUrl: r['websiteUrl'] as String?,
      );
    }).where((r) => r.latitude != 0.0 && r.longitude != 0.0).toList();
  }

  // ---------------------------------------------------------------------------
  // Search actions
  // ---------------------------------------------------------------------------

  /// Text search: query both buildings and POIs in parallel.
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    // Recompute category matches on submit
    final q = query.toLowerCase();
    final matched = _allPoiClasses
        .where((c) => c.toLowerCase().contains(q))
        .toList();

    for (final cat in _categories) {
      if (cat.poiClassValue.toLowerCase().contains(q) &&
          !matched.contains(cat.poiClassValue)) {
        matched.insert(0, cat.poiClassValue);
      }
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
        _queryBuildings(query),
        _queryPOIs(query),
      ]);
      final merged = <MapSearchResult>[...results[0], ...results[1]];
      setState(() {
        _searchResults = merged;
        _isSearching = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  /// Returns the current visible map extent projected to WGS84.
  Envelope? _getViewportEnvelopeWGS84() {
    final vp = _mapViewController.getCurrentViewpoint(
      ViewpointType.boundingGeometry,
    );
    if (vp == null) return null;
    final geom = vp.targetGeometry;
    if (geom == null) return null;
    final projected = GeometryEngine.project(
      geom,
      outputSpatialReference: SpatialReference.wgs84,
    );
    return projected as Envelope?;
  }

  /// Filters a result list to only those within the current map viewport.
  /// Returns the full list unchanged if the envelope can't be determined.
  List<MapSearchResult> _filterToViewport(List<MapSearchResult> results) {
    final env = _getViewportEnvelopeWGS84();
    if (env == null) return results;
    return results.where((r) {
      return r.latitude  >= env.yMin &&
            r.latitude  <= env.yMax &&
            r.longitude >= env.xMin &&
            r.longitude <= env.xMax;
    }).toList();
  }

  /// distance in meters between two WGS84 points
  double _distanceMeters(
      double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  /// Returns the user's current WGS84 lat/lng, or null if unavailable.
  (double lat, double lng)? _getUserLatLng() {
    final pos = _mapViewController.locationDisplay.location?.position;
    if (pos == null) return null;
    final wgs = GeometryEngine.project(
      pos,
      outputSpatialReference: SpatialReference.wgs84,
    ) as ArcGISPoint?;
    if (wgs == null) return null;
    return (wgs.y, wgs.x);
  }

  /// Plot a list of results as pins on the map.
  void _plotResultsOnMap(List<MapSearchResult> results) {
    _graphicsOverlay.graphics.clear();
    _mappedResults = results;
    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      final point = ArcGISPoint(
        x: result.longitude,
        y: result.latitude,
        spatialReference: SpatialReference.wgs84,
      );
      final graphic = Graphic(
        geometry: point,
        symbol: SimpleMarkerSymbol(
          style: SimpleMarkerSymbolStyle.circle,
          color: Colors.red,
          size: 14,
        ),
      );
      // Store the list index so we can retrieve the result on tap
      graphic.attributes['resultIndex'] = i;
      _graphicsOverlay.graphics.add(graphic);
    }
  }

  /// Zoom the map to fit all mapped results, with padding.
  void _zoomToResults(List<MapSearchResult> results) {
    if (results.isEmpty) return;

    if (results.length == 1) {
      final r = results.first;
      _mapViewController.setViewpointAnimated(
        Viewpoint.fromCenter(
          ArcGISPoint(
            x: r.longitude,
            y: r.latitude,
            spatialReference: SpatialReference.wgs84,
          ),
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
    _mapViewController.setViewpointAnimated(
      Viewpoint.fromTargetExtent(envelope),
    );
  }

  /// Category search: query POIs filtered by Class.
  /// Category search: query POIs filtered by Class and plot all as map pins.
  Future<void> _performCategorySearch(_SearchCategory category) async {
    setState(() {
      _isSearching = true;
      _showResults = false;
      _showSuggestions = false;
      _selectedResult = null;
      _showSeeAll = false;
      _showCategoryList = false;
      _activeCategory = category;
      _searchController.text = category.label;
    });
    _focusNode.unfocus();
    _fromFocusNode.unfocus();
    _toFocusNode.unfocus();

    try {
      final allResults = await _queryPOIsByClass(category.poiClassValue);

      // Always plot ALL pins — no zoom, no viewport filtering.
      // The user pans/zooms freely to discover them.
      _plotResultsOnMap(allResults);

      setState(() {
        _allCategoryResults = allResults;
        // Show "Zoom to all" pill whenever there are results
        _showSeeAll = allResults.isNotEmpty;
        _isSearching = false;
      });
    } catch (e) {
      print('Category search error: $e');
      setState(() {
        _mappedResults = [];
        _allCategoryResults = [];
        _showSeeAll = false;
        _isSearching = false;
      });
    }
  }

  /// Triggers a category-style search from a raw POI class string.
  Future<void> _performClassSearch(String classValue) async {
    final category = _SearchCategory(
      label: _labelForClass(classValue),
      icon: _iconForClass(classValue),
      poiClassValue: classValue,
    );
    await _performCategorySearch(category);
  }

  /// Plots all results for the active category
  void _seeAllCategoryResults() {
    if (_allCategoryResults.isEmpty) return;
    _zoomToResults(_allCategoryResults);
    setState(() => _showSeeAll = false);
  }

  void _selectResult(MapSearchResult result) {
    // Handle result selection within route fields
    if (_showRouteFields && _activeRouteField != null) {
      if (_activeRouteField == 'from') {
        _fromController.text = result.name;
        _fromLatLng = (result.latitude, result.longitude);
        _graphicsOverlay.graphics.clear();
        setState(() {
          _showResults = false;
          _showSuggestions = false;
          _mappedResults = [];
          _allCategoryResults = [];
          _showSeeAll = false;
          _showCategoryList = false;
          _activeCategory = null;
        });
        _fromFocusNode.unfocus();
        // Re-solve route if we already have a destination
        if (_routeDestination != null) {
          _solveRoute(_routeDestination!, originLatLng: _fromLatLng);
        }
      } else if (_activeRouteField == 'to') {
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
          _showSeeAll = false;
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

    final point = ArcGISPoint(
      x: result.longitude,
      y: result.latitude,
      spatialReference: SpatialReference.wgs84,
    );

    final graphic = Graphic(
      geometry: point,
      symbol: SimpleMarkerSymbol(
        style: SimpleMarkerSymbolStyle.circle,
        color: result.source == MapSearchSource.building
            ? Colors.blue
            : Colors.red,
        size: 14,
      ),
    );
    _graphicsOverlay.graphics.add(graphic);

    _mapViewController.setViewpointAnimated(
      Viewpoint.fromCenter(point, scale: 5000),
    );

    setState(() {
      _showResults = false;
      _showSuggestions = false;
      _searchController.text = result.name;
      _selectedResult = result;
      _lastSelectedResult = result;
    });
    _focusNode.unfocus();

    // Save to recent searches
    _addToRecentSearches(result);
  }

  /// Called when the ArcGISMapView is tapped
  /// Identifies any graphic at the tap location and shows its detail panel
  Future<void> _onMapTap(Offset screenPoint) async {
    // Dismiss any open dropdowns first
    if (_showSuggestions || _showResults) {
      setState(() {
        _showSuggestions = false;
        _showResults = false;
      });
      _focusNode.unfocus();
      return;
    }

    // Only attempt identify when pins are on the map
    if (_mappedResults.isEmpty) {
      if (_selectedResult != null) _closeDetail();
      return;
    }

    try {
      final identifyResult = await _mapViewController.identifyGraphicsOverlay(
        _graphicsOverlay,
        screenPoint: screenPoint,
        tolerance: 12.0,
        maximumResults: 1,
      );

      if (identifyResult.graphics.isNotEmpty) {
        final tappedGraphic = identifyResult.graphics.first;
        final index = tappedGraphic.attributes['resultIndex'] as int?;
        if (index != null && index >= 0 && index < _mappedResults.length) {
          _selectResultFromPin(_mappedResults[index]);
        }
      } else {
        // Tapped empty space — close detail if open
        if (_selectedResult != null) _closeDetail();
      }
    } catch (e) {
      print('Identify error: $e');
    }
  }

  /// Select a result from a map pin tap
  /// keeps all existing category pins visible
  void _selectResultFromPin(MapSearchResult result) {
    // In routing mode, treat pin tap based on active route field
    if (_showRouteFields) {
      if (_activeRouteField == 'from') {
        _fromController.text = result.name;
        _fromLatLng = (result.latitude, result.longitude);
        _graphicsOverlay.graphics.clear();
        setState(() {
          _showResults = false;
          _showSuggestions = false;
          _mappedResults = [];
          _allCategoryResults = [];
          _showSeeAll = false;
          _showCategoryList = false;
          _activeCategory = null;
        });
        _fromFocusNode.unfocus();
        if (_routeDestination != null) {
          _solveRoute(_routeDestination!, originLatLng: _fromLatLng);
        }
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
          _showSeeAll = false;
          _showCategoryList = false;
          _activeCategory = null;
        });
        _toFocusNode.unfocus();
        _solveRoute(result, originLatLng: _fromLatLng);
      }
      _addToRecentSearches(result);
      return;
    }

    final point = ArcGISPoint(
      x: result.longitude,
      y: result.latitude,
      spatialReference: SpatialReference.wgs84,
    );

    _mapViewController.setViewpointAnimated(
      Viewpoint.fromCenter(point, scale: 5000),
    );

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
    setState(() {
      _selectedResult = null;
      // If a category search is active and not in routing mode, reopen the list view
      if (_allCategoryResults.isNotEmpty &&
          !_showRouteFields && !_hasRoute && !_routeFailed) {
        _showCategoryList = true;
      }
    });
  }

  void _reopenDetail() {
    if (_lastSelectedResult != null) {
      setState(() {
        _selectedResult = _lastSelectedResult;
      });
    }
  }

  void _recenterOnUser() {
    if (!_locationStarted) {
      _startLocationDisplay();
      return;
    }
    final loc = _mapViewController.locationDisplay.location;
    if (loc == null) return;

    // Briefly snap to recenter mode, then release back to free pan
    _mapViewController.locationDisplay.autoPanMode =
        LocationDisplayAutoPanMode.recenter;
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _mapViewController.locationDisplay.autoPanMode =
            LocationDisplayAutoPanMode.off;
      }
    });
  }

  void _recenterOnView() {
    if (_selectedResult != null) {
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
    } else if (_lastSelectedResult != null && _mappedResults.isEmpty) {
      // Single pin on map, slide-over closed
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
    } else if (_mappedResults.isNotEmpty) {
      // Category pins on map
      _zoomToResults(_mappedResults);
    } else {
      _mapViewController.setViewpointAnimated(
        Viewpoint.fromCenter(
          ArcGISPoint(
            x: -117.2340,
            y: 32.8801,
            spatialReference: SpatialReference.wgs84,
          ),
          scale: 24000,
        ),
      );
    }
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
      _showSeeAll = false;
      _showCategoryList = false;
      _activeCategory = null;
      _selectedResult = null;
      _lastSelectedResult = null;
      _activeRouteField = null;
      _fromLatLng = null;
      _routeDestination = null;
    });
  }

  Future<void> _launchWebsite(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ---------------------------------------------------------------------------
  // Routing
  // ---------------------------------------------------------------------------

/*   Future<void> _launchDirections(MapSearchResult result) async {                                                                
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${result.latitude},${result.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  } */

  static const _routeServiceUrl =
      'https://admin-enterprise-gis.ucsd.edu/server/rest/services/'
      'Wayfinding/Campus_Wayfinding_Network/NAServer/Route';

  Future<void> _solveRoute(MapSearchResult destination, {String? travelMode, (double, double)? originLatLng}) async {
    // Use provided origin or fall back to GPS
    final userLatLng = originLatLng ?? _getUserLatLng();
    if (userLatLng == null) {
      setState(() => _isRouting = false);
      return;
    }

    final mode = travelMode ?? _travelMode;

    setState(() {
      _isRouting = true;
      _routeFailed = false;
      _travelMode = mode;
    });

    try {
      await dotenv.load(fileName: ".env");
      final token = dotenv.env['ARCGIS_AGE_API_KEY'] ?? '';

      final routeTask = RouteTask.withUri(Uri.parse(_routeServiceUrl));
      routeTask.apiKey = token;
      await routeTask.load();

      final params = await routeTask.createDefaultParameters();
      params.returnDirections = true;
      final taskInfo = routeTask.getRouteTaskInfo();
      final matchingMode = taskInfo.travelModes
          .where((m) => m.name == mode)
          .firstOrNull;
      if (matchingMode != null) {
        params.travelMode = matchingMode;
      }

      final origin = Stop(ArcGISPoint(
        x: userLatLng.$2,
        y: userLatLng.$1,
        spatialReference: SpatialReference.wgs84,
      ));
      final dest = Stop(ArcGISPoint(
        x: destination.longitude,
        y: destination.latitude,
        spatialReference: SpatialReference.wgs84,
      ));
      params.setStops([origin, dest]);

      final result = await routeTask.solveRoute(params);
      if (result.routes.isEmpty) {
        setState(() {
          _isRouting = false;
          _routeFailed = true;
        });
        return;
      }

      final route = result.routes.first;
      _routeTravelTimeMinutes = route.totalTime;
      _routeManeuvers = route.directionManeuvers;

      final routeGeometry = route.routeGeometry;
      if (routeGeometry == null) {
        setState(() {
          _isRouting = false;
          _routeFailed = true;
        });
        return;
      }

      _routeGraphicsOverlay.graphics.clear();
      final routeGraphic = Graphic(
        geometry: routeGeometry,
        symbol: SimpleLineSymbol(
          style: SimpleLineSymbolStyle.solid,
          color: Colors.blue,
          width: 4,
        ),
      );
      _routeGraphicsOverlay.graphics.add(routeGraphic);

      // End point marker
      final whiteOutline = SimpleLineSymbol(
        style: SimpleLineSymbolStyle.solid,
        color: Colors.white,
        width: 2,
      );
      _routeGraphicsOverlay.graphics.add(Graphic(
        geometry: ArcGISPoint(
          x: destination.longitude,
          y: destination.latitude,
          spatialReference: SpatialReference.wgs84,
        ),
        symbol: SimpleMarkerSymbol(
          style: SimpleMarkerSymbolStyle.circle,
          color: Colors.red,
          size: 12,
        )..outline = whiteOutline,
      ));

      // Start point marker (only when origin is not GPS)
      if (originLatLng != null) {
        _routeGraphicsOverlay.graphics.add(Graphic(
          geometry: ArcGISPoint(
            x: originLatLng.$2,
            y: originLatLng.$1,
            spatialReference: SpatialReference.wgs84,
          ),
          symbol: SimpleMarkerSymbol(
            style: SimpleMarkerSymbolStyle.circle,
            color: Colors.blue,
            size: 12,
          )..outline = whiteOutline,
        ));
      }

      // Zoom to the route extent with extra bottom padding so the line
      // stays centred in the visible map area above the detail slide-over.
      final extent = routeGeometry.extent;
      final dx = extent.width * 0.2;
      final dyTop = extent.height * 0.5;
      final dyBottom = extent.height * 0.75;
      final paddedExtent = Envelope.fromXY(
        xMin: extent.xMin - dx,
        yMin: extent.yMin - dyBottom,
        xMax: extent.xMax + dx,
        yMax: extent.yMax + dyTop,
        spatialReference: extent.spatialReference,
      );
      _routePaddedExtent = paddedExtent;
      _mapViewController.setViewpointAnimated(
        Viewpoint.fromTargetExtent(paddedExtent),
      );

      _graphicsOverlay.graphics.clear();
      _mappedResults = [];
      _allCategoryResults = [];

      setState(() {
        _isRouting = false;
        _hasRoute = true;
        _showSeeAll = false;
        _showCategoryList = false;
        _activeCategory = null;
      });
    } catch (e) {
      debugPrint('Route solve error: $e');
      setState(() {
        _isRouting = false;
        _routeFailed = true;
      });
    }
  }

  void _clearRoute() {
    _routeGraphicsOverlay.graphics.clear();
    _fromController.clear();
    _toController.clear();
    _routePaddedExtent = null;

    // Re-add destination pin and center on it if a result is still selected
    final destination = _selectedResult;
    if (destination != null) {
      final point = ArcGISPoint(
        x: destination.longitude,
        y: destination.latitude,
        spatialReference: SpatialReference.wgs84,
      );
      _graphicsOverlay.graphics.clear();
      _graphicsOverlay.graphics.add(Graphic(
        geometry: point,
        symbol: SimpleMarkerSymbol(
          style: SimpleMarkerSymbolStyle.circle,
          color: destination.source == MapSearchSource.building
              ? Colors.blue
              : Colors.red,
          size: 14,
        ),
      ));
      _mapViewController.setViewpointAnimated(
        Viewpoint.fromCenter(point, scale: 5000),
      );
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

  IconData _iconForResult(MapSearchResult result) {
    return result.source == MapSearchSource.building
        ? Icons.business
        : Icons.place;
  }

  /// Returns the icon for a POI class — uses the hardcoded category icon if one
  /// exists, otherwise falls back to a generic place icon.
  IconData _iconForClass(String classValue) {
    return _categories
        .firstWhere(
          (c) => c.poiClassValue.toLowerCase() == classValue.toLowerCase(),
          orElse: () => const _SearchCategory(
              label: '', icon: Icons.place, poiClassValue: ''),
        )
        .icon;
  }

  /// Converts a raw class value like "Food and Beverage" into a display label.
  /// Uses the hardcoded category label if available, otherwise returns as-is.
  String _labelForClass(String classValue) {
    final match = _categories.where(
        (c) => c.poiClassValue.toLowerCase() == classValue.toLowerCase());
    return match.isNotEmpty ? match.first.label : classValue;
  }

  // ---------------------------------------------------------------------------
  // Suggestions panel (categories + recent searches)
  // ---------------------------------------------------------------------------

  Widget _buildSuggestionsPanel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[850] : Colors.white;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      color: bgColor,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category section header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Suggested',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 12),

            // Category icons row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _categories
                    .map((cat) => _buildCategoryChip(context, cat))
                    .toList(),
              ),
            ),

            // Recent searches section
            if (_recentSearches.isNotEmpty) ...[
              SizedBox(height: 16),
              Divider(height: 1),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recently viewed',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(height: 4),
              ...List.generate(_recentSearches.length, (index) {
                final recent = _recentSearches[index];
                return ListTile(
                  splashColor: Colors.transparent,
                  dense: true,
                  leading: Icon(
                    Icons.history,
                    size: 20,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  title: Text(
                    recent.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: GestureDetector(
                    onTap: () => _removeFromRecentSearches(index),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                    ),
                  ),
                  onTap: () => _selectResult(recent),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, _SearchCategory category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colors = {
      'Parking':             Color(0xFFCCF4F7),
      'Dining and Beverage': Color(0xFFF9DDEF),
      'Athletic Facilities': Color(0xFFFCF9CC),
      'Transit':             Color(0xFFFFEDD1),
    };
    final iconColors = {
      'Parking':             Colors.black,
      'Dining and Beverage': Colors.black,
      'Athletic Facilities': Colors.black,
      'Transit':             Colors.black,
    };

    return GestureDetector(
      onTap: () => _performCategorySearch(category),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors[category.poiClassValue] ?? (isDark ? Colors.grey[800]! : Colors.grey[100]!),
              shape: BoxShape.circle,
            ),
            child: Icon(
              category.icon,
              size: 24,
              color: iconColors[category.poiClassValue] ?? (isDark ? Colors.white70 : Colors.grey[700]),
            ),
          ),
          SizedBox(height: 6),
          Text(
            category.label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeeAllButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = _allCategoryResults.length;

    return GestureDetector(
      onTap: _seeAllCategoryResults,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.layers_outlined,
              size: 16,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              'See all $total results',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.grey[900],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Map interaction → collapse slideover
  // ---------------------------------------------------------------------------

  void _onMapPointerDown(PointerDownEvent _) {
    // Close layers panel when user touches the map
    if (_showLayersPanel) {
      setState(() => _showLayersPanel = false);
      return;
    }
    // Collapse whichever sheet is active to the minimum snap
    if (_showCategoryList && _selectedResult == null) {
      if (_categorySheetController.isAttached) {
        _categorySheetController.animateTo(
          0.15,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }
    if (_selectedResult != null) {
      if (_detailSheetController.isAttached) {
        _detailSheetController.animateTo(
          0.15,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Shared slide-over template
  // ---------------------------------------------------------------------------

  /// Builds a consistent DraggableScrollableSheet with a pinned header.
  /// [headerTitle] and [headerIcon] are shown in the header row.
  /// [onClose] is called when the X button is tapped.
  /// [trailing] is an optional widget shown before the close button (e.g. "Search here").
  /// [sliverBody] is the scrollable content below the header.
  static const _slideOverHeaderHeight = 80.0;

  Widget _buildSlideOverContent({
    required BuildContext context,
    required ScrollController scrollController,
    required String headerTitle,
    IconData? headerIcon,
    required VoidCallback onClose,
    Widget? trailing,
    required List<Widget> sliverBody,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[900]! : Colors.white;

    return Material(
      elevation: 8,
      color: bgColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _SlideOverHeaderDelegate(
              height: _slideOverHeaderHeight,
              backgroundColor: bgColor,
              child: Column(
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 4),
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                    child: Row(
                      children: [
                        if (headerIcon != null) ...[
                          Icon(
                            headerIcon,
                            size: 18,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            headerTitle,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.grey[900],
                            ),
                          ),
                        ),
                        if (trailing != null) trailing!,
                        GestureDetector(
                          onTap: onClose,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  isDark ? Colors.grey[800] : Colors.grey[200],
                            ),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: isDark ? Colors.white70 : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Divider below header
          SliverToBoxAdapter(
            child: Divider(height: 1),
          ),
          ...sliverBody,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // List view
  // ---------------------------------------------------------------------------
  Widget _buildCategoryListPanel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = _activeCategory?.label ?? 'Results';

    final viewport = _filterToViewport(_allCategoryResults);
    final userPos = _getUserLatLng();
    final results = List<MapSearchResult>.from(viewport);
    if (userPos != null) {
      results.sort((a, b) =>
          _distanceMeters(userPos.$1, userPos.$2, a.latitude, a.longitude)
              .compareTo(
                  _distanceMeters(
                      userPos.$1, userPos.$2, b.latitude, b.longitude)));
    }

    // Content-aware sizing: estimate content height as fraction of screen
    final screenHeight = MediaQuery.of(context).size.height;
    // Each list tile ~56px + header ~80px + divider
    final contentHeight =
        _slideOverHeaderHeight + (results.length * 56.0).clamp(56.0, 600.0);
    final contentFraction = (contentHeight / screenHeight).clamp(0.15, 0.80);
    final initialSize =
        contentFraction < 0.45 ? contentFraction : 0.45;
    final maxSize = contentFraction < 0.80 ? contentFraction.clamp(0.45, 0.80) : 0.80;
    // Snap sizes must be strictly increasing and within [min, max]
    final snaps = <double>[0.15];
    if (initialSize > 0.15 + 0.01) snaps.add(initialSize);

    return DraggableScrollableSheet(
      controller: _categorySheetController,
      initialChildSize: initialSize,
      minChildSize: 0.15,
      maxChildSize: maxSize,
      snap: true,
      snapSizes: snaps,
      builder: (context, scrollController) {
        final headerTitle = results.isEmpty
            ? '$label - None in view'
            : '$label - ${results.length} in view';

        return _buildSlideOverContent(
          context: context,
          scrollController: scrollController,
          headerTitle: headerTitle,
          headerIcon: _activeCategory?.icon ?? Icons.place,
          onClose: () => setState(() => _showCategoryList = false),
          trailing: TextButton.icon(
            icon: Icon(
              Icons.refresh,
              size: 16,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
            label: Text(
              'Search here',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
            ),
            style: TextButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            onPressed: () => setState(() {}),
          ),
          sliverBody: results.isEmpty
              ? [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_off,
                              size: 32,
                              color: isDark
                                  ? Colors.grey[600]
                                  : Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'No $label in current view.\nPan the map, then tap "Search here" to refresh.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              : [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final r = results[index];
                        final dist = userPos != null
                            ? _distanceMeters(userPos.$1, userPos.$2,
                                r.latitude, r.longitude)
                            : null;
                        final distLabel = dist == null
                            ? null
                            : dist < 1000
                                ? '${dist.round()} m away'
                                : '${(dist / 1000).toStringAsFixed(1)} km away';

                        return Column(
                          children: [
                            ListTile(
                              splashColor: Colors.transparent,
                              leading: Icon(
                                _iconForResult(r),
                                size: 20,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              title: Text(
                                r.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: distLabel != null
                                  ? Text(distLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ))
                                  : (r.subtitle.isNotEmpty
                                      ? Text(r.subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style:
                                              const TextStyle(fontSize: 12))
                                      : null),
                              dense: true,
                              onTap: () => _selectResultFromPin(r),
                            ),
                            if (index < results.length - 1)
                              const Divider(height: 1),
                          ],
                        );
                      },
                      childCount: results.length,
                    ),
                  ),
                ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Detail slide-over
  // ---------------------------------------------------------------------------

  Widget _buildDetailSlideOver(BuildContext context, MapSearchResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRouting = _showRouteFields || _hasRoute || _routeFailed;

    final detailText = result.source == MapSearchSource.building
        ? result.address
        : result.description;
    final categoryLabel = result.source == MapSearchSource.building
        ? 'Building'
        : result.subtitle;

    // Content-aware sizing: estimate how tall the detail content is
    final screenHeight = MediaQuery.of(context).size.height;
    // header ~80 + name ~30 + detail ~20 + buttons ~48 + padding ~40
    double contentEst = _slideOverHeaderHeight + 30 + 48 + 40;
    if (detailText.isNotEmpty) contentEst += 60;
    if (_hasRoute && _routeManeuvers.isNotEmpty) contentEst += _routeManeuvers.length * 52.0;
    final contentFraction = (contentEst / screenHeight).clamp(0.15, 0.80);
    final initialSize =
        _hasRoute ? 0.35 : (contentFraction < 0.30 ? contentFraction : 0.30);
    final maxSize = _hasRoute
        ? 0.80
        : (contentFraction < 0.80 ? contentFraction.clamp(0.30, 0.80) : 0.80);
    // Snap sizes must be strictly increasing and within [min, max]
    final snaps = <double>[0.15];
    if (initialSize > 0.15 + 0.01) snaps.add(initialSize);

    return DraggableScrollableSheet(
      controller: _detailSheetController,
      initialChildSize: initialSize,
      minChildSize: 0.15,
      maxChildSize: maxSize,
      snap: true,
      snapSizes: snaps,
      builder: (context, scrollController) {
        return _buildSlideOverContent(
          context: context,
          scrollController: scrollController,
          headerTitle: isRouting
              ? 'Directions to ${result.name}'
              : result.name,
          headerIcon: _iconForResult(result),
          onClose: isRouting ? _clearRoute : _closeDetail,
          sliverBody: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category label (hidden in routing mode)
                    if (!isRouting)
                      Text(
                        categoryLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),

                    // Detail text (hidden in routing mode)
                    if (!isRouting && detailText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        detailText,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (!isRouting) const SizedBox(height: 16),

                    // Action buttons
                    if (_routeFailed) ...[
                      Text(
                        'No route available from your current location.',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _launchWebsite(
                            'https://www.google.com/maps/dir/?api=1'
                            '&destination=${_routeDestination?.latitude ?? result.latitude},${_routeDestination?.longitude ?? result.longitude}'
                            '&travelmode=walking'
                            '${_fromLatLng != null ? '&origin=${_fromLatLng!.$1},${_fromLatLng!.$2}' : ''}',
                          ),
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: const Text('Navigate in Google Maps'),
                          style: FilledButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ] else if (_hasRoute) ...[
                      // Travel time
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 18,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _routeTravelTimeMinutes < 1
                                ? '< 1 min'
                                : '${_routeTravelTimeMinutes.ceil()} min',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.grey[900],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Travel mode toggle chips
                      Row(
                        children: [
                          for (final mode in ['Walking', 'Accessible']) ...[
                            if (mode != 'Walking') const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _isRouting || mode == _travelMode
                                  ? null
                                  : () => _solveRoute(result, travelMode: mode, originLatLng: _fromLatLng),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: mode == _travelMode
                                      ? (isDark
                                          ? Colors.white
                                          : Colors.grey[900])
                                      : (isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[100]),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      mode == 'Walking'
                                          ? Icons.directions_walk
                                          : Icons.accessible,
                                      size: 16,
                                      color: mode == _travelMode
                                          ? (isDark
                                              ? Colors.grey[900]
                                              : Colors.white)
                                          : (isDark
                                              ? Colors.white70
                                              : Colors.grey[700]),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      mode,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: mode == _travelMode
                                            ? (isDark
                                                ? Colors.grey[900]
                                                : Colors.white)
                                            : (isDark
                                                ? Colors.white70
                                                : Colors.grey[700]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Navigate in Google Maps button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _launchWebsite(
                            'https://www.google.com/maps/dir/?api=1'
                            '&destination=${_routeDestination?.latitude ?? result.latitude},${_routeDestination?.longitude ?? result.longitude}'
                            '&travelmode=walking'
                            '${_fromLatLng != null ? '&origin=${_fromLatLng!.$1},${_fromLatLng!.$2}' : ''}',
                          ),
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: const Text('Navigate in Google Maps'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark
                                ? const Color(0xFFFFCD00)
                                : null,
                            side: isDark
                                ? const BorderSide(
                                    color: Color(0xFFFFCD00))
                                : null,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ] else
                      Row(
                        children: [
                          if (result.websiteUrl != null) ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _launchWebsite(result.websiteUrl!),
                                icon: const Icon(Icons.language, size: 18),
                                label: const Text('View website'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark
                                      ? const Color(0xFFFFCD00)
                                      : null,
                                  side: isDark
                                      ? const BorderSide(
                                          color: Color(0xFFFFCD00))
                                      : null,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _isRouting
                                  ? null
                                  : () {
                                      final gps = _getUserLatLng();
                                      _fromController.text =
                                          gps != null ? 'My Location' : '';
                                      _toController.text = result.name;
                                      _routeDestination = result;
                                      _graphicsOverlay.graphics.clear();
                                      setState(() {
                                        _showRouteFields = true;
                                        _mappedResults = [];
                                        _allCategoryResults = [];
                                        _showSeeAll = false;
                                        _showCategoryList = false;
                                        _activeCategory = null;
                                      });
                                      _solveRoute(result);
                                    },
                              icon: _isRouting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.directions, size: 18),
                              label: Text(
                                  _isRouting ? 'Routing...' : 'Get Directions'),
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            // Direction maneuver steps (when route is active)
            if (_hasRoute && _routeManeuvers.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final step = _routeManeuvers[index];
                    final distMeters = step.length;
                    final distLabel = distMeters < 1000
                        ? '${distMeters.round()} m'
                        : '${(distMeters / 1000).toStringAsFixed(1)} km';
                    return Column(
                      children: [
                        if (index == 0) const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.subdirectory_arrow_right,
                            size: 20,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          title: Text(
                            step.directionText,
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: distMeters > 0
                              ? Text(
                                  distLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[500],
                                  ),
                                )
                              : null,
                          dense: true,
                        ),
                        if (index < _routeManeuvers.length - 1)
                          const Divider(height: 1),
                      ],
                    );
                  },
                  childCount: _routeManeuvers.length,
                ),
              ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: Stack(
        children: [
          // Map — swaps between 2D ArcGISMapView and 3D ArcGISSceneView
          Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _sceneMode == '3D Building' ? 1
                       : _sceneMode == 'Drone View'  ? 2
                       : 0,
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

          // Floating search bar + dropdown — hidden in 3D/Drone View modes
          if (_sceneMode == 'Default')
          Positioned(
            top: 8,
            left: 12,
            right: 12,
            child: Column(
              children: [
                // Search bar / route fields
                if (_showRouteFields)
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    color: isDark ? Colors.grey[850] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left dot column
                          Padding(
                            padding: const EdgeInsets.only(left: 14),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle_outlined,
                                    size: 12,
                                    color: Colors.blue),
                                Container(
                                  width: 1.5,
                                  height: 24,
                                  color: isDark
                                      ? Colors.grey[600]
                                      : Colors.grey[300],
                                ),
                                Icon(Icons.circle,
                                    size: 12,
                                    color: Colors.red),
                              ],
                            ),
                          ),
                          // Text fields
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _fromController,
                                        focusNode: _fromFocusNode,
                                        style: const TextStyle(fontSize: 15),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 10),
                                          hintText: 'From',
                                          isDense: true,
                                        ),
                                        onTap: () {
                                          setState(() =>
                                              _activeRouteField = 'from');
                                        },
                                        onChanged: (text) {
                                          _fromLatLng = null;
                                          if (text.length >= 3) {
                                            _performSearch(text);
                                          } else if (text.isEmpty) {
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
                                      ),
                                    ),
                                    if (_fromController.text.isNotEmpty)
                                      SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(Icons.close,
                                              size: 16,
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.grey[600]),
                                          onPressed: () {
                                            _fromController.clear();
                                            _fromLatLng = null;
                                            setState(() =>
                                                _showSuggestions = true);
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                                Divider(height: 1, indent: 10, endIndent: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _toController,
                                        focusNode: _toFocusNode,
                                        style: const TextStyle(fontSize: 15),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 10),
                                          hintText: 'To',
                                          isDense: true,
                                        ),
                                        onTap: () {
                                          setState(() =>
                                              _activeRouteField = 'to');
                                        },
                                        onChanged: (text) {
                                          if (text.length >= 3) {
                                            _performSearch(text);
                                          } else if (text.isEmpty) {
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
                                      ),
                                    ),
                                    if (_toController.text.isNotEmpty)
                                      SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(Icons.close,
                                              size: 16,
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.grey[600]),
                                          onPressed: () {
                                            _toController.clear();
                                            setState(() =>
                                                _showSuggestions = true);
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Swap button
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.swap_vert,
                                  size: 20,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey[600]),
                              onPressed: () {
                                final tmpText = _fromController.text;
                                final tmpLatLng = _fromLatLng;
                                _fromController.text = _toController.text;
                                _toController.text = tmpText;
                                setState(() {
                                  _fromLatLng = _routeDestination != null
                                      ? (_routeDestination!.latitude, _routeDestination!.longitude)
                                      : null;
                                  _routeDestination = tmpLatLng != null
                                      ? MapSearchResult(
                                          name: tmpText,
                                          subtitle: '',
                                          latitude: tmpLatLng.$1,
                                          longitude: tmpLatLng.$2,
                                          source: MapSearchSource.building,
                                        )
                                      : null;
                                });
                                if (_routeDestination != null && _fromLatLng != null) {
                                  _solveRoute(_routeDestination!, originLatLng: _fromLatLng);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  )
                else
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    color: isDark ? Colors.grey[850] : Colors.white,
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Icon(
                            Icons.search,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            textInputAction: TextInputAction.search,
                            onSubmitted: _performSearch,
                            onChanged: (text) {
                              if (text.isEmpty) {
                                setState(() {
                                  _showResults = false;
                                  _searchResults = [];
                                  _matchingPoiClasses = [];
                                  _showSuggestions = _focusNode.hasFocus;
                                });
                              } else {
                                final q = text.toLowerCase();
                                // Match against server-fetched classes
                                final matched = _allPoiClasses
                                    .where((c) => c.toLowerCase().contains(q))
                                    .toList();

                                // Always include hardcoded category class values as a fallback
                                // so chips appear even if the server fetch is still in flight
                                for (final cat in _categories) {
                                  if (cat.poiClassValue.toLowerCase().contains(q) &&
                                      !matched.contains(cat.poiClassValue)) {
                                    matched.insert(0, cat.poiClassValue);
                                  }
                                }

                                setState(() {
                                  _showSuggestions = false;
                                  _matchingPoiClasses = matched;
                                });
                              }
                            },
                            onTap: () {
                              // Close detail panel when user taps search bar
                              if (_selectedResult != null) {
                                setState(() {
                                  _selectedResult = null;
                                });
                              }
                              // Show suggestions if text is empty
                              if (_searchController.text.isEmpty) {
                                setState(() {
                                  _showSuggestions = true;
                                  _showResults = false;
                                });
                              }
                            },
                            style: TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              hintText: 'Search buildings, places...',
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: _clearSearch,
                          ),
                      ],
                    ),
                  ),

                SizedBox(height: 4),

                // Suggestions panel (categories + recents)
                if (_showSuggestions && !_showResults)
                  _buildSuggestionsPanel(context),

                // Search results dropdown
                if (_showResults || (_matchingPoiClasses.isNotEmpty && _searchController.text.isNotEmpty && !_showSuggestions))
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    color: isDark ? Colors.grey[850] : Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Category matches (always at top) ──────────────────────────
                        if (_matchingPoiClasses.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                            child: Row(
                              children: [
                                Icon(Icons.category_outlined,
                                    size: 13,
                                    color: isDark ? Colors.grey[500] : Colors.grey[500]),
                                const SizedBox(width: 6),
                                Text(
                                  'CATEGORIES',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ..._matchingPoiClasses.map(
                            (classValue) => ListTile(
                              splashColor: Colors.transparent,
                              leading: Icon(
                                _iconForClass(classValue),
                                size: 20,
                                color: isDark ? Colors.white70 : Colors.grey[700],
                              ),
                              title: Text(_labelForClass(classValue)),
                              subtitle: Text(
                                classValue, // show raw class value as subtitle so user knows what they're getting
                                style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[500] : Colors.grey[500]),
                              ),
                              dense: true,
                              onTap: () => _performClassSearch(classValue),
                            ),
                          ),
                          if (_showResults && (_isSearching || _searchResults.isNotEmpty))
                            const Divider(height: 1),
                        ],

                        // ── POI / building results ─────────────────────────────────────
                        if (_showResults)
                          _isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              : _searchResults.isEmpty
                                  // Only show "no results" if there are also no category matches
                                  ? (_matchingPoiClasses.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text('No results found'),
                                      )
                                    : const SizedBox.shrink())
                                  : ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                                    ),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemCount: _searchResults.length,
                                      separatorBuilder: (_, __) => const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final result = _searchResults[index];
                                        return ListTile(
                                          splashColor: Colors.transparent,
                                          leading: Icon(_iconForResult(result)),
                                          title: Text(result.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                          subtitle: result.subtitle.isNotEmpty
                                              ? Text(result.subtitle,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis)
                                              : null,
                                          dense: true,
                                              onTap: () => _selectResult(result),
                                        );
                                      },
                                    ),
                                  ),

                      ],
                    ),
                  ),
              ],
            ),
          ),

          
          // "See All" pill — shown when category results are filtered to viewport
          if (_showSeeAll && _selectedResult == null)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: _buildSeeAllButton(context),
              ),
            ),
          // Bottom-right FAB cluster — hidden when keyboard or layers panel is active
          if (_selectedResult == null && !keyboardVisible && !_showLayersPanel)
            Positioned(
              right: 16,
              bottom: 32,
              child: EsriMapFabCluster(
                isDark: isDark,
                allCategoryResultsCount: _allCategoryResults.length,
                showCategoryList: _showCategoryList,
                hasLastSelectedResult: _lastSelectedResult != null,
                showRouteFields: _showRouteFields,
                hasRoute: _hasRoute,
                mapRotation: _mapRotation,
                onShowLayersPanel: () => setState(() => _showLayersPanel = true),
                onToggleCategoryList: () => setState(() => _showCategoryList = !_showCategoryList),
                onReopenDetail: _reopenDetail,
                onClearRoute: _clearRoute,
                onRecenterOnView: _recenterOnView,
                onRecenterOnUser: _recenterOnUser,
                onSnapToNorth: _snapToNorth,
              ),
            ),

          // Category list panel — shown when list button is toggled
          if (_showCategoryList && _selectedResult == null && _allCategoryResults.isNotEmpty)
            _buildCategoryListPanel(context),

          // Layers/display panel
          if (_showLayersPanel)
            EsriMapLayersPanel(
              currentBasemapType: _currentBasemapType,
              sceneMode: _sceneMode,
              showTransitLayer: _showTransitLayer,
              loadingTransitLayer: _loadingTransitLayer,
              showCampusDistricts: _showCampusDistricts,
              showConstruction: _showConstruction,
              loadingConstruction: _loadingConstruction,
              showAssemblyAreas: _showAssemblyAreas,
              loadingAssemblyAreas: _loadingAssemblyAreas,
              onSwitchBasemap: _switchBasemap,
              onSetSceneMode: _setSceneMode,
              onToggleTransitLayer: _toggleTransitLayer,
              onToggleCampusDistricts: _toggleCampusDistricts,
              onToggleConstruction: _toggleConstruction,
              onToggleAssemblyAreas: _toggleAssemblyAreas,
              onClose: () => setState(() => _showLayersPanel = false),
            ),
        ],
      ),
    );
  }
}

class _AgeAuthChallengeHandler implements ArcGISAuthenticationChallengeHandler {
  final Future<Map<String, dynamic>> Function(Map<String, dynamic>) callLambda;

  String? _cachedAgeToken;
  DateTime? _ageTokenExpiry;

  String? _cachedAgoToken;
  DateTime? _agoTokenExpiry;

  _AgeAuthChallengeHandler(this.callLambda);

  Future<(String?, DateTime?)> _getTokenForHost(String host) async {
    final isAgo = host.contains('arcgis.com');

    if (isAgo) {
      if (_cachedAgoToken != null &&
          _agoTokenExpiry != null &&
          DateTime.now().isBefore(_agoTokenExpiry!.subtract(const Duration(minutes: 5)))) {
        return (_cachedAgoToken, _agoTokenExpiry);
      }
    } else {
      if (_cachedAgeToken != null &&
          _ageTokenExpiry != null &&
          DateTime.now().isBefore(_ageTokenExpiry!.subtract(const Duration(minutes: 5)))) {
        return (_cachedAgeToken, _ageTokenExpiry);
      }
    }

    final data = await callLambda({'action': 'getTokens'});

    _cachedAgeToken = data['age']?['token'] as String?;
    final ageExpiresIn = data['age']?['expires_in'] as int? ?? 7200;
    _ageTokenExpiry = DateTime.now().add(Duration(seconds: ageExpiresIn));

    _cachedAgoToken = data['ago']?['token'] as String?;
    final agoExpiresIn = data['ago']?['expires_in'] as int? ?? 7200;
    _agoTokenExpiry = DateTime.now().add(Duration(seconds: agoExpiresIn));

    return isAgo ? (_cachedAgoToken, _agoTokenExpiry) : (_cachedAgeToken, _ageTokenExpiry);
  }

  @override
  Future<void> handleArcGISAuthenticationChallenge(
    ArcGISAuthenticationChallenge challenge,
  ) async {
    try {
      final host = challenge.requestUri.host;
      final (token, expiry) = await _getTokenForHost(host);
      if (token == null || expiry == null) {
        challenge.continueAndFail();
        return;
      }
      final tokenInfo = TokenInfo.create(
        accessToken: token,
        expirationDate: expiry,
        isSslRequired: true,
      );
      if (tokenInfo == null) {
        challenge.continueAndFail();
        return;
      }
      final credential = PregeneratedTokenCredential(
        uri: challenge.requestUri,
        tokenInfo: tokenInfo,
        referer: '',
      );
      challenge.continueWithCredential(credential);
    } catch (e) {
      debugPrint('Auth challenge failed: $e');
      challenge.continueAndFail();
    }
  }
}