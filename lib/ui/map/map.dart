import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/ui/map/map_search_bar_ph.dart';
import 'package:campus_mobile_experimental/ui/map/more_results_list.dart';
import 'package:campus_mobile_experimental/ui/map/my_location_button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Maps extends StatelessWidget {
  Widget resultsList(BuildContext context) {
    if (Provider.of<MapsDataProvider>(context).markers.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Scaffold.of(context).removeCurrentSnackBar();
      });
      return MoreResultsList();
    } else if (Provider.of<MapsDataProvider>(context).noResults) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
              SnackBar(content: Text('No results found for your search.')));
      });
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          markers: Set<Marker>.of(
              Provider.of<MapsDataProvider>(context).markers.values),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            Provider.of<MapsDataProvider>(context, listen: false)
                .mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: const LatLng(32.8801, -117.2341),
            zoom: 14.5,
          ),
        ),
        MapSearchBarPlaceHolder(),
        MyLocationButton(
            mapController:
                Provider.of<MapsDataProvider>(context).mapController),
        resultsList(context),
      ],
    );
  }
}
