import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:flutter/rendering.dart';

class NeighborhoodLotsView extends StatefulWidget {
  final List<String> args;
  const NeighborhoodLotsView(this.args);

  _NeighborhoodLotsViewState createState() => _NeighborhoodLotsViewState();
}

class _NeighborhoodLotsViewState extends State<NeighborhoodLotsView> {
  List<bool> selected = List.filled(20, false, growable: true);

  @override
  Widget build(BuildContext context) => ContainerView(
        child: buildingsList(context),
      );
// builds the list of rooms to be put into ListView
  // builds the listview that will be put into ContainerView
  Widget buildingsList(BuildContext context) {
    List<String> arguments = widget.args;

    // creates a list that will hold the list of building names
    List<Widget> list = [];
    list.add(ListTile(
      title: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Text(
          "Parking Lots:",
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    ));

    // loops through and adds buttons for the user to click on
    for (int i = 0; i < arguments.length; i++) {
      list.add(ListTile(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(
            arguments[i],
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
        trailing: IconButton(
          icon: Icon(selected[i] ? Icons.cancel_rounded : Icons.add_rounded),
          color: Colors.black,
          onPressed: () {
            setState(() {
              selected[i] = !selected[i];
            });
          },
        ),
        // onTap: () {
        //   Navigator.pushNamed(
        //     context,
        //     RoutePaths.VentilationFloors,
        //     arguments: {'building': 'Atkinson Hall'},
        //   );
        // },
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

class ScreenArguments {
  final List<String> lotList;

  ScreenArguments(this.lotList);
}
