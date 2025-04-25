import 'package:campus_mobile_experimental/core/models/wam_list_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app_styles.dart';
import '../../core/providers/map.dart';

/// A stateless widget that builds the scrollable list of nearby places
/// with details such as the place name, category, distance, and a button to get walking directions.
///
/// **Parameters:**
/// - `places` (*List<Place>*): A list of `Place` objects to display.
///
/// **Example Usage:**
/// ```dart
/// BuildWhatAroundMeList(places: nearbyPlaces);
/// ```
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
              var coordinates = Provider.of<MapsDataProvider>(context, listen: false).coordinates;
              if (coordinates!.lat == null || coordinates.lon == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please turn your location on in order to use this feature.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              } else {
                getDirectionsToPlace(context, place.location);
              }
            },
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.lightBlue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_walk,
                color: Colors.lightBlue,
              ),
            ),
          ),
          // Place Name // TODO: Make this clickable to open a "place details page"
          // That would require the "Get Place Details API" ^
          // https://developers.arcgis.com/documentation/mapping-and-location-services/place-finding/get-place-details/
          title: Text(
            place.name,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w700,
              color: lightPrimaryColor,
            ),
          ),
          // Place Category
          subtitle: Text(
            "${place.category}",
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.light
                  ? descriptiveTextColorLight
                  : descriptiveTextColorDark,
              fontWeight: FontWeight.w400,
            ),
          ),
          // Place Distance in miles
          trailing: Text(
            "${(place.distanceMeters / 1609.34).toStringAsFixed(1)} mi",
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

/// This async function takes a location string in the format "latitude, longitude"
/// and opens walking directions to a WAM list item location in either Google Maps or Apple Maps.
/// If neither application can be launched, it throws an error.
///
/// **Parameters:**
/// - `context` (*BuildContext*): The current build context.
/// - `location` (*String*): A string containing the latitude and longitude of the destination, separated by a comma.
///
/// **Example Usage:**
/// ```dart
/// await getDirectionsToPlace(context, "32.7157, -117.1611");
/// ```
Future<void> getDirectionsToPlace(BuildContext context, String location) async {
  // Parse coordinates
  List<String> coordinates = location.split(', ');
  double latitude = double.parse(coordinates[0]);
  double longitude = double.parse(coordinates[1]);

  // Log coordinates for debugging
  // print('Latitude: $latitude, Longitude: $longitude');

  // Construct URLs
  String googleUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=walking';
  String appleUrl = 'http://maps.apple.com/?daddr=$latitude,$longitude&dirflag=w';

  // Launch directions
  if (await canLaunch(googleUrl)) {
    await launch(googleUrl);
  } else if (await canLaunch(appleUrl)) {
    await launch(appleUrl);
  } else {
    throw 'Could not launch $googleUrl';
  }
}
