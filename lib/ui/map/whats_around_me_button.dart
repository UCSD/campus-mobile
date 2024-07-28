import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class WhatsAroundMeButton extends StatelessWidget {
  const WhatsAroundMeButton({
    Key? key,
    required GoogleMapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "whats_around_me",
      child: Icon(
        Icons.explore_sharp, /// or Icons.emergency_share_sharp,
        color: Colors.white,
      ),
      backgroundColor: Colors.amber.shade400,
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
                'Please turn your location on in order to use this feature.'),
            duration: Duration(seconds: 3),
          ));
        } else {
          _mapController!.animateCamera(CameraUpdate.newLatLng(LatLng(
              Provider.of<MapsDataProvider>(context, listen: false)
                  .coordinates!
                  .lat!,
              Provider.of<MapsDataProvider>(context, listen: false)
                  .coordinates!
                  .lon!)));
        }
      },
    );
  }
}
