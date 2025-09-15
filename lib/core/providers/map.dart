import 'dart:math';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/services/map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:campus_mobile_experimental/core/models/esri_poi.dart';

class MapsDataProvider extends ChangeNotifier {
  MapsDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;
    _noResults = false;

    ///INITIALIZE SERVICES
    _mapSearchService = MapSearchService();
    _esriPOIModels = [];
  }

  ///STATES
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;
  bool? _noResults;

  Coordinates? _coordinates;
  Map<MarkerId, Marker> _markers = Map<MarkerId, Marker>();
  TextEditingController _searchBarController = TextEditingController();
  GoogleMapController? _mapController;
  List<String> _searchHistory = [];

  ///Default coordinates for Price Center
  double? _defaultLat = 32.87990969506536;
  double? _defaultLong = -117.2362059310055;

  ///MODELS
  List<EsriPOIModel> _esriPOIModels = [];

  ///SERVICES
  late MapSearchService _mapSearchService;

  /// Adds a marker to the map based on the given index.
  void addMarker(int listIndex) {
    Marker? marker;
    // Check if _esriPOIModels has data and the index is valid
    if (_esriPOIModels.isNotEmpty &&
        listIndex >= 0 &&
        listIndex < _esriPOIModels.length) {
      final model = _esriPOIModels[listIndex];
      // Check for valid coordinates before creating the marker
      if (model.attributes.latitude == null ||
          model.attributes.longitude == null) {
        // If the coordinates are invalid, do not create a marker (a.k.a. nothing will happen when you click on this location)
        return;
      }
      // Create a marker from the EsriPOIModel at the given index
      // TODO: Replace c3dDescription once a replacement becomes available - As of August 2025, it is planned to be deprecated.
      marker = Marker(
        markerId: MarkerId(model.mkrMarkerid.toString()),
        position:
            LatLng(model.attributes.latitude!, model.attributes.longitude!),
        infoWindow: InfoWindow(
          title: model.attributes.updatedName ?? model.attributes.c3dName,
          snippet: model.attributes.c3dDescription,
        ),
      );
    } else {
      return; // If neither list has valid data for the index, do nothing
    }

    // Clear all existing markers and add the new marker
    _markers.clear();
    _markers[marker.markerId] = marker;

    // Move the map camera to the new marker and show its info window
    updateMapPosition();
    notifyListeners();
  }

  void updateMapPosition() {
    if (_markers.isNotEmpty && _mapController != null) {
      _mapController!
          .animateCamera(
              CameraUpdate.newLatLng(_markers.values.toList()[0].position))
          .then((_) async {
        await Future.delayed(Duration(seconds: 1));
        try {
          _mapController!
              .showMarkerInfoWindow(_markers.values.toList()[0].markerId);
        } catch (e) {}
      });
    }
  }

  void removeFromSearchHistory(String item) {
    searchHistory.remove(item);
    notifyListeners();
  }

  /// Fetches locations from the MapSearchService or ESRI Points of Interest
  void fetchLocations() async {
    String query = searchBarController.text;
    markers.clear();
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (await _mapSearchService.fetchESRILocations(query)) {
      _esriPOIModels = _mapSearchService.esriResults;
      _noResults = false;
      // print("ESRI API Results: " + _esriPOIModels.toString());
      if (_esriPOIModels.isEmpty) {
        _noResults = true;
      } else {
        _noResults = false;
        populateESRIDistances();
        reorderESRILocations();
        addMarker(0);
      }
      if (!_searchHistory.contains(query)) {
        // Check to see if this search is already in history...
        _searchHistory.add(query); // ...If it is not, add it...
      } else {
        _searchHistory
            .remove(query); // ...reorder search history to put it back on top
        _searchHistory.add(query);
      }
      _lastUpdated = DateTime.now();
    } else {
      _error = _mapSearchService.error;
      _noResults = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  void populateESRIDistances() {
    double? latitude =
        _coordinates!.lat != null ? _coordinates!.lat : _defaultLat;
    double? longitude =
        _coordinates!.lon != null ? _coordinates!.lon : _defaultLong;
    if (_coordinates != null) {
      for (EsriPOIModel model in _esriPOIModels) {
        if (model.attributes.latitude != null &&
            model.attributes.longitude != null) {
          var distance = calculateDistance(latitude!, longitude!,
              model.attributes.latitude!, model.attributes.longitude!);
          model.distance = distance as double?;
        }
      }
    }
  }

  void reorderESRILocations() {
    _esriPOIModels.sort((EsriPOIModel a, EsriPOIModel b) {
      if (a.distance != null && b.distance != null) {
        return a.distance!.compareTo(b.distance!);
      }
      return 0;
    });
  }

  num calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 0.621371;
  }

  /// Setters
  set coordinates(Coordinates? value) {
    _coordinates = value;
    notifyListeners();
  }

  set searchBarController(TextEditingController value) {
    _searchBarController = value;
    notifyListeners();
  }

  set mapController(GoogleMapController? value) {
    _mapController = value;
    notifyListeners();
  }

  void resetNoResults() {
    _noResults = false;
    notifyListeners();
  }

  /// SIMPLE GETTERS
  bool? get isLoading => _isLoading;
  bool? get noResults => _noResults;
  String? get error => _error;
  List<String> get searchHistory => _searchHistory;
  List<EsriPOIModel> get esriPOIModels => _esriPOIModels;
  Map<MarkerId, Marker> get markers => _markers;
  Coordinates? get coordinates => _coordinates;
  DateTime? get lastUpdated => _lastUpdated;
  TextEditingController get searchBarController => _searchBarController;
  GoogleMapController? get mapController => _mapController;
}
