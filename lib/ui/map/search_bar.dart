import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/ui/common/alert_dialog_widget.dart';

class MapSearchBar extends StatelessWidget {
  const MapSearchBar({
    Key? key,
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
                var searchText = Provider.of<MapsDataProvider>(context, listen: false)
                    .searchBarController
                    .text;
                if (searchText.length < 3) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialogWidget(
                          type: MessageTypeConstants.ERROR,
                          icon: Icons.block_flipped,
                          title: LoginConstants.mapSearchMinTitle,
                          description: LoginConstants.mapSearchMinDesc,
                          onClose: () {
                            Navigator.of(context).pop();
                          },
                        );
                      }
                      );
                  return;
                }
                if (searchText.isNotEmpty){
                  Provider.of<MapsDataProvider>(context, listen: false)
                      .fetchLocations();
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
