import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../app_styles.dart';

class ParkingStructureView extends StatefulWidget {
  _ParkingStructureViewState createState() => _ParkingStructureViewState();
}

class _ParkingStructureViewState extends State<ParkingStructureView> {
  late ParkingDataProvider parkingDataProvider;

  @override
  Widget build(BuildContext context) {
    parkingDataProvider = Provider.of<ParkingDataProvider>(context);
    return ContainerView(
      child: structureList(context),
    );
  }

// builds the list of rooms to be put into ListView
  // builds the listview that will be put into ContainerView
  Widget structureList(BuildContext context) {
    List<String> structures =
        Provider.of<ParkingDataProvider>(context).getStructures();

    // creates a list that will hold the list of building names
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
    parkingDataProvider.parkingViewState!.forEach((key, value) {
      if (value == true) {
        selectedLots++;
      }
    });
    // loops through and adds buttons for the user to click on
    for (var i = 0; i < structures.length; i++) {
      bool structureState =
          parkingDataProvider.parkingViewState![structures[i]]!;
      list.add(ListTile(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(
            structures[i],
            style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .secondary, // structureState ? ColorPrimary : Colors.black,
                fontSize: 20),
          ),
        ),
        trailing: IconButton(
          icon: Icon(structureState ? Icons.cancel_rounded : Icons.add_rounded),
          color: Theme.of(context)
              .colorScheme
              .secondary, // structureState ? ColorPrimary : Colors.black,
          onPressed: () {
            parkingDataProvider.toggleLot(structures[i], selectedLots);
          },
        ),
      ));
    }

    // adds SizedBox to have a grey underline for the last item in the list
    list.add(SizedBox());

    return ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      children: ListTile.divideTiles(tiles: list, context: context).toList(),
    );
  }
}
