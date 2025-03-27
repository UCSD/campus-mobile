import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/app_styles.dart';

class NeighborhoodsView extends StatefulWidget {
  @override
  _NeighborhoodsViewState createState() => _NeighborhoodsViewState();
}

class _NeighborhoodsViewState extends State<NeighborhoodsView> {
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: buildNeighborhoodsList(context),
    );
  }

  Widget buildNeighborhoodsList(BuildContext context) {
    Map<String, List<String>> neighborhoods =
        Provider.of<ParkingDataProvider>(context).getParkingMap();

    List<Widget> listTiles = [];

    listTiles.add(
      ListTile(
        title: Text(
          "Neighborhoods",
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: lightPrimaryColor),
        ),
      ),
    );

    neighborhoods.forEach((key, value) {
      if (key.isNotEmpty) {
        listTiles.add(
          ListTile(
            title: Text(
              key,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: dotsSelectedColorLight,
              size: 18.0,
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                RoutePaths.NeighborhoodsLotsView,
                arguments: value,
              );
            },
          ),
        );
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        children: ListTile.divideTiles(
          tiles: listTiles,
          context: context,
          color: Theme.of(context).brightness == Brightness.dark
              ? listTileDividerColorDark
              : listTileDividerColorLight,
        ).toList(),
      ),
    );
  }
}
