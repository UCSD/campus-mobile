import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/navigator_keys.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/ui/common/directions_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/app_styles.dart';

class DirectionsButton extends StatelessWidget {
  const DirectionsButton({
    Key? key,
  }) : super(key: key);

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
        if (Provider.of<MapsDataProvider>(context, listen: false)
                    .coordinates!
                    .lat ==
                null ||
            Provider.of<MapsDataProvider>(context, listen: false)
                    .coordinates!
                    .lon ==
                null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Please turn your location on in order to use this feature.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: darkPrimaryColor,
            duration: Duration(seconds: 3),
          ));
        } else {
          String locationQuery =
              Provider.of<MapsDataProvider>(context, listen: false)
                  .searchBarController
                  .text;
          if (locationQuery.isNotEmpty) {
            getDirections(context);
          } else {
            //Navigator.pushNamed(context, RoutePaths.MapSearch);
            TabNavigatorKeys.mapTabKey.currentState
                ?.pushNamed(RoutePaths.MapSearch);
          }
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

    try {
      await DirectionsHelper.openDirections(lat, lon);
    } catch (e) {
      throw 'Could not launch directions: $e';
    }
  }
}
