import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_constants.dart';
import '../common/alert_dialog_widget.dart';

class ParkingStructureView extends StatefulWidget {
  @override
  _ParkingStructureViewState createState() => _ParkingStructureViewState();
}

class _ParkingStructureViewState extends State<ParkingStructureView> {
  late ParkingDataProvider parkingDataProvider;
  var showedScaffold = false;

  @override
  Widget build(BuildContext context) {
    parkingDataProvider = Provider.of<ParkingDataProvider>(context);
    return ContainerView(child: structureList(context));
  }

  Widget structureList(BuildContext context) {
    List<String> structures =
        Provider.of<ParkingDataProvider>(context).getStructures();

    List<Widget> listTiles = [];
    listTiles.add(
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Text("Parking Structures",
              style: Theme.of(context).brightness == Brightness.dark
                  ? textSubheaderDark
                  : textSubheaderLight),
        ),
      ),
    );

    var selectedLots = 0;
    parkingDataProvider.parkingViewState.forEach((key, value) {
      if (value == true) selectedLots++;
    });

    for (var structureName in structures) {
      bool structureState =
          parkingDataProvider.parkingViewState[structureName]!;
      listTiles.add(
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Text(
              structureName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          trailing: Transform.scale(
            scale: 0.9,
            child: CupertinoSwitch(
              value: structureState,
              activeColor: toggleActiveColor,
              trackColor: Colors.grey.shade400,
              onChanged: (bool newValue) {
                if (selectedLots == 10 && !structureState && !showedScaffold) {
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
                  parkingDataProvider.toggleLot(structureName, selectedLots);
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
      children: [
        for (int i = 0; i < listTiles.length; i++) ...[
          listTiles[i],
          if (i != listTiles.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                color: Theme.of(context).brightness == Brightness.dark
                    ? listTileDividerColorDark
                    : listTileDividerColorLight,
                thickness: 0.5,
                height: 0,
              ),
            ),
        ]
      ],
    );
  }
}
