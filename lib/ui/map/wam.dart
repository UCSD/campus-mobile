import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/wam.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/core/services/wam.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// A stateful widget that displays nearby points of interest.
///
/// This widget serves as the entry point for the "What's Around Me" feature. It manages
/// the state and delegates the logic to `_WhatsAroundMeState` for fetching and displaying
/// nearby places.
///
/// **Example Usage:**
/// ```dart
/// WhatsAroundMe();
/// ```
class WhatsAroundMe extends StatefulWidget {
  const WhatsAroundMe({Key? key}) : super(key: key);
  @override
  State<WhatsAroundMe> createState() => _WhatsAroundMeState();
}

/// What's Around Me Class - Manages the state and UI for displaying places around you.
/// **Key Features:**
/// - Fetches nearby places asynchronously using `fetchNearbySearchPlaces`.
/// - Sorts and displays the fetched places by distance (closest first).
/// - `nearbySearchList` (*List<Place>*): Stores the fetched list of places.
///
/// **Methods:**
/// - `initState()`: Initializes the state and triggers the initial fetch of places.
/// - `fetchPlaces()`: Fetches the list of nearby places and updates the state.
/// - `fetchTopNearbyPlaces()`: Sorts and retrieves the top places by proximity.
///
/// **Example Usage:**
/// ```dart
/// WhatsAroundMe();
/// ```
class _WhatsAroundMeState extends State<WhatsAroundMe> {
  var showPlaces = false;
  bool isLoading = false;
  final placesToFetch = 13; // Fetch 13 places. // TODO: Make # of places to fetch a user setting
  late List<Place> nearbySearchList;

  @override
  void initState() {
    super.initState();
    fetchPlaces();
  }

  /// Fetches a list of points places using the `fetchNearbySearchPlaces` service.
  /// Updates `nearbySearchList` with the fetched data or an empty list on error.
  ///
  /// **Example Usage:**
  /// ```dart
  /// await fetchPlaces();
  /// ```
  Future<void> fetchPlaces() async {
    setState(() { isLoading = true; });
    try {
      nearbySearchList = await fetchWhatsAroundYou(placesToFetch);
    } catch (e) {
      print("Error fetching $placesToFetch places: $e");
      nearbySearchList = []; // Ensure the list is initialized even on error
    } finally {
      setState(() { isLoading = false; });
    }
  }

  /// Retrieves the top nearby places (a subset of nearbySearchList) sorted by proximity.
  /// This is a subset of the `nearbySearchList` by design.
  /// If we want to let the student choose how many places to show, we can add a setting for that,
  /// and that setting will modify this function's `placesToFetch`.
  /// However, the student won't be able to see more than the places we fetch in nearbySearchList.
  /// This is so we control the cost of using this API.
  ///
  /// **Returns:**
  /// - A `List<Place>` containing the top places sorted by proximity.
  ///
  /// **Notes:**
  /// - `nearbySearchList` should be populated before calling this function.
  ///
  /// **Example Usage:**
  /// ```dart
  /// List<Place> topPlaces = fetchTopNearbyPlaces();
  /// ```
  List<Place> fetchTopNearbyPlaces() {
    List<Place> sorted = List.from(nearbySearchList)
      ..sort((a, b) => a.distanceFromUser.compareTo(b.distanceFromUser));
    return sorted.take(placesToFetch).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Define container constraints
    final containerConstraints = BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width * 0.8,
      maxHeight: MediaQuery.of(context).size.height * 0.4,
    );

    // Define container decoration
    final containerDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );

    /// What's Around Me
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// What's Around Me List
        if (showPlaces)
          Container(
            constraints: containerConstraints,
            decoration: containerDecoration,
            child: BuildWhatAroundMeList(places: fetchTopNearbyPlaces()),
          ),
        SizedBox(height: 10),
        /// What's Around You? Button
        FloatingActionButton.extended(
          onPressed: () => setState(() => showPlaces = !showPlaces),
          label: showPlaces
              ? Icon(Icons.close, size: 20)
              : Text("What's Around You?"),
          backgroundColor: Colors.lightBlue,
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
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
            "${(place.distanceFromUser / 1609.34).toStringAsFixed(1)} mi",
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