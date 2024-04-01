import 'package:campus_mobile_experimental/core/providers/parking_getx.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NeighborhoodLotsView extends StatefulWidget {
  final Map<String, dynamic> args;
  const NeighborhoodLotsView(this.args);

  @override
  _NeighborhoodLotsViewState createState() => _NeighborhoodLotsViewState();
}

class _NeighborhoodLotsViewState extends State<NeighborhoodLotsView> {
  // Initialize ParkingGetX controller and retrieve it using Get.find()
  ParkingGetX parkingController = Get.find();
  bool showedScaffold = false;

  @override
  Widget build(BuildContext context) {
    // Build the ContainerView with the lotsList widget
    return ContainerView(
      child: lotsList(context),
    );
  }

  // Build the list of parking lots
  Widget lotsList(BuildContext context) {
    List<String> arguments = widget.args["neighborhoodList"];

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
    for (int i = 0; i < arguments.length; i++) {
      bool lotState = parkingController.parkingViewState.value![arguments[i]]!;
      list.add(
        ListTile(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Text(
              arguments[i],
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary, fontSize: 20),
            ),
          ),
          trailing: Icon(lotState ? Icons.cancel_rounded : Icons.add_rounded),
          onTap: () {
            // Show a snackbar if maximum lots are selected
            if (selectedLots == 10 && !lotState && showedScaffold != true) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'You have reached the maximum number of lots (10) that can be selected. You need to deselect some lots before you can add any more.'),
                duration: Duration(seconds: 5),
              ));
              showedScaffold = !showedScaffold;
            }
            // Toggle the state of the lot and rebuild the UI
            parkingController.toggleLot(arguments[i], selectedLots);
            setState(() {});
            widget.args["rebuildParkingCard"]();
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

// Helper function to convert hex color string to Color object
Color colorFromHex(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  if (hexColor.length == 6) {
    hexColor = 'FF' + hexColor; // FF as the opacity value if you don't add it.
  }
  return Color(int.parse('FF$hexCode', radix: 16));
}

// Class for holding screen arguments
class ScreenArguments {
  final List<String> lotList;

  ScreenArguments(this.lotList);
}
