import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:campus_mobile_experimental/ui/ventilation/ventilation_display.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VentilationRooms extends StatefulWidget {
  final Map args;
  const VentilationRooms(this.args);

  VentilationRoomsState createState() => VentilationRoomsState();
}

class VentilationRoomsState extends State<VentilationRooms> {
  // keeps track of which button was tapped
  List<bool> _added = [];

  @override
  Widget build(BuildContext context) => ContainerView(
        child: roomsList(context),
      );

  // builds the list of rooms to be put into ListView
  Widget roomsList(BuildContext context) {
    Map arguments = widget.args;

    List<Widget> list = [];
    list.add(ListTile(
      title: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Text(
          'Rooms:',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    ));

    for (var i = 0; i < 5; i++) {
      _added.add(false);
      list.add(ListTile(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(
            'Room 301',
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
        trailing: Icon(
          !_added[i] ? Icons.add_circle_outline_outlined : Icons.cancel,
        ),
        onTap: () {
          setState(() {
            _added[i] = !_added[i];
          });

          arguments['room'] = 'Room 101';
          print("Arguments: $arguments");
          VentilationDisplay.args = arguments;

          // Set tab bar index to the Home tab
          Provider.of<BottomNavigationBarProvider>(context, listen: false)
              .currentIndex = NavigatorConstants.HomeTab;

          // Navigate to Home tab
          Navigator.of(context).pushNamedAndRemoveUntil(
              RoutePaths.BottomNavigationBar, (Route<dynamic> route) => false);

          // change the appBar title to the ucsd logo
          Provider.of<CustomAppBar>(context, listen: false)
              .changeTitle(CustomAppBar().appBar.title);
        },
      ));
    }

    // adds sizedbox to have a grey underline for the last item in the list
    list.add(SizedBox());

    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: ListTile.divideTiles(tiles: list, context: context).toList(),
    );
  }
}
