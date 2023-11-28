import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/map/quick_search_icons.dart';
import 'package:campus_mobile_experimental/ui/map/search_bar.dart';
import 'package:campus_mobile_experimental/ui/map/search_history_list.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'map.dart';

class MapSearchView extends StatelessWidget {
  final void Function() fetchLocations;
  final TextEditingController searchBarController;
  final Map<MarkerId, Marker> markers;
  final List<String> searchHistory;

  const MapSearchView({
    required this.fetchLocations,
    required this.searchBarController,
    required this.markers,
    required this.searchHistory,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: Column(
        children: <Widget>[
          Hero(
            tag: 'search_bar',
            child: SearchBar(
              fetchLocations: fetchLocations,
              searchBarController: searchBarController,
              markers: markers,
            ),
          ),
          QuickSearchIcons(
            fetchLocations: fetchLocations,
            searchBarController: searchBarController,
          ),
          Provider.of<MapsDataProvider>(context).searchHistory.isEmpty
              ? Card(
                  margin: EdgeInsets.all(5),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    child: Center(child: Text('You have no recent searches')),
                  ),
                )
              : SearchHistoryList(
                  fetchLocations: fetchLocations,
                  searchHistory: searchHistory,
                  searchBarController: searchBarController,
                )
        ],
      ),
    );
  }
}
