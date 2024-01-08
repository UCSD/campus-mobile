import 'dart:ffi';

import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocationsList extends StatelessWidget {
  final String destination;

  const LocationsList({
    Key? key,
    required this.destination,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> autocompleteSugesstions =
        generateAutocompleteSuggestions();

    return Flexible(
      child: Card(
        margin: EdgeInsets.all(5),
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(height: 0),
          itemCount: autocompleteSugesstions.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              leading: Icon(Icons.location_pin),
              title: Text(autocompleteSugesstions[index]),
              onTap: () {
                Provider.of<MapsDataProvider>(context, listen: false)
                    .searchBarController
                    .text = autocompleteSugesstions[index];
                Provider.of<MapsDataProvider>(context, listen: false)
                    .fetchLocations();
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }

  List<String> generateAutocompleteSuggestions() {
    return locations
        .where((str) => str.toLowerCase().startsWith(
            destination.toLowerCase())) // maybe also check if it's a substring?
        .toList();
  }
}

final List<String> locations = [
  'Apple',
  'Banana',
  'Orange',
  'Grapes',
  'Mango',
  'Parking',
  'COVID Tests',
  'Hydration',
  'ATM',
];
