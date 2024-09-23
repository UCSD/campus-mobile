import 'package:campus_mobile_experimental/ui/whats_around_me/wam_details_page.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_list_provider.dart';
import 'package:provider/provider.dart';

/// Fetches Nearby Places using the student's current location to build the What's Around Me List.
class BuildWhatsAroundMeList extends StatefulWidget {
  final dynamic mapController;

  BuildWhatsAroundMeList({required this.mapController, required BuildContext context});

  @override
  _BuildWhatsAroundMeListState createState() => _BuildWhatsAroundMeListState();
}

class _BuildWhatsAroundMeListState extends State<BuildWhatsAroundMeList> {
  late PlacesByCategoryProvider _placesByCategoryProvider;

  // Category Ids (Constants) to fetch nearby places from
  final Map<String, String> categories = {
    "Art": "", // exhibitions, stuart collection
    "ATMs": "",
    "Bathrooms": "",
    "Book Stores": "",
    "Coffee Shops": "13032",
    "Constructions": "",
    "Dining Halls": "",
    "Gym & Fitness": "",
    "Health": "",
    "Lecture Halls": "",
    "Libraries": "",
    "Live Events": "",
    "Major Buildings": "",
    "Markets": "",
    "Microwaves": "",
    "Parking": "",
    "Research Centers": "",
    "Restaurants": "13065",
    "Stores": "",
    "Student Care": "",
    "Student Housing": "",
    "Student Lounges": "",
    "Student Organizations": "",
    "Student Resources": "",
    "Theaters": "",
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _placesByCategoryProvider = Provider.of<PlacesByCategoryProvider>(context);
    _fetchAllCategories();
  }

