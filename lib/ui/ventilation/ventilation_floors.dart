import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/ventilation_locations.dart';
import 'package:campus_mobile_experimental/core/providers/ventilation.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class VentilationFloors extends StatefulWidget {
  final List<BuildingFloor> args;
  const VentilationFloors(this.args);

  VentilationFloorsState createState() => VentilationFloorsState();
}

class VentilationFloorsState extends State<VentilationFloors> {
  late VentilationDataProvider _ventilationDataProvider;

  @override
  Widget build(BuildContext context) {
    _ventilationDataProvider = Provider.of<VentilationDataProvider>(context);
    return ContainerView(
      child: floorsList(context),
    );
  }

  // builds the list of floors to be put into ListView
  Widget floorsList(BuildContext context) {
    List<BuildingFloor> arguments = widget.args;

    // creates a list that will hold the list of floor names
    List<Widget> contentList = [];
    Widget titleWidget = Container(
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(
            'Floors:',
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

    // loops through and adds buttons for the user to click on
    for (BuildingFloor model in arguments) {
      contentList.add(ListTile(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(
            model.buildingFloorNumber.toString(),
            style: TextStyle(fontSize: 20),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
        ),
        onTap: () {
          _ventilationDataProvider
              .addFloorID(model.buildingFloorNumber.toString());
          Navigator.pushNamed(
            context,
            RoutePaths.VentilationRooms,
            arguments: model.buildingFloorRooms,
          );
        },
      ));
    }

    // adds SizedBox to have a grey underline for the last item in the list
    contentList.add(SizedBox());
    ListView contentListView = ListView(
      // physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children:
          ListTile.divideTiles(tiles: contentList, context: context).toList(),
    );

    return Column(
      children: [titleWidget, Expanded(child: contentListView)],
    );
  }
}
