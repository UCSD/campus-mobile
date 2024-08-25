import 'package:campus_mobile_experimental/ui/whats_around_me/wam_details_page.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_provider.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_list_model.dart';
import 'package:provider/provider.dart';
/// TODO FIX skeleton
/// Fetches Nearby Places using the student's current location to build the What's Around Me List.
class BuildWhatsAroundMeList extends StatelessWidget {
  final BuildContext context;
  final dynamic mapController;
  BuildWhatsAroundMeList({required this.context, required this.mapController});
  // Category Ids (Constants) to fetch nearby places from
  final restaurantArcGISCategoryId = "13065";
  final lectureHallArcGISCategoryId = "";
  final parkingArcGISCategoryId = "";
  final coffeeShopArcGISCategoryId = "13032";
  final storesArcGISCategoryId = "";

  @override
  Widget build(BuildContext context) {
    // Fetch all lists from each category using the list provider
    // i.e. List<Results?> nearbyRestaurants = _listProvider.fetchPlacesByCategory(restaurantArcGISCategoryId); DO THIS FOR EACH CATEGORY
    // THEN FEED THE LIST BELOW WITH THAT DATA
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
                          builder: (context) => PlaceDetailsPage(
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
                          builder: (context) => PlaceDetailsPage(
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
                          builder: (context) => PlaceDetailsPage(
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
                          builder: (context) => PlaceDetailsPage(
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
                          builder: (context) => PlaceDetailsPage(
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