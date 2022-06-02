import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/ventilation.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VentilationRooms extends StatefulWidget {
  final List<String> args;
  const VentilationRooms(this.args);

  VentilationRoomsState createState() => VentilationRoomsState();
}

class VentilationRoomsState extends State<VentilationRooms> {
  // keeps track of which button was tapped
  List<bool> _added = [];
  late VentilationDataProvider _ventilationDataProvider;

  @override
  Widget build(BuildContext context) {
    _ventilationDataProvider = Provider.of<VentilationDataProvider>(context);
    return ContainerView(
      child: roomsList(context),
    );
  }

  // builds the list of rooms to be put into ListView
  Widget roomsList(BuildContext context) {
    List<String> arguments = widget.args;
    List<String> bfrIDs = []; // list of the bfrIDs
    List<Widget> contentList = []; // list of ListTile widgets

    Widget titleWidget = Container(
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(
            'Rooms:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: .75),
        ),
      ),
    );

    for (int i = 0; i < arguments.length; i++) {
      // makes the bfrID and adds it to the list
      String bfrID = _ventilationDataProvider.bfrID(arguments[i]);
      bfrIDs.add(bfrID);

      // checks to see if the user has added this bfrID
      bool containsID = _ventilationDataProvider.ventilationIDs.contains(bfrID);
      _added.add(containsID);

      // creates the ListTile and button
      contentList.add(ListTile(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(
            '${arguments[i]}',
            style: TextStyle(fontSize: 20),
          ),
        ),
        trailing: Icon(
          !_added[i] ? Icons.add_circle_outline_outlined : Icons.cancel,
        ),
        onTap: () {
          // removes or adds a location depending if the user already added it

          !_added[i]
              ? _ventilationDataProvider.addLocation(arguments[i])
              : _ventilationDataProvider.removeLocation(arguments[i]);

          setState(() {
            _added[i] = !_added[i];
          });

          // Set tab bar index to the Home tab
          Provider.of<BottomNavigationBarProvider>(context, listen: false)
              .currentIndex = NavigatorConstants.HomeTab;

          // Navigate to Home tab
          Navigator.of(context).pushNamedAndRemoveUntil(
              RoutePaths.BottomNavigationBar, (Route<dynamic> route) => false);

          // change the appBar title to the ucsd logo
          Provider.of<CustomAppBar>(context, listen: false)
              .changeTitle(CustomAppBar().appBar.title);

          if (_ventilationDataProvider.error ==
              VentilationConstants.addLocationFailed) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Could not add location."),
            ));
          } else if (_ventilationDataProvider.error ==
              VentilationConstants.removeLocationFailed) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Could not remove location."),
            ));
          }
        },
      ));
    }

    // adds sizedbox to have a grey underline for the last item in the list
    contentList.add(SizedBox());
    ListView contentListView = ListView(
      shrinkWrap: true,
      children:
          ListTile.divideTiles(tiles: contentList, context: context).toList(),
    );

    return Column(
      children: [titleWidget, Expanded(child: contentListView)],
    );
  }
}
