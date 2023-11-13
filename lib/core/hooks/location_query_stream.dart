// location_stream_hook.dart
import 'dart:async';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';
import 'package:geolocator/geolocator.dart';

/*
 * For the version in this file, it is mostly done by GPT. It seems like it's
 * using useState and useEffect directly.
 *
 */
Coordinates usePositionStreamHook() {
  // State to hold the latest Coordinates
  final coordinates = useState(Coordinates());
  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  useEffect(() {
    final streamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .map((position) => Coordinates(
                lat: position.latitude,
                lon: position.longitude)) // Convert Position to Coordinates
            .listen(
      (coords) {
        // Update the state with the new Coordinates
        coordinates.value = coords;
      },
      onError: (error) {
        // Handle errors, possibly by setting the state to a 'null' or 'error' value
      },
    );

    // Unsubscribe when the widget is disposed
    return streamSubscription.cancel;
  }, [locationSettings]);

  // Return the current Coordinates
  return coordinates.value;
}

/*
 * Here is an example of how to use it Widget build by GPT
// my_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'location_stream_hook.dart'; // Import the custom hook
import 'package:geolocator/geolocator.dart';

class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {

    // Use the custom hook to listen to the position stream and
    //get the current coordinates
    final currentCoordinates = usePositionStreamHook();

    // Build your UI based on the current coordinates
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Stream Example'),
      ),
      body: Center(
        child: currentCoordinates != null
            ? Text('Current Coordinates: Lat: ${currentCoordinates.latitude},
            * Long: ${currentCoordinates.longitude}')
            : CircularProgressIndicator(),
      ),
    );
  }
}

 */
