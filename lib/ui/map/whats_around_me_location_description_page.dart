import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers/map.dart';
import 'directions_button.dart';

/// Upon clicking a location in the What's Around Me list,
/// This File will fetch all the necessary data to build the
/// location description page.
class LocationDescriptionPage extends StatelessWidget {
  const LocationDescriptionPage({
    Key? key,
    required GoogleMapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Description'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/images/bk_test_image.png'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Location Name
                  Text(
                    'Burger King',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  /// Review Portion
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange),
                      Text('3.3 (182)', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 8),
                  /// Location Details
                  Text(
                    'Fast Food Restaurant',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  /// List Data
                  Text(
                    '(Not too busy) · 0.01 mi',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  /// Open? Until when?
                  Row(
                    children: [
                      Text(
                        'Open · Closes 17:00',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  /// Middle buttons Bar ///
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      /// Walking Navigation
                      Column(
                        children: [
                          DirectionsButton(
                            mapController: Provider.of<MapsDataProvider>(context).mapController,
                          ),
                          SizedBox(height: 10),
                          Text('Directions'),
                        ],
                      ),
                      /// Busyness
                      Column(
                        children: [
                          Icon(Icons.bar_chart),
                          Text('Busyness'),
                        ],
                      ),
                      /// Location's Phone Number
                      Column(
                        children: [
                          Icon(Icons.call),
                          Text('Call'),
                        ],
                      ),
                    ],
                  ),
                  Divider(height: 32),
                  /// Location Description
                  Text(
                    'Well-known fast-food chain serving grilled burgers, fries & shakes.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  /// Location Address
                  Row(
                    children: [
                      Icon(Icons.location_on),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '9500 Gilman Dr, San Diego, CA 92093',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  /// Location Hours
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: ExpansionTile(
                          title: Row(
                            children: <Widget>[
                              Icon(Icons.access_time),
                              SizedBox(width: 8), // Adds space between the icon and the text
                              Text('Location Hours'),
                            ],
                          ),
                          children: <Widget>[
                            ListTile(
                              title: Row(
                                children: <Widget>[
                                  Expanded(child: Text('Sunday')),
                                  Text('10:00-15:00'),
                                ],
                              ),
                            ),
                            ListTile(
                              title: Row(
                                children: <Widget>[
                                  Expanded(child: Text('Monday')),
                                  Text('10:00-15:00'),
                                ],
                              ),
                            ),
                            ListTile(
                              title: Row(
                                children: <Widget>[
                                  Expanded(child: Text('Tuesday')),
                                  Text('10:00-15:00'),
                                ],
                              ),
                            ),
                            ListTile(
                              title: Row(
                                children: <Widget>[
                                  Expanded(child: Text('Wednesday')),
                                  Text('10:00-15:00'),
                                ],
                              ),
                            ),
                            ListTile(
                              title: Row(
                                children: <Widget>[
                                  Expanded(child: Text('Thursday')),
                                  Text('10:00-15:00'),
                                ],
                              ),
                            ),
                            ListTile(
                              title: Row(
                                children: <Widget>[
                                  Expanded(child: Text('Friday')),
                                  Text('10:00-15:00'),
                                ],
                              ),
                            ),
                            ListTile(
                              title: Row(
                                children: <Widget>[
                                  Expanded(child: Text('Saturday')),
                                  Text('10:00-15:00'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  /// Location Website
                  Row(
                    children: [
                      Icon(Icons.web),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          const url = 'https://www.burgerking.com';
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            // Handle the error
                            throw 'Could not launch $url';
                          }
                        },
                        child: Text(
                          'burgerking.com',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,  // Optional: Make the text look like a link
                            decoration: TextDecoration.underline,  // Optional: Add an underline to the text
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  /// $ Approximate
                  Row(
                    children: [
                      Icon(Icons.attach_money),
                      SizedBox(width: 8),
                      Text(
                        '\$1–10 per person',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}