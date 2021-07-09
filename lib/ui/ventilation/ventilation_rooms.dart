import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VentilationRooms extends StatefulWidget {
  VentilationRoomsState createState() => VentilationRoomsState();
}

class VentilationRoomsState extends State<VentilationRooms> {
  List<bool> _added = [];

  @override
  //constructor
  Widget build(BuildContext context) {
    return ContainerView(
      child: buildRoomsList(context),
    );
  }

  // converts a nullable map to a non-nullable map
  Map nullMap(Map? args) {
    if (args != null) {
      return args;
    }

    return {'building': 'Bonner Hall', 'floor': '3rd Floor'};
  }

  // builds the LIstView that will be put into ContainerView
  Widget buildRoomsList(BuildContext context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children:
          ListTile.divideTiles(tiles: roomsList(context), context: context)
              .toList(),
    );
  }

  // builds the list of rooms to be put into ListView
  List<Widget> roomsList(BuildContext context) {
    // converts the nullable args to non-nullable arguments
    Map? args = ModalRoute.of(context)!.settings.arguments as Map?;
    final arguments = nullMap(args);

    List<Widget> list = [];
    list.add(Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: ListTile(
        dense: true,
        title: Text(
          'Rooms:',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            onPrimary: Theme.of(context).primaryColor, // foreground
            primary: Theme.of(context).buttonColor,
          ),
          child: Text('Done',
              style: TextStyle(
                color: Theme.of(context).textTheme.button!.color,
              )),
          onPressed: () {
            /// Set tab bar index to the Home tab
            Provider.of<BottomNavigationBarProvider>(context, listen: false)
                .currentIndex = NavigatorConstants.HomeTab;

            /// Navigate to Home tab
            Navigator.of(context).pushNamedAndRemoveUntil(
                RoutePaths.BottomNavigationBar,
                (Route<dynamic> route) => false);
          },
        ),
      ),
    ));

    for (var i = 0; i < 5; i++) {
      _added.add(false);
      list.add(
        TextButton(
            child: ListTile(
              dense: true,
              title: Text(
                'Room 301',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              trailing: Icon(
                !_added[i] ? Icons.add_circle_outline_outlined : Icons.cancel,
              ),
            ),
            onPressed: () {
              setState(() {
                _added[i] = !_added[i];
              });
            }),
      );
    }

    return list;
  }
}
