import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapController mapController;

  final LatLng _center = const LatLng(32.8911637, -117.2428029);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 14.5,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(10),
            width: double.infinity,
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.search,
                  size: 30,
                ),
                Expanded(
                  child: TextField(
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      hintText: 'Search here',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
