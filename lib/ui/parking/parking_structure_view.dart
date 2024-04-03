import 'package:campus_mobile_experimental/core/providers/parking_getx.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ParkingStructureView extends StatefulWidget {
  final Function rebuildParkingCard;
  const ParkingStructureView(this.rebuildParkingCard);

  @override
  _ParkingStructureViewState createState() => _ParkingStructureViewState();
}

class _ParkingStructureViewState extends State<ParkingStructureView> {
  // Initialize ParkingGetX controller and retrieve it using Get.find()
  ParkingGetX parkingController = Get.find();
  bool showedScaffold = false;

  @override
  Widget build(BuildContext context) {
    // Obx widget to rebuild the UI when parkingViewState changes
    return Obx(() => ContainerView(
          child: structureList(context),
        ));
  }

  // Build the list of parking structures
  Widget structureList(BuildContext context) {
    List<String> structures = parkingController.getStructures();

    // Create a list that will hold the list of parking structures
    List<Widget> list = [];
    list.add(ListTile(
      title: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Text(
          "Parking Structure:",
          style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
    ));

    int selectedLots = 0;
    // Count the number of selected lots
    parkingController.parkingViewState!.forEach((key, value) {
      if (value == true) {
        selectedLots++;
      }
    });

    // Loop through and add ListTile for each parking structure
    for (var i = 0; i < structures.length; i++) {
      bool structureState = parkingController.parkingViewState![structures[i]]!;
      list.add(
        ListTile(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Text(
              structures[i],
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary, fontSize: 20),
            ),
          ),
          trailing:
              Icon(structureState ? Icons.cancel_rounded : Icons.add_rounded),
          onTap: () {
            // Show a snackbar if maximum lots are selected
            if (selectedLots == 10 &&
                !structureState &&
                showedScaffold != true) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'You have reached the maximum number of lots (10) that can be selected. You need to deselect some lots before you can add any more.'),
                duration: Duration(seconds: 5),
              ));
              showedScaffold = !showedScaffold;
            }
            // Toggle the state of the structure and rebuild the UI
            parkingController.toggleLot(structures[i], selectedLots);
            setState(() {});
            widget.rebuildParkingCard();
          },
        ),
      );
    }

    // Add SizedBox to have a grey underline for the last item in the list
    list.add(SizedBox());

    // Return a ListView containing the list of parking structures
    return ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      children: ListTile.divideTiles(tiles: list, context: context).toList(),
    );
  }
}
