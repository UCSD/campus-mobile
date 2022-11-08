import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:provider/provider.dart';

class NeighborhoodsView extends StatefulWidget {
  _NeighborhoodsViewState createState() => _NeighborhoodsViewState();
}

class _NeighborhoodsViewState extends State<NeighborhoodsView> {
  List<bool> selected = List.filled(5, false);

  @override
  Widget build(BuildContext context) => ContainerView(
        child: neighborhoodsList(context),
      );

  // builds the listview that will be put into ContainerView
  Widget neighborhoodsList(BuildContext context) {
    Map<String, List<String>?>? neighborhoods =
        Provider.of<ParkingDataProvider>(context).getParkingMap();
    // creates a list that will hold the list of building names
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

    // loops through and adds buttons for the user to click on
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
            Navigator.pushNamed(context, RoutePaths.NeighborhoodsLotsView,
                arguments: value);
            // arguments: {'building': 'Atkinson Hall'},
          },
        ));
      }
    });

    // adds SizedBox to have a grey underline for the last item in the list
    list.add(SizedBox());

    return ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      children: ListTile.divideTiles(tiles: list, context: context).toList(),
    );
  }
}
