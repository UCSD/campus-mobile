import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/ventilation_locations.dart';
import 'package:campus_mobile_experimental/core/providers/ventilation.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VentilationBuildings extends StatefulWidget {
  @override
  _VentilationBuildingsState createState() => _VentilationBuildingsState();
}

class _VentilationBuildingsState extends State<VentilationBuildings> {
  late VentilationDataProvider ventilationDataProvider;

  @override
  Widget build(BuildContext context) {
    print("Context in ventilation buildings: $context");

    ventilationDataProvider = Provider.of<VentilationDataProvider>(context);

    return ContainerView(
      child: buildingsList(context),
    );
  }

  Widget buildingsList(BuildContext context) {
    List<Widget> list = [];
    list.add(Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: ListTile(
        dense: true,
        title: Text(
          'Buildings:',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    ));

    for (VentilationLocationsModel model
        in ventilationDataProvider.ventilationLocationModels) {
      list.add(TextButton(
          child: ListTile(
            dense: true,
            title: Text(
              'Atkinson Hall',
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
              RoutePaths.VentilationFloors,
              arguments: {'building': 'Atkinson Hall'},
            );
          }));
    }

    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: ListTile.divideTiles(tiles: list, context: context).toList(),
    );
  }
}
