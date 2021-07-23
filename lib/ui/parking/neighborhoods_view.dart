import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:flutter/rendering.dart';

class NeighborhoodsView extends StatefulWidget {
  _NeighborhoodsViewState createState() => _NeighborhoodsViewState();
}

class _NeighborhoodsViewState extends State<NeighborhoodsView> {
  List<bool> _added = [];
  List<bool> selected = List.filled(5, false);

  @override
  Widget build(BuildContext context) => ContainerView(
        child: buildingsList(context),
      );
// builds the list of rooms to be put into ListView
  // builds the listview that will be put into ContainerView
  Widget buildingsList(BuildContext context) {
    // creates a list that will hold the list of building names
    List<Widget> list = [];
    list.add(ListTile(
      title: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Text(
          "Neighborhoods:",
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    ));

    // loops through and adds buttons for the user to click on
    for (var i = 0; i < 5; i++) {
      list.add(ListTile(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(
            "Revelle College",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.black,
        ),
        onTap: () {
          Navigator.pushNamed(context, RoutePaths.NeighborhoodsLotsView);
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
