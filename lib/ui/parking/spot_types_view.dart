

import 'package:campus_mobile_experimental/core/models/spot_types.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/ui/common/HexColor.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SpotTypesView extends StatelessWidget {
  late ParkingDataProvider spotTypesDataProvider;
  @override
  Widget build(BuildContext context) {
    spotTypesDataProvider = Provider.of<ParkingDataProvider>(context);
    return ContainerView(
      child: createListWidget(context),
    );
  }

  Widget createListWidget(BuildContext context) {
    return ListView(children: createList(context));
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = [];
    for (Spot data in spotTypesDataProvider.spotTypeModel!.spots!) {
      Color iconColor = HexColor(data.color!);
      Color textColor = HexColor(data.textColor!);
      list.add(ListTile(
        key: Key(data.spotKey.toString()),
        leading: Container(
            width: 35,
            height: 35,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor,
            ),
            child: Align(
                alignment: Alignment.center,
                child: data.text!.contains("&#x267f;")
                    ? Icon(
                        Icons.accessible,
                        size: 25.0,
                      )
                    : Text(
                        data.text!,
                        style: TextStyle(color: textColor),
                      ))),
        title: Text(data.name!),
        trailing: Switch(
          value: Provider.of<ParkingDataProvider>(context)
              .spotTypesState![data.spotKey]!,
          onChanged: (_) {
            spotTypesDataProvider.toggleSpotSelection(data.spotKey);
          },
          activeColor: Theme.of(context).buttonColor,
        ),
      ));
    }
    return list;
  }
}
