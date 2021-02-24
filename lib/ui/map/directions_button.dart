import 'package:campus_mobile_experimental/app_constants.dart';
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
      heroTag: "directions",
      child: Icon(
        Icons.directions_walk,
        color: Colors.lightBlue,
      ),
      backgroundColor: Colors.white,
      onPressed: () {
        String locationQuery =
            Provider.of<MapsDataProvider>(context, listen: false)
                .searchBarController
                .text;
        if (locationQuery.isNotEmpty) {
          getDirections(context);
        } else {
          Navigator.pushNamed(context, RoutePaths.MapSearch);
        }
      },
    );
  }

  Future<void> getDirections(BuildContext context) async {
    LatLng currentPin = Provider.of<MapsDataProvider>(context, listen: false)
        .markers
        .values
        .toList()[0]
        .position;
    double lat = currentPin.latitude;
    double lon = currentPin.longitude;

    Provider.of<MapsDataProvider>(context, listen: false)
        .createPolylines(lat, lon);
  }
}
