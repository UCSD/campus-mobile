import 'package:campus_mobile_experimental/core/models/wam_list_model.dart';
import 'package:flutter/material.dart';
import '../../core/services/wam_service.dart';
import 'wam_list.dart';

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
      nearbySearchList = await fetchNearbySearchPlaces(placesToFetch);
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
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
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
