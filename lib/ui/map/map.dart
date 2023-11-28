import 'dart:async';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/ui/map/directions_button.dart';
import 'package:campus_mobile_experimental/ui/map/map_search_bar_ph.dart';
import 'package:campus_mobile_experimental/ui/map/more_results_list.dart';
import 'package:campus_mobile_experimental/ui/map/my_location_button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uni_links2/uni_links.dart';

class Maps extends StatelessWidget {
  ///STATES
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;
  bool? _noResults;

  ///Default coordinates for Price Center
  double? _defaultLat = 32.87990969506536;
  double? _defaultLong = -117.2362059310055;

  ///MODELS
  List<MapSearchModel> _mapSearchModels = [];
  Coordinates? _coordinates;
  Map<MarkerId, Marker> _markers = Map<MarkerId, Marker>();
  TextEditingController _searchBarController = TextEditingController();
  GoogleMapController? _mapController;
  List<String> _searchHistory = [];

  ///SERVICES (later to be HOOKS)
  late MapSearchService _mapSearchService;

  Widget resultsList(BuildContext context) {
    if (Provider.of<MapsDataProvider>(context).markers.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      });
      return MoreResultsList();
    } else if (Provider.of<MapsDataProvider>(context).noResults!) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
              SnackBar(content: Text('No results found for your search.')));
      });
    }
    return Container();
  }

  Widget buildButtons(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: height * 0.05,
      right: width * 0.05,
      child: Column(
        children: [
          MyLocationButton(
              mapController:
                  Provider.of<MapsDataProvider>(context).mapController),
          SizedBox(height: 10),
          DirectionsButton(
              mapController:
                  Provider.of<MapsDataProvider>(context).mapController),
        ],
      ),
    );
  }

  Future<Null> initUniLinks(BuildContext context) async {
    // deep links are received by this method
    // the specific host needs to be added in AndroidManifest.xml and Info.plist
    // currently, this method handles executing custom map query
    late StreamSubscription _sub;
    _sub = linkStream.listen((String? link) async {
      // handling for map query
      if (link!.contains("deeplinking.searchmap")) {
        var uri = Uri.dataFromString(link);
        var query = uri.queryParameters['query']!;
        // redirect query to maps tab and search with query
        Provider.of<MapsDataProvider>(context, listen: false)
            .searchBarController
            .text = query;
        Provider.of<MapsDataProvider>(context, listen: false).fetchLocations();
        setBottomNavigationBarIndex(NavigatorConstants.MapTab);
        // received deeplink, cancel stream to prevent memory leaks
        _sub.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    initUniLinks(context);
    return Stack(
      children: <Widget>[
        GoogleMap(
          markers: Set<Marker>.of(
              Provider.of<MapsDataProvider>(context).markers.values),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            Provider.of<MapsDataProvider>(context, listen: false)
                .mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: const LatLng(32.8801, -117.2341),
            zoom: 14.5,
          ),
        ),
        MapSearchBarPlaceHolder(),
        buildButtons(context),
        resultsList(context),
      ],
    );
  }

  /// MAP HELPER FUNCTIONS BELOW HERE
  void addMarker(int listIndex) {
    final Marker marker = Marker(
      markerId: MarkerId(_mapSearchModels[listIndex].mkrMarkerid.toString()),
      position: LatLng(_mapSearchModels[listIndex].mkrLat!,
          _mapSearchModels[listIndex].mkrLong!),
      infoWindow: InfoWindow(
          title: _mapSearchModels[listIndex].title,
          snippet: _mapSearchModels[listIndex].description),
    );
    _markers.clear();
    _markers[marker.markerId] = marker;

    updateMapPosition();
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

  void reorderLocations() {
    _mapSearchModels.sort((MapSearchModel a, MapSearchModel b) {
      if (a.distance != null && b.distance != null) {
        return a.distance!.compareTo(b.distance!);
      }
      return 0;
    });
  }

  void fetchLocations() async {
    String query = searchBarController.text;
    markers.clear();
    _isLoading = true;
    _error = null;
    if (await _mapSearchService.fetchLocations(query)) {
      _mapSearchModels = _mapSearchService.results;
      _noResults = false;
      populateDistances();
      reorderLocations();
      addMarker(0);
      if (!_searchHistory.contains(query)) {
        // Check to see if this search is already in history...
        _searchHistory.add(query); // ...If it is not, add it...
      } else {
        // ...otherwise...
        _searchHistory
            .remove(query); // ...reorder search history to put it back on top
        _searchHistory.add(query);
      }
      _lastUpdated = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error = _mapSearchService.error;
      _noResults = true;
    }
    _isLoading = false;
  }

  void populateDistances() {
    double? latitude =
        _coordinates!.lat != null ? _coordinates!.lat : _defaultLat;
    double? longitude =
        _coordinates!.lon != null ? _coordinates!.lon : _defaultLong;
    if (_coordinates != null) {
      for (MapSearchModel model in _mapSearchModels) {
        if (model.mkrLat != null && model.mkrLong != null) {
          var distance = calculateDistance(
              latitude!, longitude!, model.mkrLat!, model.mkrLong!);
          model.distance = distance as double?;
        }
      }
    }
  }

  num calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 0.621371;
  }

  ///SIMPLE GETTERS
  bool? get isLoading => _isLoading;

  String? get error => _error;

  DateTime? get lastUpdated => _lastUpdated;

  List<MapSearchModel> get mapSearchModels => _mapSearchModels;

  List<String> get searchHistory => _searchHistory;

  Map<MarkerId, Marker> get markers => _markers;

  Coordinates? get coordinates => _coordinates;

  TextEditingController get searchBarController => _searchBarController;

  bool? get noResults => _noResults;

  GoogleMapController? get mapController => _mapController;
}
