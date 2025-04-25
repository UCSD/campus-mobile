import 'package:campus_mobile_experimental/ui/WhatsAroundMe/places_list_model.dart';
import 'package:flutter/material.dart';
import 'fetch_places_api.dart';
import 'wam_list.dart';

class WhatsAroundMe extends StatefulWidget {
  const WhatsAroundMe({Key? key}) : super(key: key);
  @override
  State<WhatsAroundMe> createState() => _WhatsAroundMeState();
}

class _WhatsAroundMeState extends State<WhatsAroundMe> {
  var showPlaces = false;
  // Fetch Points of Interest using the ESRI Nearby Search API
  //late final List<Place> pointsOfInterest = generateRandomPlaces(20);
  // TEST TEST TEST //
  late List<Place> TEST;

 @override
 void initState() {
   super.initState();
   fetchPlaces();
 }

  Future<void> fetchPlaces() async {
    try {
      TEST = await fetchPointsOfInterest(10);
    } catch (e) {
      print("Error fetching places: $e");
      TEST = []; // Ensure TEST is initialized even on error
    } finally {
      setState(() {}); // Update the UI after fetching data
    }
  }

  List<Place> fetchTopNearbyPlaces() {
    List<Place> sorted = List.from(TEST)
      ..sort((a, b) => a.distanceMi.compareTo(b.distanceMi));
    return sorted.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    final containerConstraints = BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width * 0.8,
      maxHeight: MediaQuery.of(context).size.height * 0.4
    );

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // What's Around Me List
        if (showPlaces)
          Container(
            constraints: containerConstraints,
            decoration: containerDecoration,
            child: BuildWhatAroundMeList(places: fetchTopNearbyPlaces()),
          ),
        SizedBox(height: 10),
        // What's Around Me Button
        FloatingActionButton.extended(
          onPressed: () => setState(() => showPlaces = !showPlaces),
          label: showPlaces? Icon(Icons.close, size: 20) : Text("What's Around You?"),
          backgroundColor: Colors.lightBlue,
        ),
      ],
    );
  }
}