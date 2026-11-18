import 'dart:async';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/ui/map/directions_button.dart';
import 'package:campus_mobile_experimental/ui/map/map_search_bar_ph.dart';
import 'package:campus_mobile_experimental/ui/map/map_search_feedback.dart';
import 'package:campus_mobile_experimental/ui/map/more_results_list.dart';
import 'package:campus_mobile_experimental/ui/map/my_location_button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';

class Maps extends StatefulWidget {
  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  StreamSubscription<Uri>? _linkSubscription;
  bool _mapInitialized = false;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    // Warm the native map after the app has laid out its full viewport.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _mapInitialized = true);
      initUniLinks();
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Widget resultsList(BuildContext context) =>
      Provider.of<MapsDataProvider>(context).markers.isNotEmpty ? MoreResultsList() : const SizedBox.shrink();

  Widget buildButtons(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: height * 0.05,
      right: width * 0.05,
      child: Column(
        children: [
          MyLocationButton(mapController: Provider.of<MapsDataProvider>(context).mapController),
          SizedBox(height: 10),
          DirectionsButton(),
        ],
      ),
    );
  }

  Future<void> initUniLinks() async {
    final appLinks = AppLinks();
    final initialUri = await appLinks.getInitialAppLink();
    if (!mounted) return;
    _handleMapLink(initialUri);
    _linkSubscription = appLinks.uriLinkStream.listen(_handleMapLink);
  }

  void _handleMapLink(Uri? uri) {
    if (!mounted || uri == null || !uri.toString().contains('deeplinking.searchmap')) return;
    final query = uri.queryParameters['query'];
    if (query == null) return;
    final mapsProvider = context.read<MapsDataProvider>();
    mapsProvider.searchBarController.text = query;
    mapsProvider.fetchLocations();
    context.read<BottomNavigationBarProvider>().currentIndex = NavigatorConstants.MAP_TAB;
  }

  @override
  Widget build(BuildContext context) {
    final isMapTab = context.select<BottomNavigationBarProvider, bool>(
      (provider) => provider.currentIndex == NavigatorConstants.MAP_TAB,
    );
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // Reserve the full viewport even before the native map is created.
        Positioned.fill(
          child: _mapInitialized
              ? GoogleMap(
                  markers: Set<Marker>.of(Provider.of<MapsDataProvider>(context).markers.values),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) {
                    if (!mounted) return;
                    final mapsProvider = context.read<MapsDataProvider>();
                    mapsProvider.mapController = controller;
                    mapsProvider.updateMapPosition();
                    setState(() => _mapReady = true);
                  },
                  initialCameraPosition: CameraPosition(target: const LatLng(32.8801, -117.2341), zoom: 14.5),
                )
              : const SizedBox.expand(),
        ),
        if (isMapTab && !_mapReady)
          const Positioned.fill(
            child: IgnorePointer(
              child: Center(child: CircularProgressIndicator(semanticsLabel: 'Loading map')),
            ),
          ),
        const Positioned(top: 0, left: 0, right: 0, child: MapSearchBarPlaceHolder()),
        buildButtons(context),
        resultsList(context),
        const MapSearchFeedback(),
      ],
    );
  }
}
