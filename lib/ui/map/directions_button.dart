import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
    LatLng currentPin = Provider
        .of<MapsDataProvider>(context, listen: false)
        .markers
        .values
        .toList()[0].position;
    double lat = currentPin.latitude;
    double lon = currentPin.longitude;

    String googleUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=walking';
    String appleUrl =
        'http://maps.apple.com/?daddr=$lat,$lon&dirflag=w';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    }
    else if (await canLaunch(appleUrl)) {
      await launch(appleUrl);
    } else {
      throw 'Could not launch $googleUrl';
    }
  }
}
