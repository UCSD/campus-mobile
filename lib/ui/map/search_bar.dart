import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/ui/map/map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class SearchBar extends StatelessWidget {
  final void Function() fetchLocations;
  final TextEditingController searchBarController;
  final Map<MarkerId, Marker> markers;

  const SearchBar({
    Key? key,
    required this.fetchLocations,
    required this.searchBarController,
    required this.markers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back),
            padding: EdgeInsets.symmetric(horizontal: 9),
            alignment: Alignment.centerLeft,
            iconSize: 30,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: TextField(
              textInputAction: TextInputAction.search,
              onChanged: (text) {},
              onSubmitted: (text) {
                if (searchBarController.text.isNotEmpty) {
                  // Don't fetch on empty text field
                  /// TODO
                  fetchLocations(); // Text doesn't need to be sent over because it's already in the controller
                }
                Navigator.pop(context);
              },
              autofocus: true,
              controller: searchBarController,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                hintText: 'Search',
              ),
            ),
          ),
          searchBarController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchBarController.clear();
                    markers.clear();
                  },
                )
              : Container(height: 0)
        ],
      ),
    );
  }
}
