import 'package:campus_mobile_experimental/core/models/spot_types.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/ui/common/hex_color.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/ui/common/alert_dialog_widget.dart';

class SpotTypesView extends StatefulWidget {
  @override
  _SpotTypesViewState createState() => _SpotTypesViewState();
}

class _SpotTypesViewState extends State<SpotTypesView> {
  late ParkingDataProvider spotTypesDataProvider;

  @override
  Widget build(BuildContext context) {
    spotTypesDataProvider = Provider.of<ParkingDataProvider>(context);
    return ContainerView(child: createListWidget(context));
  }

  Widget createListWidget(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView(
          children: [
            for (int i = 0; i < createList(context).length; i++) ...[
              createList(context)[i],
              if (i != createList(context).length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? listTileDividerColorDark
                        : listTileDividerColorLight,
                    thickness: 1,
                    height: 0,
                  ),
                ),
            ]
          ],
        ),
      );

  List<Widget> createList(BuildContext context) {
    var selectedSpots =
        Provider.of<ParkingDataProvider>(context).spotTypesState.values.where((selected) => selected == true).length;

    List<Widget> list = [];

    for (Spot data in spotTypesDataProvider.spotTypeModel!.spots!) {
      var isSelected = Provider.of<ParkingDataProvider>(context).spotTypesState[data.spotKey]!;

      var iconColor = HexColor(data.logoBackgroundColor);
      var textColor = HexColor(data.logoTextColor);

      list.add(
        ListTile(
          key: Key(data.name.toString()),
          leading: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor,
              ),
              child: Align(
                  alignment: Alignment.center,
                  child: data.logoText.startsWith('icon - ')
                      ? Icon(ParkingConstants.STRING_TO_ICON_DATA[data.logoText] ?? Icons.error,
                          size: 25.0, color: textColor)
                      : (data.logoText.isNotEmpty
                          ? Text(
                              data.logoText,
                              style: TextStyle(
                                color: textColor,
                                fontFamily: 'Brix Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: 28,
                              ),
                            )
                          : SizedBox.shrink()))),
          title: Text(
            data.name,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: Transform.scale(
            scale: 0.9,
            child: CupertinoSwitch(
              value: isSelected,
              onChanged: (bool value) {
                if (!isSelected && selectedSpots >= 3) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialogWidget(
                        type: MessageTypeConstants.ERROR,
                        icon: Icons.block_flipped,
                        title: ParkingConstants.SPOT_MAX_TITLE,
                        description: ParkingConstants.SPOT_MAX_DESC,
                        onClose: () {
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                  return;
                }
                spotTypesDataProvider.toggleSpotSelection(data.spotKey, selectedSpots);
              },
              activeTrackColor: toggleActiveColor,
              inactiveTrackColor: Colors.grey.shade400,
            ),
          ),
        ),
      );
    }
    return list;
  }
}
