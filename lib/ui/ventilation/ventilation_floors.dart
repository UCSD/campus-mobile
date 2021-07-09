import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';

class VentilationFloors extends StatefulWidget {
  VentilationFloorsState createState() => VentilationFloorsState();
}

class VentilationFloorsState extends State<VentilationFloors> {
  @override
  // constructor
  Widget build(BuildContext context) {
    return ContainerView(
      child: buildFloorsList(context),
    );
  }

  // converts a nullable map to a non-nullable map
  Map nullMap(Map? args) {
    if (args != null) {
      return args;
    }

    return {'building': 'Bonner Hall'};
  }

  // builds the ListView that will be put into ContainerView
  Widget buildFloorsList(BuildContext context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children:
          ListTile.divideTiles(tiles: floorsList(context), context: context)
              .toList(),
    );
  }

  // builds the list of floors to be put into ListView
  List<Widget> floorsList(BuildContext context) {
    Map? args = ModalRoute.of(context)!.settings.arguments as Map?;
    final arguments = nullMap(args);

    List<Widget> list = [];
    list.add(Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: ListTile(
        dense: true,
        title: Text(
          'Floors:',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    ));

    for (var i = 0; i < 5; i++) {
      list.add(TextButton(
          child: ListTile(
            dense: true,
            title: Text(
              '1st Floor',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.black,
            ),
          ),
          onPressed: () {
            Navigator.pushNamed(
              context,
              RoutePaths.VentilationRooms,
              arguments: {
                'building': arguments['building'],
                'floor': '1st Floor'
              },
            );
          }));
    }

    return list;
  }
}
