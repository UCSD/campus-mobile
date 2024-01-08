import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/map/locations_list.dart';
import 'package:campus_mobile_experimental/ui/map/quick_search_icons.dart';
import 'package:campus_mobile_experimental/ui/map/search_bar.dart';
import 'package:campus_mobile_experimental/ui/map/search_history_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapSearchView extends StatefulWidget {
  @override
  State<MapSearchView> createState() => _MapSearchViewState();
}

class _MapSearchViewState extends State<MapSearchView> {
  bool displayLocationsList = false;
  String destination = "";

  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: Column(
        children: <Widget>[
          Hero(
            tag: 'search_bar',
            child: SearchBar(onTextChanged: (text) {
              setState(() {
                if (text.isEmpty) {
                  displayLocationsList = false;
                } else {
                  displayLocationsList = true;
                  destination = text;
                }
              });
            }),
          ),
          QuickSearchIcons(),
          displayLocationsList
              ? LocationsList(destination: destination)
              : Provider.of<MapsDataProvider>(context).searchHistory.isEmpty
                  ? Card(
                      margin: EdgeInsets.all(5),
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        child:
                            Center(child: Text('You have no recent searches')),
                      ),
                    )
                  : SearchHistoryList()
        ],
      ),
    );
  }
}
