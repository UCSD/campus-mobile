import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/ui/common/alert_dialog_widget.dart';

class NeighborhoodLotsView extends StatefulWidget {
  final List<String> args;
  const NeighborhoodLotsView(this.args);

  @override
  _NeighborhoodLotsViewState createState() => _NeighborhoodLotsViewState();
}

class _NeighborhoodLotsViewState extends State<NeighborhoodLotsView> {
  bool showedScaffold = false;
  late ParkingDataProvider parkingDataProvider;

  @override
  Widget build(BuildContext context) {
    parkingDataProvider = Provider.of<ParkingDataProvider>(context);
    return ContainerView(child: buildLotsList(context));
  }

  Widget buildLotsList(BuildContext context) {
    List<String> arguments = widget.args;

    List<Widget> list = [];
    list.add(
      ListTile(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(
            "Parking Lots",
            style: Theme.of(context).brightness == Brightness.dark ? textSubheaderDark : textSubheaderLight,
          ),
        ),
      ),
    );

    var selectedLots = 0;
    parkingDataProvider.parkingViewState.forEach((key, value) {
      if (value == true) selectedLots++;
    });

    for (var lotName in arguments) {
      bool lotState = parkingDataProvider.parkingViewState[lotName]!;
      list.add(
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
              value: lotState,
              activeColor: toggleActiveColor,
              trackColor: Colors.grey.shade400,
              onChanged: (bool newValue) {
                if (selectedLots == 10 && !lotState && !showedScaffold) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialogWidget(
                        type: MessageTypeConstants.ERROR,
                        icon: Icons.block_flipped,
                        title: ParkingConstants.lotMaxTitle,
                        description: ParkingConstants.lotMaxDesc,
                        onClose: () {
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        children: ListTile.divideTiles(
          tiles: list,
          context: context,
          color: Theme.of(context).brightness == Brightness.dark ? listTileDividerColorDark : listTileDividerColorLight,
        ).toList(),
      ),
    );
  }
}
