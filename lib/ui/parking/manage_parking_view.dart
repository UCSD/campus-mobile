import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/material.dart';

class ManageParkingView extends StatefulWidget {
  @override
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
    const List<String> parkingType = [
      "Neighborhoods",
      "Parking Structures",
    ];

    List<Widget> listTiles = [];
    for (int i = 0; i < parkingType.length; i++) {
      listTiles.add(
        ListTile(
          title: Text(
            parkingType[i],
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: dotsSelectedColorLight,
            size: 18.0,
          ),
          onTap: () {
            if (i == 0) {
              Navigator.pushNamed(context, RoutePaths.NeighborhoodsView);
            } else if (i == 1) {
              Navigator.pushNamed(context, RoutePaths.ParkingStructureView);
            }
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          for (int i = 0; i < listTiles.length; i++) ...[
            listTiles[i],
            if (i != listTiles.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? listTileDividerColorDark
                      : listTileDividerColorLight,
                  thickness: 0.5,
                  height: 0,
                ),
              ),
          ]
        ],
      ),
    );
  }
}
