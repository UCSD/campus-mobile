import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParkingLotsView extends StatefulWidget {
  @override
  _ParkingLotViewState createState() => _ParkingLotViewState();
}

class _ParkingLotViewState extends State<ParkingLotsView> {
  late ParkingDataProvider parkingDataProvider;
  var showedScaffold = false;

  @override
  Widget build(BuildContext context) {
    parkingDataProvider = Provider.of<ParkingDataProvider>(context);
    return ContainerView(child: parkingLotsList(context));
  }

  Widget parkingLotsList(BuildContext context) {
    List<String> lots = Provider.of<ParkingDataProvider>(context).getLots();

    List<Widget> listTiles = [];
    listTiles.add(
      ListTile(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(
            "Parking Lots",
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: lightPrimaryColor),
          ),
        ),
      ),
    );

    var selectedLots = 0;
    parkingDataProvider.parkingViewState.forEach((key, value) {
      if (value == true) selectedLots++;
    });

    for (var lotName in lots) {
      bool lotViewState = parkingDataProvider.parkingViewState[lotName]!;
      listTiles.add(
        ListTile(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Text(
              lotName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          trailing: Transform.scale(
            scale: 0.9,
            child: CupertinoSwitch(
              value: lotViewState,
              activeColor: toggleActiveColor,
              trackColor: Colors.grey.shade400,
              onChanged: (bool newValue) {
                if (selectedLots == 10 && !lotViewState && !showedScaffold) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'You have reached the maximum number of lots (10) that can be selected. Please deselect some lots before adding more.'),
                    duration: Duration(seconds: 5),
                  ));
                  showedScaffold = true;
                } else {
                  parkingDataProvider.toggleLot(lotName, selectedLots);
                }
              },
            ),
          ),
        ),
      );
    }

    return ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      children: ListTile.divideTiles(
        tiles: listTiles,
        context: context,
        color: Theme.of(context).brightness == Brightness.dark
            ? listTileDividerColorDark
            : listTileDividerColorLight,
      ).toList(),
    );
  }
}
