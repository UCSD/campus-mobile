import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/whats_around_me/wam_place_list_provider.dart';
import 'package:provider/provider.dart';

class BuildWhatsAroundMeList extends StatefulWidget {
  final dynamic mapController;

  BuildWhatsAroundMeList({required this.mapController, required BuildContext context});

  @override
  _BuildWhatsAroundMeListState createState() => _BuildWhatsAroundMeListState();
}

class _BuildWhatsAroundMeListState extends State<BuildWhatsAroundMeList> {
  @override
  void initState() {
    super.initState();
    // Fetch the categories when the widget initializes
    Provider.of<PlacesByCategoryProvider>(context, listen: false)
        .fetchWhatsAroundYou();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlacesByCategoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading == true) {
          return Center(child: CircularProgressIndicator());
        } else if (provider.error != null) {
          return Center(child: Text("Error: ${provider.error}"));
        } else if (provider.categoriesAroundMe == null ||
            provider.categoriesAroundMe!.isEmpty) {
          print("Here's why categories are not found");
          print(provider.categoriesAroundMe);
          return Center(child: Text("No categories found"));
        } else {
          return Expanded(
            child: ListView.builder(
              itemCount: provider.categoriesAroundMe!.length,
              itemBuilder: (context, index) {
                // Get the category for the current index
                final category = provider.categoriesAroundMe![index];

                // Access the category name and places
                final categoryName = category.categoryName ??
                    "Unknown Category";
                final places = category.places ?? {};

                return ExpansionTile(
                  title: Text(categoryName),
                  children: places.entries.map((entry) {
                    return ListTile(
                      title: Text(entry.value),
                    );
                  }).toList(),
                );
              },
            ),
          );
        }
      },
    );
  }
}

/**
 *  // Category Ids (Constants) to fetch nearby places from
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
 */