  Future<void> _fetchAllCategories() async {
    for (var id in categories.values) {
      if (id.isNotEmpty) {
        await _placesByCategoryProvider.fetchPlacesByCategory(id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlacesByCategoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading == true) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }

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
                ...categories.entries.map((entry) {
                  String category = entry.key;
                  String categoryId = entry.value;
                  var nearbyPlaces = provider.getPlacesByCategory(categoryId);

                  return ExpansionTile(
                    title: Text(
                      category,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      nearbyPlaces?.isNotEmpty == true
                          ? 'Nearest: ${nearbyPlaces![0].name} - ${nearbyPlaces[0].distance?.toStringAsFixed(2)} mi'
                          : 'No places found',
                    ),
                    children: nearbyPlaces?.map((place) {
                      return ListTile(
                        title: Text('${place.name} - Open: Closes 17:00'),
                        subtitle: Text('(Not too busy) - ${place.distance?.toStringAsFixed(2)} mi'),
                        trailing: Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaceDetailsPage(
                                mapController: widget.mapController,
                                placeId: place.placeId!, // Pass in the placeId also contained in response
                              ),
                            ),
                          );
                        },
                      );
                    }).toList() ?? [],
                  );
                }).toList(),
                ElevatedButton(
                  child: const Text('Close List'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// OLD VERSIONS - DO NOT DELETE UNTIL ENSURING FUNCTIONALITY OF THE ABOVE AFTER JACK ENABLES ACCESS TO APIs //
// import 'package:campus_mobile_experimental/ui/whats_around_me/wam_details_page.dart';
// import 'package:flutter/material.dart';
// import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_list_provider.dart';
// import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_list_model.dart';
// import 'package:provider/provider.dart';
//
// /// Fetches Nearby Places using the student's current location to build the What's Around Me List.
// class BuildWhatsAroundMeList extends StatelessWidget {
//   final BuildContext context;
//   final dynamic mapController;
//
//   BuildWhatsAroundMeList({required this.context, required this.mapController});
//
//   // Category Ids (Constants) to fetch nearby places from
//   final restaurantsArcGISCategoryId = "13065";
//
//   @override
//   Widget build(BuildContext context) {
//     final _placesByCategoryProvider = Provider.of<PlacesByCategoryProvider>(context);
//
//     // Fetch data
//     _placesByCategoryProvider.fetchPlacesByCategory(restaurantsArcGISCategoryId);
//
//     // Check if loading or error
//     if (_placesByCategoryProvider.isLoading == true) {
//       return Center(child: CircularProgressIndicator());
//     }
//
//     if (_placesByCategoryProvider.error != null) {
//       return Center(child: Text('Error: ${_placesByCategoryProvider.error}'));
//     }
//
//     // Get the list of nearby restaurants
//     final nearbyRestaurants = _placesByCategoryProvider.placeDetailsModelData.results;
//
//     return Container(
//       color: Colors.amber,
//       child: Center(
//         child: ListView(
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.only(top: 20.0),
//               child: Center(
//                 child: const Text(
//                   'What\'s Around Me',
//                   style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             ExpansionTile(
//               title: Text(
//                 'Restaurants',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               subtitle: Text(
//                 'Nearest: ${nearbyRestaurants?.isNotEmpty == true ? nearbyRestaurants![0].name : 'No restaurants found'} - 0.01 mi',
//               ),
//               children: nearbyRestaurants?.map((restaurant) {
//                 return ListTile(
//                   title: Text('${restaurant.name} - Open: Closes 17:00'),
//                   subtitle: Text('(Not too busy) - ${restaurant.distance?.toStringAsFixed(2)} mi'),
//                   trailing: Icon(
//                     Icons.arrow_forward,
//                     color: Colors.black,
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => PlaceDetailsPage(
//                           mapController: mapController,
//                           placeId: restaurant.placeId!,
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               }).toList() ?? [],
//             ),
//             ElevatedButton(
//               child: const Text('Close List'),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:campus_mobile_experimental/ui/whats_around_me/wam_details_page.dart';
// import 'package:flutter/material.dart';
// import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_list_provider.dart';
// import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_list_model.dart';
// import 'package:provider/provider.dart';
// /// TODO FIX skeleton
// /// Fetches Nearby Places using the student's current location to build the What's Around Me List.
// class BuildWhatsAroundMeList extends StatelessWidget {
//   final BuildContext context;
//   final dynamic mapController;
//   BuildWhatsAroundMeList({required this.context, required this.mapController});
//   // Category Ids (Constants) to fetch nearby places from
//   final artArcGISCategoryId = ""; // exhibitions, stuart collection
//   final atmArcGISCategoryId = "";
//   final bathroomsArcGISCategoryId = "";
//   final bookStoresArcGISCategoryId = "";
//   final coffeeShopsArcGISCategoryId = "13032";
//   final constructionsArcGISCategoryId = "";
//   final dinningHallsArcGISCategoryId = "";
//   final gymAndFitnessArcGISCategoryId = "";
//   final healthArcGISCategoryId = ""; // ship, cvs, hospitals
//   final lectureHallsArcGISCategoryId = "";
//   final librariesArcGISCategoryId = "";
//   final liveEventsArcGISCategoryId = "";
//   final majorBuildingsArcGISCategoryId = "";
//   final marketsArcGISCategoryId = "";
//   final microwavesArcGISCategoryId = "";
//   final parkingArcGISCategoryId = "";
//   final researchCentersArcGISCategoryId = "";
//   final restaurantsArcGISCategoryId = "13065";
//   final storesArcGISCategoryId = ""; // bookstores, retail, target
//   final studentCareArcGISCategoryId = "";
//   final studentHousingArcGISCategoryId = "";
//   final studentLoungesArcGISCategoryId = "";
//   final studentOrganizationsArcGISCategoryId = "";
//   final studentResourcesArcGISCategoryId = "";
//   final theatersArcGISCategoryId = "";
//
//   @override
//   Widget build(BuildContext context) {
//     // Instantiate the provider to get a list of nearby places of an x category
//     final _placesByCategoryProvider = Provider.of<PlacesByCategoryProvider>(context);
//     // Fetch all lists from each category using the list provider
//     // i.e. List<Results?> nearbyRestaurants = _listProvider.fetchPlacesByCategory(restaurantArcGISCategoryId); DO THIS FOR EACH CATEGORY
//     var nearbyArt = _placesByCategoryProvider.fetchPlacesByCategory(artArcGISCategoryId); // exhibitions, stuart collection
//     var nearbyAtm = _placesByCategoryProvider.fetchPlacesByCategory(atmArcGISCategoryId);
//     var nearbyBathrooms = _placesByCategoryProvider.fetchPlacesByCategory(bathroomsArcGISCategoryId);
//     var nearbyBookStores = _placesByCategoryProvider.fetchPlacesByCategory(bookStoresArcGISCategoryId);
//     var nearbyCoffeeShops = _placesByCategoryProvider.fetchPlacesByCategory(coffeeShopsArcGISCategoryId);
//     var nearbyConstructions = _placesByCategoryProvider.fetchPlacesByCategory(constructionsArcGISCategoryId);
//     var nearbyDinningHalls = _placesByCategoryProvider.fetchPlacesByCategory(dinningHallsArcGISCategoryId);
//     var nearbyGymAndFitness = _placesByCategoryProvider.fetchPlacesByCategory(gymAndFitnessArcGISCategoryId);
//     var nearbyHealth = _placesByCategoryProvider.fetchPlacesByCategory(healthArcGISCategoryId); // ship, cvs, hospitals
//     var nearbyLectureHalls = _placesByCategoryProvider.fetchPlacesByCategory(lectureHallsArcGISCategoryId);
//     var nearbyLibraries = _placesByCategoryProvider.fetchPlacesByCategory(librariesArcGISCategoryId);
//     var nearbyLiveEvents = _placesByCategoryProvider.fetchPlacesByCategory(liveEventsArcGISCategoryId);
//     var nearbyMajorBuildings = _placesByCategoryProvider.fetchPlacesByCategory(majorBuildingsArcGISCategoryId);
//     var nearbyMarkets = _placesByCategoryProvider.fetchPlacesByCategory(marketsArcGISCategoryId);
//     var nearbyMicrowaves = _placesByCategoryProvider.fetchPlacesByCategory(microwavesArcGISCategoryId);
//     var nearbyParking = _placesByCategoryProvider.fetchPlacesByCategory(parkingArcGISCategoryId);
//     var nearbyResearchCenters = _placesByCategoryProvider.fetchPlacesByCategory(researchCentersArcGISCategoryId);
//     var nearbyRestaurants = _placesByCategoryProvider.fetchPlacesByCategory(restaurantsArcGISCategoryId);
//     var nearbyStores = _placesByCategoryProvider.fetchPlacesByCategory(storesArcGISCategoryId); // bookstores, retail, target
//     var nearbyStudentCare = _placesByCategoryProvider.fetchPlacesByCategory(studentCareArcGISCategoryId);
//     var nearbyStudentHousing = _placesByCategoryProvider.fetchPlacesByCategory(studentHousingArcGISCategoryId);
//     var nearbyStudentLounges = _placesByCategoryProvider.fetchPlacesByCategory(studentLoungesArcGISCategoryId);
//     var nearbyStudentOrganizations = _placesByCategoryProvider.fetchPlacesByCategory(studentOrganizationsArcGISCategoryId);
//     var nearbyStudentResources = _placesByCategoryProvider.fetchPlacesByCategory(studentResourcesArcGISCategoryId);
//     var nearbyTheaters = _placesByCategoryProvider.fetchPlacesByCategory(theatersArcGISCategoryId);
//     // THEN FEED THE LIST BELOW WITH THAT DATA
//     return Container(
//       color: Colors.amber,
//       child: Center(
//         child: ListView(
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.only(top: 20.0),
//               child: Center(
//                 child: const Text(
//                   'What\'s Around Me',
//                   style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             ExpansionTile(
//               title: Text(
//                 'Restaurants',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               subtitle: Text('Nearest: ${_placesByCategoryProvider.fetchPlacesByCategory(restaurantsArcGISCategoryId)} - 0.01 mi'),
//               children: <Widget>[
//                 ListTile(
//                   title: Text('NearbyRestaurants[0] - Open: Closes 17:00'),
//                   subtitle: Text('(Not too busy) - RestaurantDistance[0] mi'),
//                   trailing: Icon(
//                     Icons.arrow_forward,
//                     color: Colors.black,
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => PlaceDetailsPage(
//                             mapController: mapController,
//                             placeId: "bd5f5dfa788b7c5f59f3bfe2cc3d9c60",
//                           )),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   title: Text('NearbyRestaurants[1] - Open: Closes 17:00'),
//                   subtitle: Text('(Busy) - RestaurantDistance[1] mi'),
//                   trailing: Icon(
//                     Icons.arrow_forward,
//                     color: Colors.black,
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => PlaceDetailsPage(
//                             mapController: mapController,
//                             placeId: "bd5f5dfa788b7c5f59f3bfe2cc3d9c60",
//                           )),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   title: Text('NearbyRestaurants[2] - Open: Closes 17:00 '),
//                   subtitle: Text('(Not busy) - RestaurantDistance[2] mi'),
//                   trailing: Icon(
//                     Icons.arrow_forward,
//                     color: Colors.black,
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => PlaceDetailsPage(
//                             mapController: mapController,
//                             placeId: "bd5f5dfa788b7c5f59f3bfe2cc3d9c60",  // PLACE HOLDER, MAKE DYNAMIC SO THAT It's always the right place (maybe another service function? (i.e. get place id) or maybe it is already inside the response json... find out)
//                           )),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   title: Text('NearbyRestaurants[3] - Open: Closes 17:00'),
//                   subtitle: Text('(Very busy) - RestaurantDistance[3] mi'),
//                   trailing: Icon(
//                     Icons.arrow_forward,
//                     color: Colors.black,
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => PlaceDetailsPage(
//                             mapController: mapController,
//                             placeId: "bd5f5dfa788b7c5f59f3bfe2cc3d9c60",
//                           )),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   title: Text('NearbyRestaurants[4] - Open: Closes 17:00'),
//                   subtitle: Text('(Not Busy) - RestaurantDistance[4] mi'),
//                   trailing: Icon(
//                     Icons.arrow_forward,
//                     color: Colors.black,
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => PlaceDetailsPage(
//                             mapController: mapController,
//                             placeId: "bd5f5dfa788b7c5f59f3bfe2cc3d9c60",
//                           )),
//                     );
//                   },
//                 ),
//               ],
//             ),
//             ElevatedButton(
//               child: const Text('Close List'),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//   // Instantiate the provider to get nearby places of an x category
//     final _placesByCategoryProvider = Provider.of<PlacesByCategoryProvider>(context);
//     _placesByCategoryProvider.fetchPlacesByCategory(restaurantArcGISCategoryId);
//
//     return Scaffold( // Added Scaffold here
//       appBar: AppBar(
//         title: Text("What's Around Me"),
//       ),
//       body: Container(
//         color: Colors.amber,
//         child: Center(
//           child: ListView(
//             children: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.only(top: 20.0),
//                 child: Center(
//                   child: const Text(
//                     'What\'s Around Me',
//                     style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//               ExpansionTile(
//                 title: Text(
//                   'Restaurants',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: Text('Nearest: NearbyRestaurants[0] - 0.01 mi'),
//                 children: <Widget>[
//                   ListTile(
//                     title: Text('NearbyRestaurants[0] - Open: Closes 17:00'),
//                     subtitle: Text('(Not too busy) - RestaurantDistance[0] mi'),
//                     trailing: Icon(
//                       Icons.arrow_forward,
//                       color: Colors.black,
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => PlaceDetailsPage(
//                             mapController: mapController,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   ListTile(
//                     title: Text('NearbyRestaurants[1] - Open: Closes 17:00'),
//                     subtitle: Text('(Busy) - RestaurantDistance[1] mi'),
//                     trailing: Icon(
//                       Icons.arrow_forward,
//                       color: Colors.black,
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => PlaceDetailsPage(
//                               mapController: mapController,
//                             )),
//                       );
//                     },
//                   ),
//                   ListTile(
//                     title: Text('NearbyRestaurants[2] - Open: Closes 17:00 '),
//                     subtitle: Text('(Not busy) - RestaurantDistance[2] mi'),
//                     trailing: Icon(
//                       Icons.arrow_forward,
//                       color: Colors.black,
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => PlaceDetailsPage(
//                               mapController: mapController,
//                             )),
//                       );
//                     },
//                   ),
//                   ListTile(
//                     title: Text('NearbyRestaurants[3] - Open: Closes 17:00'),
//                     subtitle: Text('(Very busy) - RestaurantDistance[3] mi'),
//                     trailing: Icon(
//                       Icons.arrow_forward,
//                       color: Colors.black,
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => PlaceDetailsPage(
//                               mapController: mapController,
//                             )),
//                       );
//                     },
//                   ),
//                   ListTile(
//                     title: Text('NearbyRestaurants[4] - Open: Closes 17:00'),
//                     subtitle: Text('(Not Busy) - RestaurantDistance[4] mi'),
//                     trailing: Icon(
//                       Icons.arrow_forward,
//                       color: Colors.black,
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => PlaceDetailsPage(
//                               mapController: mapController,
//                             )),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               ElevatedButton(
//                 child: const Text('Close List'),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
