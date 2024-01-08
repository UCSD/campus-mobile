import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchBar extends StatelessWidget {
  final Function(String) onTextChanged; // Callback for text changes

  const SearchBar({
    Key? key,
    required this.onTextChanged,
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
              onChanged: (text) {
                onTextChanged(text);
              },
              onSubmitted: (text) {
                if (Provider.of<MapsDataProvider>(context, listen: false)
                    .searchBarController
                    .text
                    .isNotEmpty) {
                  // Don't fetch on empty text field
                  Provider.of<MapsDataProvider>(context, listen: false)
                      .fetchLocations(); // Text doesn't need to be sent over because it's already in the controller
                }
                Navigator.pop(context);
              },
              autofocus: true,
              controller:
                  Provider.of<MapsDataProvider>(context).searchBarController,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                hintText: 'Search',
              ),
            ),
          ),
          Provider.of<MapsDataProvider>(context)
                  .searchBarController
                  .text
                  .isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    Provider.of<MapsDataProvider>(context, listen: false)
                        .searchBarController
                        .clear();
                    Provider.of<MapsDataProvider>(context, listen: false)
                        .markers
                        .clear();
                  },
                )
              : Container(height: 0)
        ],
      ),
    );
  }
}
