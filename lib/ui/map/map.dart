import 'dart:async';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/ui/map/directions_button.dart';
import 'package:campus_mobile_experimental/ui/map/map_search_bar_ph.dart';
import 'package:campus_mobile_experimental/ui/map/more_results_list.dart';
import 'package:campus_mobile_experimental/ui/map/my_location_button.dart';
import 'package:campus_mobile_experimental/ui/map/whats_around_me_button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uni_links2/uni_links.dart';

class Maps extends StatelessWidget {
  Widget resultsList(BuildContext context) {
    if (Provider.of<MapsDataProvider>(context).markers.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      });
      return MoreResultsList();
    } else if (Provider.of<MapsDataProvider>(context).noResults!) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
              SnackBar(content: Text('No results found for your search.')));
      });
    }
    return Container();
  }

  Widget buildButtons(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: height * 0.05,
      right: width * 0.05,
      child: Column(
        children: [
          MyLocationButton(
              mapController:
                  Provider.of<MapsDataProvider>(context).mapController),
          SizedBox(height: 10),
          WhatsAroundMeButton(
              mapController:
              Provider.of<MapsDataProvider>(context).mapController),
          SizedBox(height: 10),
          DirectionsButton(
              mapController:
                  Provider.of<MapsDataProvider>(context).mapController),
        ],
      ),
    );
  }

  Future<Null> initUniLinks(BuildContext context) async {
    // deep links are received by this method
    // the specific host needs to be added in AndroidManifest.xml and Info.plist
    // currently, this method handles executing custom map query
    late StreamSubscription _sub;
    _sub = linkStream.listen((String? link) async {
      // handling for map query
      if (link!.contains("deeplinking.searchmap")) {
        var uri = Uri.dataFromString(link);
        var query = uri.queryParameters['query']!;
        // redirect query to maps tab and search with query
        Provider.of<MapsDataProvider>(context, listen: false)
            .searchBarController
            .text = query;
        Provider.of<MapsDataProvider>(context, listen: false).fetchLocations();
        Provider.of<BottomNavigationBarProvider>(context, listen: false)
            .currentIndex = NavigatorConstants.MapTab;
        // received deeplink, cancel stream to prevent memory leaks
        _sub.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    initUniLinks(context);
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
        buildButtons(context),
        resultsList(context),
      ],
    );
  }
}
