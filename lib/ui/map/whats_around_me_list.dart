import 'package:campus_mobile_experimental/ui/map/whats_around_me_location_description_page.dart';
import 'package:flutter/material.dart';

/// Fetches all the necessary data to build the What's Around Me List.
class BuildWhatsAroundMeList extends StatelessWidget {
  final BuildContext context;
  final dynamic mapController; // Replace 'dynamic' with the correct type

  BuildWhatsAroundMeList({required this.context, required this.mapController});

  @override
  Widget build(BuildContext context) {
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
              subtitle: Text('Nearest: Burger King - 0.01 mi'),
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
                          builder: (context) => LocationDescriptionPage(
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
                          builder: (context) => LocationDescriptionPage(
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
                          builder: (context) => LocationDescriptionPage(
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
                          builder: (context) => LocationDescriptionPage(
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
                          builder: (context) => LocationDescriptionPage(
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