import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/map_search_model.dart';
import 'package:campus_mobile_experimental/core/services/map_search_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Maps extends StatefulWidget {
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  final MapSearchService _mapSearchService = MapSearchService();
  GoogleMapController _mapController;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  List<MapSearchModel> _data;

  final LatLng _center = const LatLng(32.8911637, -117.2428029);

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _addMarker(String text) async {
    _data = await _mapSearchService.fetchMenu(text);
    final Marker marker = Marker(
      markerId: MarkerId(_data[0].mkrMarkerid.toString()),
      position: LatLng(_data[0].mkrLat, _data[0].mkrLong),
      infoWindow: InfoWindow(title: _data[0].title),
    );
    setState(() {
      _markers[marker.markerId] = marker;
      _mapController.animateCamera(CameraUpdate.newLatLng(marker.position));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          markers: Set<Marker>.of(_markers.values),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 14.5,
          ),
        ),
        Hero(
          tag: 'search_bar',
          child: Card(
            margin: EdgeInsets.all(5),
            child: RawMaterialButton(
              onPressed: () {
                Navigator.pushNamed(context, RoutePaths.MapSearch,
                    arguments: _addMarker);
              },
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 9),
                    child: Icon(
                      Icons.search,
                      size: 30,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      enabled: false,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        hintText: 'Search',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
//        Padding(
//          padding: const EdgeInsets.all(16.0),
//          child: Align(
//            alignment: Alignment.bottomRight,
//            child: FloatingActionButton(
//              child: Icon(Icons.my_location),
//              onPressed: () {},
//            ),
//          ),
//        )
      ],
    );
  }
}
