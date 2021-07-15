import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class VentilationFloors extends StatefulWidget {
  final Map args;
  const VentilationFloors(this.args);

  VentilationFloorsState createState() => VentilationFloorsState();
}

class VentilationFloorsState extends State<VentilationFloors> {
  @override
  Widget build(BuildContext context) => ContainerView(
        child: floorsList(context),
      );

  // builds the list of floors to be put into ListView
  Widget floorsList(BuildContext context) {
    Map arguments = widget.args;

    // creates a list that will hold the list of floor names
    List<Widget> list = [];
    list.add(ListTile(
      title: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Text(
          'Floors:',
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
            '1st Floor',
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.black,
        ),
        onTap: () {
          arguments['floor'] = '1st Floor';
          Navigator.pushNamed(
            context,
            RoutePaths.VentilationRooms,
            arguments: arguments,
          );
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
