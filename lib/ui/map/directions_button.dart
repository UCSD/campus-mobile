import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class DirectionsButton extends StatelessWidget {
  const DirectionsButton({
    Key key,
    @required GoogleMapController mapController,
  })  : _mapController = mapController,
        super(key: key);

  final GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(
        Icons.directions_walk,
        color: Colors.lightBlue,
      ),
      backgroundColor: Colors.white,
      onPressed: () {
      },
    );
  }
}
