import 'package:campus_mobile_experimental/ui/WhatsAroundMe/wam_list_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app_constants.dart';
import '../../app_styles.dart';
import '../../core/providers/map.dart';

/// TODO: Make each place name clickable to open a "place details page" (might need to update router)
/// That would require the "Get Place Details API" ^
/// https://developers.arcgis.com/documentation/mapping-and-location-services/place-finding/get-place-details/
class BuildWhatAroundMeList extends StatelessWidget {
  final List<Place> places;
  const BuildWhatAroundMeList({Key? key, required this.places}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 12.0),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return ListTile(
          // Directions Button (Far left of the list item)
          leading: GestureDetector(
            onTap: () {
              print("Opening directions for ${place.name}...");
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
                      'Please turn your location on in order to use this feature.'),
                  duration: Duration(seconds: 3),
                ));
              } else {
                getDirectionsToPlace(context, place.location);
              }
            },
            child: Container(
              padding: EdgeInsets.all(8.0), // Add padding around the icon
              decoration: BoxDecoration(
                color: Colors.lightBlue.withOpacity(0.2), // Light background color
                shape: BoxShape.circle, // Circular shape for the container
              ),
              child: Icon(
                Icons.directions_walk,
                color: Colors.lightBlue,
              ),
            ),
          ),
          title: Text(
            place.name,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w700,
              color: lightPrimaryColor
            ),
          ),
          subtitle: Text(
            // "${place.location} • ${place.category}", // TODO: replace location for busyness
            "${place.category}",
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.light
                  ? descriptiveTextColorLight
                  : descriptiveTextColorDark,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: Text(
            "${(place.distanceMeters/1609.34).toStringAsFixed(1)} mi",
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.light
                  ? descriptiveTextColorLight
                  : descriptiveTextColorDark,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      },
    );
  }
}

Future<void> getDirectionsToPlace(BuildContext context, String location) async {
  List<String> coordinates = location.split(', ');
  double latitude = double.parse(coordinates[0]);
  double longitude = double.parse(coordinates[1]);

  print('Latitude: $latitude, Longitude: $longitude');

  String googleUrl =
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=walking';
  String appleUrl = 'http://maps.apple.com/?daddr=$latitude,$longitude&dirflag=w';
  if (await canLaunch(googleUrl)) {
    await launch(googleUrl);
  } else if (await canLaunch(appleUrl)) {
    await launch(appleUrl);
  } else {
    throw 'Could not launch $googleUrl';
  }
}
