import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/spot_types.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/ui/common/HexColor.dart';
import 'package:campus_mobile_experimental/ui/common/alert_dialog_widget.dart';
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
  late UserDataProvider _userDataProvider;

  @override
  Widget build(BuildContext context) {
    spotTypesDataProvider = Provider.of<ParkingDataProvider>(context);
    _userDataProvider = Provider.of<UserDataProvider>(context);
    return ContainerView(child: createListWidget(context));
  }

  Widget createListWidget(BuildContext context) =>
      ListView(children: createList(context));

  List<Widget> createList(BuildContext context) {
    var selectedSpots = 0;
    List<Widget> list = [];
    for (Spot data in spotTypesDataProvider.spotTypeModel!.spots!) {
      if (Provider.of<ParkingDataProvider>(context)
              .spotTypesState[data.spotKey]! ==
          true) {
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
          value: Provider.of<ParkingDataProvider>(context)
              .spotTypesState[data.spotKey]!,
          onChanged: (bool isOn) {
            if (isOn &&
                spotTypesDataProvider.selectedSpots >
                    ParkingDataProvider.MAX_SELECTED_SPOTS) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialogWidget(
                    type: MessageTypeConstants.ERROR,
                    icon: Icons.block_flipped,
                    title: ParkingConstants.spotMaxTitle,
                    description: ParkingConstants.spotMaxDesc,
                    onClose: () {
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            } else {
              spotTypesDataProvider.toggleSpotSelection(
                  data.spotKey, selectedSpots);
            }
          },
          // activeColor: Theme.of(context).buttonColor,
          activeColor: Theme.of(context).colorScheme.background,
        ),
      ));
    }
    return list;
  }
}
