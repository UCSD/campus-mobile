import 'package:campus_mobile_experimental/core/models/spot_types.dart';
import 'package:campus_mobile_experimental/core/providers/parking_getx.dart';
import 'package:campus_mobile_experimental/ui/common/HexColor.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpotTypesView extends StatefulWidget {
  final Function rebuildParkingCard;
  const SpotTypesView(this.rebuildParkingCard);

  @override
  _SpotTypesViewState createState() => _SpotTypesViewState();
}

class _SpotTypesViewState extends State<SpotTypesView> {
  // Initialize ParkingGetX controller and retrieve it using Get.find()
  ParkingGetX parkingController = Get.find();

  @override
  Widget build(BuildContext context) {
    // Build the container view with the list widget
    return ContainerView(
      child: createListWidget(context),
    );
  }

  // Create a list widget containing the spot types
  Widget createListWidget(BuildContext context) {
    return ListView(children: createList(context));
  }

  // Create a list of widgets representing spot types
  List<Widget> createList(BuildContext context) {
    int selectedSpots = 0;
    List<Widget> list = [];

    // Loop through each spot type
    for (Spot data in parkingController.spotTypeModel!.spots!) {
      // Check if the spot type is selected
      if (parkingController.selectedSpotTypesState![data.spotKey]! == true) {
        selectedSpots++;
      }

      // Convert color strings to Color objects
      Color iconColor = HexColor(data.color!);
      Color textColor = HexColor(data.textColor!);

      // Add ListTile for each spot type
      list.add(ListTile(
        key: Key(data.name.toString()),
        leading: Container(
            width: 35,
            height: 35,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor,
            ),
            child: Align(
                alignment: Alignment.center,
                child: data.text!.contains("&#x267f;")
                    ? Icon(Icons.accessible,
                        size: 25.0, color: colorFromHex(data.textColor!))
                    : Text(
                        data.spotKey!.contains("SR") ? "RS" : data.text!,
                        style: TextStyle(color: textColor),
                      ))),
        title: Text(data.name!),
        trailing: Switch(
          value: parkingController.selectedSpotTypesState![data.spotKey]!,
          onChanged: (_) {
            parkingController.toggleSpotSelection(data.spotKey, selectedSpots);
            setState(() {});
            widget.rebuildParkingCard();
          },
          // activeColor: Theme.of(context).buttonColor,
          activeColor: Theme.of(context).backgroundColor,
        ),
      ));
    }
    return list;
  }

  // Convert hex color string to Color object
  Color colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor =
          'FF' + hexColor; // FF as the opacity value if you don't add it.
    }
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}
