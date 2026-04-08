import 'dart:convert';
import 'dart:math' as math;
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final String poiClassValue; // maps to POI "Class" field value

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
  static const _buildingsQueryUrl =
      'https://admin-enterprise-gis.ucsd.edu/server/rest/services/'
      'AdministrationServices/Buildings_Public/MapServer/0/query';
  static const _poiQueryUrl =
      'https://services9.arcgis.com/mXNwDpiENQiMIzRv/arcgis/rest/services/'
      'Points_Of_Interest/FeatureServer/0/query';

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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initMap();
    _loadRecentSearches();
    _fetchAllPoiClasses();
    // Listen for focus changes to show/hide suggestions
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _categorySheetController.dispose();
    _detailSheetController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initMap() {
    final hillshadeLayer = ArcGISTiledLayer.withUri(
      Uri.parse(
        'https://services.arcgisonline.com/arcgis/rest/services/Elevation/World_Hillshade/MapServer',
      ),
    );

    final campusVectorTileLayer = ArcGISVectorTiledLayer.withUri(
      Uri.parse(
        'https://admin-enterprise-gis.ucsd.edu/server/rest/services/Hosted/CampusMapVector/VectorTileServer',
      ),
    );

    final basemap = Basemap();
    basemap.baseLayers.add(hillshadeLayer);
    basemap.baseLayers.add(campusVectorTileLayer);

    _map = ArcGISMap.withBasemap(basemap);
    _map.initialViewpoint = Viewpoint.fromCenter(
      ArcGISPoint(
        x: -117.2340,
        y: 32.8801,
        spatialReference: SpatialReference.wgs84,
      ),
      scale: 24000,
    );
  }

  void _onMapViewReady() {
    _mapViewController.arcGISMap = _map;
    _mapViewController.interactionOptions.rotateEnabled = false;
    _mapViewController.graphicsOverlays.add(_graphicsOverlay);

    // Wire up location display — blue dot, no auto-pan on start
    _mapViewController.locationDisplay.dataSource = _locationDataSource;
    _mapViewController.locationDisplay.autoPanMode =
        LocationDisplayAutoPanMode.off;

    _startLocationDisplay();
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

  String _escSql(String input) => input.replaceAll("'", "''");

  /// Query the Buildings (AGE) MapServer
  Future<List<MapSearchResult>> _queryBuildings(String query) async {
    await dotenv.load(fileName: ".env");
    final token = dotenv.env['ARCGIS_AGE_API_KEY'] ?? '';
    final escaped = _escSql(query);
    final where = "UPPER(FacilityLongName) LIKE UPPER('%$escaped%') "
        "OR UPPER(BuildingAliases) LIKE UPPER('%$escaped%')";

    final uri = Uri.parse(_buildingsQueryUrl).replace(
      queryParameters: {
        'where': where,
        'outFields':
            'FacilityLongName,BuildingAliases,StreetAddress,City,Zipcode,Latitude,Longitude',
        'returnGeometry': 'false',
        'resultRecordCount': '8',
        'f': 'json',
        if (token.isNotEmpty) 'token': token,
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) return [];

    final json = jsonDecode(response.body);
    final features = json['features'] as List<dynamic>? ?? [];

    return features.map<MapSearchResult>((f) {
      final attrs = f['attributes'] as Map<String, dynamic>;
      final name =
          (attrs['FacilityLongName'] as String?) ?? 'Unknown Building';
      final alias = (attrs['BuildingAliases'] as String?) ?? '';
      final street = (attrs['StreetAddress'] as String?) ?? '';
      final city = (attrs['City'] as String?) ?? '';
      final zip = (attrs['Zipcode'] as String?) ?? '';
      final lat = (attrs['Latitude'] as num?)?.toDouble() ?? 0.0;
      final lng = (attrs['Longitude'] as num?)?.toDouble() ?? 0.0;

      final addressParts = <String>[
        if (street.isNotEmpty) street,
        if (city.isNotEmpty) city,
        if (zip.isNotEmpty) zip,
      ];
      final fullAddress = addressParts.join(', ');
      final subtitle = alias.isNotEmpty ? alias : 'Building';

      return MapSearchResult(
        name: name,
        subtitle: subtitle,
        latitude: lat,
        longitude: lng,
        source: MapSearchSource.building,
        address: fullAddress,
      );
    }).where((r) => r.latitude != 0.0 && r.longitude != 0.0).toList();
  }

  /// Fetches all distinct POI Class values from the FeatureServer and caches them.
  Future<void> _fetchAllPoiClasses() async {
    try {
      final uri = Uri.parse(_poiQueryUrl).replace(queryParameters: {
        'where': '1=1',
        'outFields': 'Class',
        'returnDistinctValues': 'true',
        'orderByFields': 'Class',
        'returnGeometry': 'false',
        'resultRecordCount': '200',
        'f': 'json',
      });
      final response = await http.get(uri);
      if (response.statusCode != 200) return;
      final json = jsonDecode(response.body);
      final features = json['features'] as List<dynamic>? ?? [];
      final classes = features
          .map((f) => (f['attributes']['Class'] as String?) ?? '')
          .where((c) => c.isNotEmpty)
          .toList()
        ..sort();
      setState(() => _allPoiClasses = classes);
      print(_allPoiClasses);
    } catch (e) {
      debugPrint('Failed to fetch POI classes: $e');
    }
  }

  /// Query the POIs (AGO) FeatureServer by text search.
  Future<List<MapSearchResult>> _queryPOIs(String query) async {
    final escaped = _escSql(query);
    final where = "UpdatedName LIKE '%$escaped%' "
        "OR C3DName LIKE '%$escaped%' "
        "OR C3DKeywords LIKE '%$escaped%'";
    return _executePOIQuery(where);
  }

  /// Query POIs filtered by a specific Class value (for category taps).
  Future<List<MapSearchResult>> _queryPOIsByClass(String classValue) async {
    final escaped = _escSql(classValue);
    final where = "Class = '$escaped'";
    return _executePOIQuery(where, maxResults: 100);
  }

  /// Shared POI query execution.
  Future<List<MapSearchResult>> _executePOIQuery(
    String where, {
    int maxResults = 8,
  }) async {
    final uri = Uri.parse(_poiQueryUrl).replace(
      queryParameters: {
        'where': where,
        'outFields':
            'UpdatedName,C3DName,Class,Subclass,C3DDescription,URL,Latitude,Longitude',
        'returnGeometry': 'false',
        'resultRecordCount': '$maxResults',
        'f': 'json',
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) return [];

    final json = jsonDecode(response.body);
    final features = json['features'] as List<dynamic>? ?? [];

    return features.map<MapSearchResult>((f) {
      final attrs = f['attributes'] as Map<String, dynamic>;
      final updatedName = (attrs['UpdatedName'] as String?) ?? '';
      final c3dName = (attrs['C3DName'] as String?) ?? '';
      final name = updatedName.isNotEmpty ? updatedName : c3dName;
      final poiClass = (attrs['Class'] as String?) ?? '';
      final subclass = (attrs['Subclass'] as String?) ?? '';
      final description = (attrs['C3DDescription'] as String?) ?? '';
      final url = (attrs['URL'] as String?) ?? '';
      final lat = (attrs['Latitude'] as num?)?.toDouble() ?? 0.0;
      final lng = (attrs['Longitude'] as num?)?.toDouble() ?? 0.0;

      final subtitle =
          subclass.isNotEmpty ? '$poiClass - $subclass' : poiClass;

      return MapSearchResult(
        name: name.isNotEmpty ? name : 'Unknown POI',
        subtitle: subtitle,
        latitude: lat,
        longitude: lng,
        source: MapSearchSource.poi,
        description: description,
        websiteUrl: url.isNotEmpty ? url : null,
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
      // If a category search is active, reopen the list view
      if (_allCategoryResults.isNotEmpty) {
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

  void _clearSearch() {
    _searchController.clear();
    _graphicsOverlay.graphics.clear();
    setState(() {
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
    });
  }

  Future<void> _launchDirections(MapSearchResult result) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${result.latitude},${result.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchWebsite(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _categories
                  .map((cat) => _buildCategoryChip(context, cat))
                  .toList(),
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

    return GestureDetector(
      onTap: () => _performCategorySearch(category),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              category.icon,
              size: 24,
              color: isDark ? Colors.white70 : Colors.grey[700],
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
    final contentFraction = (contentEst / screenHeight).clamp(0.15, 0.80);
    final initialSize =
        contentFraction < 0.30 ? contentFraction : 0.30;
    final maxSize =
        contentFraction < 0.80 ? contentFraction.clamp(0.30, 0.80) : 0.80;
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
          headerTitle: result.name,
          headerIcon: _iconForResult(result),
          onClose: _closeDetail,
          sliverBody: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category label
                    Text(
                      categoryLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),

                    // Detail text
                    if (detailText.isNotEmpty) ...[
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
                    const SizedBox(height: 16),

                    // Action buttons
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
                            onPressed: () => _launchDirections(result),
                            icon: const Icon(Icons.directions, size: 18),
                            label: const Text('Get Directions'),
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

    return Scaffold(
      body: Stack(
        children: [
          // Map — Listener detects pointer-down to collapse slideovers
          Column(
            children: [
              Expanded(
                child: Listener(
                  onPointerDown: _onMapPointerDown,
                  child: ArcGISMapView(
                    controllerProvider: () => _mapViewController,
                    onMapViewReady: _onMapViewReady,
                    onTap: _onMapTap,
                  ),
                ),
              ),
            ],
          ),

          // Floating search bar + dropdown
          Positioned(
            top: 8,
            left: 12,
            right: 12,
            child: Column(
              children: [
                // Search bar
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
          // Bottom-right FAB cluster: list view button + info button
          if (_selectedResult == null)
            Positioned(
              right: 16,
              bottom: 32,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // List view button — only when a category search is active
                  if (_allCategoryResults.isNotEmpty) ...[
                    FloatingActionButton.small(
                      heroTag: 'listBtn',
                      onPressed: () {
                        setState(() {
                          _showCategoryList = !_showCategoryList;
                        });
                      },
                      backgroundColor: _showCategoryList
                          ? Theme.of(context).colorScheme.primary
                          : (isDark ? Colors.grey[800] : null),
                      foregroundColor: _showCategoryList
                          ? Colors.white
                          : (isDark ? Colors.white : null),
                      child: Icon(
                        _showCategoryList ? Icons.map_outlined : Icons.list,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (_lastSelectedResult != null)
                    FloatingActionButton.small(
                      heroTag: 'infoBtn',
                      backgroundColor: isDark ? Colors.grey[800] : null,
                      foregroundColor: isDark ? Colors.white : null,
                      onPressed: _reopenDetail,
                      child: const Icon(Icons.info_outline),
                    ),
                  if (_allCategoryResults.isNotEmpty || _lastSelectedResult != null)
                    const SizedBox(height: 10),
                  FloatingActionButton.small(
                    heroTag: 'locateBtn',
                    backgroundColor: isDark ? Colors.grey[800] : null,
                    foregroundColor: isDark ? Colors.white : null,
                    onPressed: _recenterOnUser,
                    child: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),

          // Category list panel — shown when list button is toggled
          if (_showCategoryList && _selectedResult == null && _allCategoryResults.isNotEmpty)
            _buildCategoryListPanel(context),

          // Detail slide-over
          if (_selectedResult != null)
            _buildDetailSlideOver(context, _selectedResult!),
        ],
      ),
    );
  }
}