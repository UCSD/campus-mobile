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
/// **Key Features:**
/// - Initializes the state for managing the list of nearby places.
/// - Delegates the state management and UI rendering to `_WhatsAroundMeState`.
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

/// Manages the state and UI for displaying nearby points of interest.
///
/// This stateful widget fetches and displays a list of nearby places using the ESRI Nearby Search API.
/// It includes functionality to toggle the visibility of the list, handle loading states, and sort the results
/// by proximity. The UI consists of a button to fetch and display the places and a list view to show the results.
///
/// **Key Features:**
/// - Fetches nearby places asynchronously using `fetchNearbySearchPlaces`.
/// - Displays a loading indicator while data is being fetched.
/// - Sorts the fetched places by distance and limits the results to the top 13.
/// - Provides a toggle button to show or hide the list of places.
///
/// **State Variables:**
/// - `showPlaces` (*bool*): Controls the visibility of the places list.
/// - `nearbySearchList` (*List<Place>*): Stores the fetched list of places.
/// - `isLoading` (*bool*): Indicates whether data is currently being fetched.
///
/// **Methods:**
/// - `initState()`: Initializes the state and triggers the initial fetch of places.
/// - `fetchPlaces()`: Fetches the list of nearby places and updates the state.
/// - `fetchTopNearbyPlaces()`: Sorts and retrieves the top 13 places by proximity.
///
/// **UI Components:**
/// - A floating action button to toggle the visibility of the places list.
/// - A container displaying the list of places with custom styling.
/// - A loading indicator displayed while fetching data.
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

  /// Fetches a list of nearby places and updates the state.
  ///
  /// This asynchronous function retrieves nearby points of interest using the `fetchNearbySearchPlaces` method.
  /// It manages the loading state before and after the fetch operation and ensures the `nearbySearchList`
  /// is updated with the fetched data or an empty list in case of an error.
  ///
  /// **State Updates:**
  /// - Sets `isLoading` to `true` before starting the fetch operation.
  /// - Updates `nearbySearchList` with the fetched data or an empty list on error.
  /// - Sets `isLoading` to `false` after the fetch operation completes.
  ///
  /// **Exceptions:**
  /// - Catches and logs any errors encountered during the fetch operation.
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

  /// Retrieves the top nearby places sorted by proximity.
  ///
  /// This function creates a sorted copy of the `nearbySearchList` based on the distance
  /// of each place in ascending order. It then selects and returns the top 13 closest places.
  ///
  /// **Returns:**
  /// - A `List<Place>` containing the top 13 places sorted by distance.
  ///
  /// **Notes:**
  /// - The original `nearbySearchList` remains unmodified.
  /// - Ensure that `nearbySearchList` is populated before calling this function.
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
