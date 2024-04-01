import 'package:campus_mobile_experimental/core/providers/parking_getx.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:get/get.dart';

class NeighborhoodsView extends StatefulWidget {
  final Function rebuildParkingCard;
  const NeighborhoodsView(this.rebuildParkingCard);

  @override
  _NeighborhoodsViewState createState() => _NeighborhoodsViewState();
}

class _NeighborhoodsViewState extends State<NeighborhoodsView> {
  // Initialize ParkingGetX controller and retrieve it using Get.find()
  ParkingGetX parkingController = Get.find();
  List<bool> selected = List.filled(5, false);

  @override
  Widget build(BuildContext context) => ContainerView(
        child: neighborhoodsList(context),
      );

  // Build the list of neighborhoods
  Widget neighborhoodsList(BuildContext context) {
    // Get the map of neighborhoods and their corresponding lots
    Map<String, List<String>?>? neighborhoods =
        parkingController.getParkingMap();

    // Create a list that will hold the list of neighborhoods
    List<Widget> list = [];
    list.add(ListTile(
      title: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Text(
          "Neighborhoods:",
          style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
    ));

    // Loop through and add ListTile for each neighborhood
    neighborhoods.forEach((key, value) {
      if (key != "") {
        list.add(ListTile(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Text(
              key,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary, fontSize: 20),
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onTap: () {
            // Navigate to NeighborhoodsLotsView when a neighborhood is tapped
            Get.toNamed(RoutePaths.NeighborhoodsLotsView, arguments: {
              "neighborhoodList": value,
              "rebuildParkingCard": widget.rebuildParkingCard
            });
          },
        ));
      }
    });

    // Add SizedBox to have a grey underline for the last item in the list
    list.add(SizedBox());

    // Return a ListView containing the list of neighborhoods
    return ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      children: ListTile.divideTiles(tiles: list, context: context).toList(),
    );
  }
}
