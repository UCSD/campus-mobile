import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class NeighborhoodLotsView extends StatefulWidget {
  final List<String> args;
  const NeighborhoodLotsView(this.args);

  _NeighborhoodLotsViewState createState() => _NeighborhoodLotsViewState();
}

class _NeighborhoodLotsViewState extends State<NeighborhoodLotsView> {
  late ParkingDataProvider parkingDataProvider;
  bool showedScaffold = false;

  @override
  Widget build(BuildContext context) {
    parkingDataProvider = Provider.of<ParkingDataProvider>(context);
    return ContainerView(
      child: lotsList(context),
    );
  }

  // builds the listview that will be put into ContainerView
  Widget lotsList(BuildContext context) {
    List<String> arguments = widget.args;

    // creates a list that will hold the list of building names
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
    parkingDataProvider.parkingViewState!.forEach((key, value) {
      if (value == true) {
        selectedLots++;
      }
    });
    // loops through and adds buttons for the user to click on
    for (int i = 0; i < arguments.length; i++) {
      bool lotState = parkingDataProvider.parkingViewState![arguments[i]]!;
      list.add(
        ListTile(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Text(
              arguments[i],
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary, // lotState ? colorFromHex('#006A96') : Theme.of(context).colorScheme.secondary,
                  fontSize: 20),
            ),
          ),
          trailing: Icon(lotState ? Icons.cancel_rounded : Icons.add_rounded),
          onTap: () {
            if (selectedLots == 10 && !lotState && showedScaffold != true) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'You have reached the maximum number of lots (10) that can be selected. You need to deselect some lots before you can add any more.'),
                duration: Duration(seconds: 5),
              ));
              showedScaffold = !showedScaffold;
            }
            parkingDataProvider.toggleLot(arguments[i], selectedLots);
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

Color colorFromHex(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  if (hexColor.length == 6) {
    hexColor = 'FF' + hexColor; // FF as the opacity value if you don't add it.
  }
  return Color(int.parse('FF$hexCode', radix: 16));
}

class ScreenArguments {
  final List<String> lotList;

  ScreenArguments(this.lotList);
}
