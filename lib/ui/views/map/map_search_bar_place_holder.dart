import 'package:campus_mobile_experimental/core/data_providers/maps_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapSearchBarPlaceHolder extends StatelessWidget {
  const MapSearchBarPlaceHolder({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Provider.of<MapsDataProvider>(context).isLoading
              ? Padding(
                  padding: const EdgeInsets.all(2.5),
                  child: Container(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator()),
                )
              : Icon(
                  Icons.search,
                  size: 30,
                ),
        ),
        Expanded(
          child: TextField(
            enabled: false,
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
      ],
    );
  }
}
