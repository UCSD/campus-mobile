import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/ventilation_locations.dart';
import 'package:campus_mobile_experimental/core/providers/ventilation.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class VentilationBuildings extends StatefulWidget {
  final List<VentilationLocationsModel> args;
  const VentilationBuildings(this.args);

  _VentilationBuildingsState createState() => _VentilationBuildingsState();
}

class _VentilationBuildingsState extends State<VentilationBuildings> {
  late VentilationDataProvider _ventilationDataProvider;

  @override
  Widget build(BuildContext context) => ContainerView(
        child: buildingsList(context),
      );

  // builds the listview that will be put into ContainerView
  Widget buildingsList(BuildContext context) {
    // creates a list that will hold the list of building names
    List<VentilationLocationsModel> arguments = widget.args;
    _ventilationDataProvider = Provider.of<VentilationDataProvider>(context);

    List<Widget> contentList = [];
    Widget titleWidget = Container(
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(
            'Buildings:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: .75,
          ),
        ),
      ),
    );

    // loops through and adds buttons for the user to click on
    for (VentilationLocationsModel model in arguments) {
      contentList.add(ListTile(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(
            model.buildingName.toString(),
            style: TextStyle(fontSize: 20),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
        ),
        onTap: () {
          _ventilationDataProvider.addBuildingID(model.buildingId.toString());
          Navigator.pushNamed(
            context,
            RoutePaths.VentilationFloors,
            arguments: model.buildingFloors,
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
