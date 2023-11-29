import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/ui/map/map_search_view.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DirectionsButton extends StatelessWidget {
  final void Function() fetchLocations;
  final TextEditingController searchBarController;
  final Map<MarkerId, Marker> markers;
  final List<String> searchHistory;
  final Coordinates coordinates;

  const DirectionsButton({
    Key? key,
    required GoogleMapController? mapController,
    required this.fetchLocations,
    required this.searchBarController,
    required this.markers,
    required this.searchHistory,
    required this.coordinates,
  })  : _mapController = mapController,
        super(key: key);

  final GoogleMapController? _mapController;

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
        if (coordinates.lat == null || coordinates.lon == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Please turn your location on in order to use this feature.'),
            duration: Duration(seconds: 3),
          ));
        } else {
          String locationQuery = searchBarController.text;
          if (locationQuery.isNotEmpty) {
            getDirections(context);
          } else {
            Navigator.pushNamed(context, RoutePaths.MapSearch, arguments: {
              'arg1': fetchLocations,
              'arg2': searchBarController,
              'arg3': markers,
              'arg4': searchHistory,
            });
          }
        }
      },
    );
  }

  Future<void> getDirections(BuildContext context) async {
    LatLng currentPin = markers.values.toList()[0].position;
    double lat = currentPin.latitude;
    double lon = currentPin.longitude;

    String googleUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=walking';
    String appleUrl = 'http://maps.apple.com/?daddr=$lat,$lon&dirflag=w';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else if (await canLaunch(appleUrl)) {
      await launch(appleUrl);
    } else {
      throw 'Could not launch $googleUrl';
    }
  }
}
