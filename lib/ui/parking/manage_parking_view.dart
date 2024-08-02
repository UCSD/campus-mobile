// ignore_for_file: unused_local_variable

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';

class ManageParkingView extends StatefulWidget {
  _ManageParkingViewState createState() => _ManageParkingViewState();
}

class _ManageParkingViewState extends State<ManageParkingView> {
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: buildLocationsList(context),
    );
  }

  Widget buildLocationsList(BuildContext context) {
    // creates a list that will hold the list of building names
    List<Widget> list = [];

    List<String> parkingType = [
      "Neighborhoods",
      "Parking Structure",
      "Parking Lots"
    ];

    List<String> parkingTypeViews = [
      "NeighborhoodsView",
      "ParkingStructureView",
      "ParkingLotsView"
    ];

    // loops through and adds buttons for the user to click on
    for (var i = 0; i < parkingType.length; i++) {
      list.add(ListTile(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(
            "${parkingType[i]}",
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary, fontSize: 20),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).colorScheme.secondary,
        ),
        onTap: () {
          if (i == 0) {
            Navigator.pushNamed(
              context,
              RoutePaths.NeighborhoodsView,
            );
          }
          if (i == 1) {
            Navigator.pushNamed(
              context,
              RoutePaths.ParkingStructureView,
            );
          }
          if (i == 2) {
            Navigator.pushNamed(
              context,
              RoutePaths.ParkingLotsView,
            );
          }
        },
      ));
    }

    // adds SizedBox to have a grey underline for the last item in the list
    list.add(SizedBox());

    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: ListTile.divideTiles(tiles: list, context: context).toList(),
    );
  }
}
