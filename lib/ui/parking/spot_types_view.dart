import 'package:campus_mobile_experimental/core/models/spot_types.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/ui/common/HexColor.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'neighborhood_lot_view.dart';

class SpotTypesView extends StatefulWidget {
  @override
  _SpotTypesViewState createState() => _SpotTypesViewState();
}

class _SpotTypesViewState extends State<SpotTypesView> {
  /// PROVIDERS
  late ParkingDataProvider spotTypesDataProvider;

  @override
  Widget build(BuildContext context) {
    spotTypesDataProvider = Provider.of<ParkingDataProvider>(context);
    return ContainerView(child: createListWidget(context));
  }

  Widget createListWidget(BuildContext context) => ListView(children: createList(context));

  List<Widget> createList(BuildContext context) {
    var selectedSpots = 0;
    List<Widget> list = [];
    for (Spot data in spotTypesDataProvider.spotTypeModel!.spots!) {
      if (Provider.of<ParkingDataProvider>(context).spotTypesState[data.spotKey]! == true) {
        selectedSpots++;
      }
      var iconColor = HexColor(data.color);
      var textColor = HexColor(data.textColor);

      list.add(ListTile(
        key: Key(data.name.toString()),
        leading: Container(
            width: 35,
            height: 35,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor,
            ),
            child: Align(
                alignment: Alignment.center,
                child: data.text.contains("&#x267f;")
                    ? Icon(Icons.accessible,
                        size: 25.0, color: colorFromHex(data.textColor))
                    : Text(
                        data.text,
                        style: TextStyle(color: textColor),
                      ))),
        title: Text(data.name),
        trailing: Switch(
          value: Provider.of<ParkingDataProvider>(context).spotTypesState[data.spotKey]!,
          onChanged: (_) {
            spotTypesDataProvider.toggleSpotSelection(data.spotKey, selectedSpots);
          },
          // activeColor: Theme.of(context).buttonColor,
          activeColor: Theme.of(context).colorScheme.surface,
        ),
      ));
    }
    return list;
  }
}
