import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class ParkingStructureView extends StatefulWidget {
  _ParkingStructureViewState createState() => _ParkingStructureViewState();
}

class _ParkingStructureViewState extends State<ParkingStructureView> {
  late ParkingDataProvider parkingDataProvider;
  bool showedScaffold = false;

  @override
  Widget build(BuildContext context) {
    parkingDataProvider = Provider.of<ParkingDataProvider>(context);
    return ContainerView(
      child: structureList(context),
    );
  }

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
      list.add(
        ListTile(
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
          trailing:
              Icon(structureState ? Icons.cancel_rounded : Icons.add_rounded),
          onTap: () {
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
            parkingDataProvider.toggleLot(structures[i], selectedLots);
          },
        ),
      );
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
