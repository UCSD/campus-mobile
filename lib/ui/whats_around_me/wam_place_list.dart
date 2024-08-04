import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_description_page.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_provider.dart';
import 'package:provider/provider.dart';

/// Fetches necessary data to build the What's Around Me List using Provider.
class BuildWhatsAroundMeList extends StatelessWidget {
  final BuildContext context;
  final dynamic mapController; // Replace 'dynamic' with the correct type

  BuildWhatsAroundMeList({required this.context, required this.mapController});

  @override
  Widget build(BuildContext context) {
    // String? data = LocationNameAddressDataProvider();
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
              subtitle: Text('Nearest: put data here - 0.01 mi'),
              children: <Widget>[
                ListTile(
                  title: Text('Burger King - Open: Closes 17:00'),
                  subtitle: Text('(Not too busy) - 0.01 mi'),
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
                  title: Text('Subway - Open: Closes 17:00'),
                  subtitle: Text('(Busy) - 0.02 mi'),
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
                  title: Text('Tapioca Express - Open: Closes 17:00 '),
                  subtitle: Text('(Not busy) - 0.02 mi'),
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
                  title: Text('Rubio\'s - Open: Closes 17:00'),
                  subtitle: Text('(Very busy) - 0.03 mi'),
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
                  title: Text('Panda Express - Open: Closes 17:00'),
                  subtitle: Text('(Not Busy) - 0.04 mi'),
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