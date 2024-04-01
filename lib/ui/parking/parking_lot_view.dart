import 'package:campus_mobile_experimental/core/providers/parking_getx.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ParkingLotsView extends StatefulWidget {
  final Function rebuildParkingCard;
  const ParkingLotsView(this.rebuildParkingCard);

  @override
  _ParkingLotViewState createState() => _ParkingLotViewState();
}

class _ParkingLotViewState extends State<ParkingLotsView> {
  // Initialize ParkingGetX controller and retrieve it using Get.find()
  ParkingGetX parkingController = Get.find();
  bool showedScaffold = false;

  @override
  Widget build(BuildContext context) {
    // Return a ContainerView containing the list of parking lots
    return ContainerView(
      child: parkingLotsList(context),
    );
  }

  // Build the list of parking lots
  Widget parkingLotsList(BuildContext context) {
    List<String> lots = parkingController.getLots();

    // Create a list that will hold the list of parking lots
    List<Widget> list = [];
    list.add(ListTile(
      title: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Text(
          "Parking Lots:",
          style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
    ));

    int selectedLots = 0;
    // Count the number of selected lots
    parkingController.parkingViewState.value!.forEach((key, value) {
      if (value == true) {
        selectedLots++;
      }
    });

    // Loop through and add ListTile for each parking lot
    for (var i = 0; i < lots.length; i++) {
      bool lotViewState = parkingController.parkingViewState.value![lots[i]]!;
      list.add(
        ListTile(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Text(
              lots[i],
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary, fontSize: 20),
            ),
          ),
          trailing:
              Icon(lotViewState ? Icons.cancel_rounded : Icons.add_rounded),
          onTap: () {
            // Show a snackbar if maximum lots are selected
            if (selectedLots == 10 && !lotViewState && showedScaffold != true) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'You have reached the maximum number of lots (10) that can be selected. You need to deselect some lots before you can add any more.'),
                duration: Duration(seconds: 5),
              ));
              showedScaffold = !showedScaffold;
            }
            // Toggle the state of the lot and rebuild the UI
            parkingController.toggleLot(lots[i], selectedLots);
            setState(() {});
            widget.rebuildParkingCard();
          },
        ),
      );
    }

    // Add SizedBox to have a grey underline for the last item in the list
    list.add(SizedBox());

    // Return a ListView containing the list of parking lots
    return ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      children: ListTile.divideTiles(tiles: list, context: context).toList(),
    );
  }
}
