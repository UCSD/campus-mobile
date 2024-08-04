import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_list.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

/// What's Around Me button that shows in the Maps page.
class WhatsAroundMeButton extends StatelessWidget {
  const WhatsAroundMeButton({
    Key? key,
    required GoogleMapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final GoogleMapController? _mapController;
  final String _dinningEndPoint = '';

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "whats_around_me",
      child: Icon(
        Icons.emergency_share_sharp, /// or Icons.explore_sharp,
        color: Colors.white,
      ),
      backgroundColor: Colors.amber.shade400,
      onPressed: () {
        /// Check whether user enabled location access. Prompt if not.
        if (Provider
          .of<MapsDataProvider>(context, listen: false)
          .coordinates!
          .lat == null ||
          Provider
          .of<MapsDataProvider>(context, listen: false)
          .coordinates!
          .lon == null) {
          // Geolocator.openLocationSettings(); /// REPLACE with the function that fixed the location issue
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
            'Please turn your location on in order to use this feature.'),
            duration: Duration(seconds: 3),
          ));
        }
        /// Trigger What's Around Me Feature (Shows the list)
        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return BuildWhatsAroundMeList(context: context, mapController: _mapController);
          },
        );
      },
    );
  }
}

