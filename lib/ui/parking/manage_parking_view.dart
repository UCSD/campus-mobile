import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManageParkingView extends StatefulWidget {
  final Function rebuildParkingCard;
  const ManageParkingView(this.rebuildParkingCard);

  @override
  _ManageParkingViewState createState() => _ManageParkingViewState();
}

class _ManageParkingViewState extends State<ManageParkingView> {
  @override
  Widget build(BuildContext context) {
    // Build the container view with the locations list
    return ContainerView(
      child: buildLocationsList(context),
    );
  }

  // Build the list of parking locations
  Widget buildLocationsList(BuildContext context) {
    // Initialize a list to hold the list of building names
    List<Widget> list = [];

    // Define types of parking
    List<String> parkingType = [
      "Neighborhoods",
      "Parking Structure",
      "Parking Lots"
    ];

    // List<String> parkingTypeViews = [
    //   "NeighborhoodsView",
    //   "ParkingStructureView",
    //   "ParkingLotsView"
    // ];

    // Loop through and add buttons for the user to click on
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
          // Navigate to corresponding view based on the parking type
          if (i == 0) {
            Get.toNamed(RoutePaths.NeighborhoodsView,
                arguments: widget.rebuildParkingCard);
          }
          if (i == 1) {
            Get.toNamed(RoutePaths.ParkingStructureView,
                arguments: widget.rebuildParkingCard);
          }
          if (i == 2) {
            Get.toNamed(RoutePaths.ParkingLotsView,
                arguments: widget.rebuildParkingCard);
          }
        },
      ));
    }

    // Add SizedBox to have a grey underline for the last item in the list
    list.add(SizedBox());

    // Return ListView with divided ListTile widgets
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: ListTile.divideTiles(tiles: list, context: context).toList(),
    );
  }
}
