import 'package:campus_mobile_experimental/ui/whats_around_me/wam_description_page.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_provider.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_model.dart';
import 'package:provider/provider.dart';

/// Fetches necessary data to build the What's Around Me List using Provider.
class BuildWhatsAroundMeList extends StatelessWidget {
  final BuildContext context;
  final dynamic mapController;

  BuildWhatsAroundMeList({required this.context, required this.mapController});

  @override
  Widget build(BuildContext context) {
    /// TODO: Fetch all nearby places (names) of each category, each with its own list (first element being the closest)
    /// Use findAddressCandidates ArcGIS API







    /// TODO: Calculate the distance of every place and put them in a list
    /// i.e. fetchPLaceCoordinates(NearbyRestaurants[0])
    /// then use those coordinates to calculate the distance form the user
    /// RestaurantDistance[0] = getDistance(NearbyRestaurants[0].X, NearbyRestaurants[0].Y)
    /// use Distance ArcGIS API



    /// TODO: Get Busyness of every place and put them in a list - TBD


    return Container(
      color: Colors.amber,
      child: Center(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Center(
                child: const Text(
                  'What\'s Around Me',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ExpansionTile(
              title: Text(
                'Restaurants',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Nearest: NearbyRestaurants[0] - 0.01 mi'),
              children: <Widget>[
                ListTile(
                  title: Text('NearbyRestaurants[0] - Open: Closes 17:00'),
                  subtitle: Text('(Not too busy) - RestaurantDistance[0] mi'),
                  trailing: Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlaceDescriptionPage(
                            mapController: mapController,
                          )),
                    );
                  },
                ),
                ListTile(
                  title: Text('NearbyRestaurants[1] - Open: Closes 17:00'),
                  subtitle: Text('(Busy) - RestaurantDistance[1] mi'),
                  trailing: Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlaceDescriptionPage(
                            mapController: mapController,
                          )),
                    );
                  },
                ),
                ListTile(
                  title: Text('NearbyRestaurants[2] - Open: Closes 17:00 '),
                  subtitle: Text('(Not busy) - RestaurantDistance[2] mi'),
                  trailing: Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlaceDescriptionPage(
                            mapController: mapController,
                          )),
                    );
                  },
                ),
                ListTile(
                  title: Text('NearbyRestaurants[3] - Open: Closes 17:00'),
                  subtitle: Text('(Very busy) - RestaurantDistance[3] mi'),
                  trailing: Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlaceDescriptionPage(
                            mapController: mapController,
                          )),
                    );
                  },
                ),
                ListTile(
                  title: Text('NearbyRestaurants[4] - Open: Closes 17:00'),
                  subtitle: Text('(Not Busy) - RestaurantDistance[4] mi'),
                  trailing: Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlaceDescriptionPage(
                            mapController: mapController,
                          )),
                    );
                  },
                ),
              ],
            ),
            ElevatedButton(
              child: const Text('Close List'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}