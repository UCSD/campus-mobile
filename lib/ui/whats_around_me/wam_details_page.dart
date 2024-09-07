/// TODO: 1) After ensuring right place id gets passed,
/// 2) ensure data is being feed properly
/// 3) Use _mapController to ensure the directions button works
/// 4) Integrate Busyness API

import 'package:campus_mobile_experimental/ui/whats_around_me/wam_details_page_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app_constants.dart';
import '../../core/models/availability.dart';
import '../../core/providers/availability.dart';
import '../../core/providers/map.dart';
import '../availability/availability_constants.dart';
import '../map/directions_button.dart';
import 'wam_details_page_provider.dart';

/// Upon clicking a location in the What's Around Me list,
/// This File will fetch all the necessary data to build the location description page.
/// Using The Place Details ArcGIS API
class PlaceDetailsPage extends StatelessWidget {
  const PlaceDetailsPage({
    Key? key,
    required GoogleMapController? mapController,
    required this.placeId, required this.model,
  }) : _mapController = mapController, super(key: key);

  final GoogleMapController? _mapController;
  final String placeId; // i.e. "bd5f5dfa788b7c5f59f3bfe2cc3d9c60"
  /// Models
  final AvailabilityModel model;

  @override
  Widget build(BuildContext context) {
    late PlaceDetailsProvider _placeDetailsProvider = Provider.of<PlaceDetailsProvider>(context);
    late AvailabilityDataProvider _availabilityDataProvider = Provider.of<AvailabilityDataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Description'),
      ),
      body: FutureBuilder<PlaceDetailsModel?>(
        future: _placeDetailsProvider.fetchPlaceDetails(placeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show loading indicator
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Show error message
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available')); // Handle case with no data
          } else {
            final placeDetails = snapshot.data?.placeDetails;

            return SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset('assets/images/bk_test_image.png'),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location Name
                        Text(
                          'Location Name: ${placeDetails?.name ?? 'No data available'}',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),

                        // Review Portion
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.orange),
                            Text('${placeDetails?.rating?.user ?? 'N/A'} (182)',
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        SizedBox(height: 8),

                        // Location Details
                        Text(
                          '${placeDetails?.categories?.first.label ?? 'No data available'}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),

                        // List Data
                        Text(
                          '(Not too busy) · 0.01 mi',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),

                        // Open? Until when?
                        Row(
                          children: [
                            Text(
                              'Open · Closes ${placeDetails?.hours?.opening ?? 'N/A'}',
                              style: TextStyle(fontSize: 16, color: Colors.green),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Middle buttons Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Walking Navigation
                            Column(
                              children: [
                                DirectionsButton(
                                  mapController: Provider.of<MapsDataProvider>(context).mapController,
                                ),
                                SizedBox(height: 10),
                                Text('Directions'),
                              ],
                            ),
                            // Busyness
                            Column(
                              children: [
                                Icon(Icons.bar_chart),
                                Text('Busyness'),
                                buildAvailabilityBars(context)
                              ],
                            ),
                            // Location's Phone Number
                            Column(
                              children: [
                                Icon(Icons.call),
                                Text('Call'),
                              ],
                            ),
                          ],
                        ),
                        Divider(height: 32),

                        // Location Description
                        Text(
                          '${placeDetails?.description ?? 'No description available'}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),

                        // Location Address
                        Row(
                          children: [
                            Icon(Icons.location_on),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${placeDetails?.address?.streetAddress ?? 'No address available'}, ${placeDetails?.address?.locality ?? 'No locality available'}, ${placeDetails?.address?.region ?? 'No region available'}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Location Hours
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: ExpansionTile(
                                title: Row(
                                  children: <Widget>[
                                    Icon(Icons.access_time),
                                    SizedBox(width: 8),
                                    Text('Location Hours'),
                                  ],
                                ),
                                children: <Widget>[
                                  ListTile(
                                    title: Row(
                                      children: <Widget>[
                                        Expanded(child: Text('Sunday')),
                                        Text('${placeDetails?.hours?.opening ?? 'N/A'}'),
                                      ],
                                    ),
                                  ),
                                  ListTile(
                                    title: Row(
                                      children: <Widget>[
                                        Expanded(child: Text('Monday')),
                                        Text('${placeDetails?.hours?.opening ?? 'N/A'}'),
                                      ],
                                    ),
                                  ),
                                  ListTile(
                                    title: Row(
                                      children: <Widget>[
                                        Expanded(child: Text('Tuesday')),
                                        Text('${placeDetails?.hours?.opening ?? 'N/A'}'),
                                      ],
                                    ),
                                  ),
                                  ListTile(
                                    title: Row(
                                      children: <Widget>[
                                        Expanded(child: Text('Wednesday')),
                                        Text('${placeDetails?.hours?.opening ?? 'N/A'}'),
                                      ],
                                    ),
                                  ),
                                  ListTile(
                                    title: Row(
                                      children: <Widget>[
                                        Expanded(child: Text('Thursday')),
                                        Text('${placeDetails?.hours?.opening ?? 'N/A'}'),
                                      ],
                                    ),
                                  ),
                                  ListTile(
                                    title: Row(
                                      children: <Widget>[
                                        Expanded(child: Text('Friday')),
                                        Text('${placeDetails?.hours?.opening ?? 'N/A'}'),
                                      ],
                                    ),
                                  ),
                                  ListTile(
                                    title: Row(
                                      children: <Widget>[
                                        Expanded(child: Text('Saturday')),
                                        Text('${placeDetails?.hours?.opening ?? 'N/A'}'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Location Website
                        Row(
                          children: [
                            Icon(Icons.web),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                final url = placeDetails?.contactInfo?.website ?? 'https://example.com';
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                              child: Text(
                                '${placeDetails?.contactInfo?.website ?? 'No website available'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // $ Approximate
                        Row(
                          children: [
                            Icon(Icons.attach_money),
                            SizedBox(width: 8),
                            Text(
                              '${placeDetails?.rating?.price ?? 'N/A'} per person',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
  Widget buildAvailabilityBars(BuildContext context) {
    List<Widget> locations = [];
    // add any children the model contains to the listview
    if (model.subLocations!.isNotEmpty) {
      for (SubLocations subLocation in model.subLocations!) {
        locations.add(
          ListTile(
            onTap: () => subLocation.floors!.length > 0
                ? Navigator.pushNamed(
                context, RoutePaths.AvailabilityDetailedView,
                arguments: subLocation)
                : print('_handleIconClick: no subLocations'),
            visualDensity: VisualDensity.compact,
            trailing: subLocation.floors!.length > 0
                ? Icon(Icons.arrow_forward_ios_rounded)
                : null,
            title: Text(
              subLocation.name!,
              style: TextStyle(
                fontSize: LOCATION_FONT_SIZE,
              ),
            ),
            subtitle: Column(
              children: <Widget>[
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      (100 * percentAvailability(subLocation))
                          .toInt()
                          .toString() +
                          '% Busy',
                      // style: TextStyle(color: Colors.black),
                    )),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: PROGRESS_BAR_HEIGHT,
                    width: PROGRESS_BAR_WIDTH,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(BORDER_RADIUS),
                      child: LinearProgressIndicator(
                        value: percentAvailability(subLocation) as double?,
                        backgroundColor: Colors.grey[BACKGROUND_GREY_SHADE],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          setIndicatorColor(
                            percentAvailability(subLocation),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    // if no children, return an error container
    else {
      return Container(
        alignment: Alignment.center,
        child: Text(
          "Data Unavailable",
          style: TextStyle(fontSize: LOCATION_FONT_SIZE),
        ),
        padding: EdgeInsets.only(
          top: DATA_UNAVAILABLE_TOP_PADDING,
        ),
      );
    }
    locations =
        ListTile.divideTiles(tiles: locations, context: context).toList();

    return Flexible(
      child: Scrollbar(
        child: ListView(
          children: locations,
        ),
      ),
    );
  }

  num percentAvailability(SubLocations location) => location.percentage!;

  setIndicatorColor(num percentage) {
    if (percentage >= .75)
      return Colors.red;
    else if (percentage >= .25)
      return Colors.yellow;
    else
      return Colors.green;
  }
}


// class PlaceDetailsPage extends StatelessWidget {
//   const PlaceDetailsPage({
//     Key? key,
//     required GoogleMapController? mapController,
//     required this.placeId,
//   }) : _mapController = mapController, super(key: key);
//
//   final GoogleMapController? _mapController;
//   final String placeId; // i.e. "bd5f5dfa788b7c5f59f3bfe2cc3d9c60"
//
//   @override
//   Widget build(BuildContext context) {
//     print("GOT PLACE ID: " + placeId);
//     // Instantiate the provider to get API data
//     final _placeDetailsProvider = Provider.of<PlaceDetailsProvider>(context);
//     // Fetch location data
//     var responseBody = _placeDetailsProvider.fetchPlaceDetails(placeId);
//     // Once you finish the list, make a function that, given the name, it returns the place ID that will go here^
//
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Location Description'),
//         ),
//         body: Consumer<PlaceDetailsProvider>(
//             builder: (context, provider, child) {
//               if (provider.isLoading == true) {
//                 return Center(
//                     child: CircularProgressIndicator()); // Show loading indicator
//               } else if (provider.error != null) {
//                 return Center(child: Text(
//                     'Error: ${provider.error}')); // Show error message
//               } else {
//                 return SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       Image.asset('assets/images/bk_test_image.png'),
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Location Name
//                             Text(
//                               'Location Name: ${provider.placeDetailsModelData
//                                   ?? 'No data available'}',
//                               style: TextStyle(
//                                   fontSize: 24, fontWeight: FontWeight.bold),
//                             ),
//                             SizedBox(height: 8),
//
//                             /// Review Portion
//                             Row(
//                               children: [
//                                 Icon(Icons.star, color: Colors.orange),
//                                 Text('3.3 (182)',
//                                     style: TextStyle(fontSize: 16)),
//                               ],
//                             ),
//                             SizedBox(height: 8),
//
//                             /// Location Details
//                             Text(
//                               'Fast Food Restaurant',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                             SizedBox(height: 8),
//
//                             /// List Data
//                             Text(
//                               '(Not too busy) · 0.01 mi',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                             SizedBox(height: 8),
//
//                             /// Open? Until when?
//                             Row(
//                               children: [
//                                 Text(
//                                   'Open · Closes 17:00',
//                                   style: TextStyle(
//                                       fontSize: 16, color: Colors.green),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 16),
//
//                             /// Middle buttons Bar ///
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceAround,
//                               children: [
//
//                                 /// Walking Navigation
//                                 Column(
//                                   children: [
//                                     DirectionsButton(
//                                       mapController: Provider
//                                           .of<MapsDataProvider>(context)
//                                           .mapController,
//                                     ),
//                                     SizedBox(height: 10),
//                                     Text('Directions'),
//                                   ],
//                                 ),
//
//                                 /// Busyness
//                                 Column(
//                                   children: [
//                                     Icon(Icons.bar_chart),
//                                     Text('Busyness'),
//                                   ],
//                                 ),
//
//                                 /// Location's Phone Number
//                                 Column(
//                                   children: [
//                                     Icon(Icons.call),
//                                     Text('Call'),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             Divider(height: 32),
//
//                             /// Location Description
//                             Text(
//                               'Well-known fast-food chain serving grilled burgers, fries & shakes.',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                             SizedBox(height: 16),
//
//                             /// Location Address
//                             Row(
//                               children: [
//                                 Icon(Icons.location_on),
//                                 SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     '9500 Gilman Dr, San Diego, CA 92093',
//                                     style: TextStyle(fontSize: 16),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 16),
//
//                             /// Location Hours
//                             Row(
//                               children: <Widget>[
//                                 Flexible(
//                                   child: ExpansionTile(
//                                     title: Row(
//                                       children: <Widget>[
//                                         Icon(Icons.access_time),
//                                         SizedBox(width: 8),
//                                         // Adds space between the icon and the text
//                                         Text('Location Hours'),
//                                       ],
//                                     ),
//                                     children: <Widget>[
//                                       ListTile(
//                                         title: Row(
//                                           children: <Widget>[
//                                             Expanded(child: Text('Sunday')),
//                                             Text('10:00-15:00'),
//                                           ],
//                                         ),
//                                       ),
//                                       ListTile(
//                                         title: Row(
//                                           children: <Widget>[
//                                             Expanded(child: Text('Monday')),
//                                             Text('10:00-15:00'),
//                                           ],
//                                         ),
//                                       ),
//                                       ListTile(
//                                         title: Row(
//                                           children: <Widget>[
//                                             Expanded(child: Text('Tuesday')),
//                                             Text('10:00-15:00'),
//                                           ],
//                                         ),
//                                       ),
//                                       ListTile(
//                                         title: Row(
//                                           children: <Widget>[
//                                             Expanded(child: Text('Wednesday')),
//                                             Text('10:00-15:00'),
//                                           ],
//                                         ),
//                                       ),
//                                       ListTile(
//                                         title: Row(
//                                           children: <Widget>[
//                                             Expanded(child: Text('Thursday')),
//                                             Text('10:00-15:00'),
//                                           ],
//                                         ),
//                                       ),
//                                       ListTile(
//                                         title: Row(
//                                           children: <Widget>[
//                                             Expanded(child: Text('Friday')),
//                                             Text('10:00-15:00'),
//                                           ],
//                                         ),
//                                       ),
//                                       ListTile(
//                                         title: Row(
//                                           children: <Widget>[
//                                             Expanded(child: Text('Saturday')),
//                                             Text('10:00-15:00'),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 16),
//
//                             /// Location Website
//                             Row(
//                               children: [
//                                 Icon(Icons.web),
//                                 SizedBox(width: 8),
//                                 GestureDetector(
//                                   onTap: () async {
//                                     const url = 'https://www.burgerking.com';
//                                     if (await canLaunch(url)) {
//                                       await launch(url);
//                                     } else {
//                                       // Handle the error
//                                       throw 'Could not launch $url';
//                                     }
//                                   },
//                                   child: Text(
//                                     'burger king.com',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.blue,
//                                       // Optional: Make the text look like a link
//                                       decoration: TextDecoration
//                                           .underline, // Optional: Add an underline to the text
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 16),
//
//                             /// $ Approximate
//                             Row(
//                               children: [
//                                 Icon(Icons.attach_money),
//                                 SizedBox(width: 8),
//                                 Text(
//                                   '\$1–10 per person',
//                                   style: TextStyle(fontSize: 16),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//             }
//         )
//     );
//   }
// }