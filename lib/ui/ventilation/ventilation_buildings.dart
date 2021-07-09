import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';

class BuildingArgument {
  BuildingArgument({required this.building});
  final String building;
}

class VentilationBuildings extends StatefulWidget {
  VentilationBuildingsState createState() => VentilationBuildingsState();
}

class VentilationBuildingsState extends State<VentilationBuildings> {
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: buildBuildingsList(context),
    );
  }

  Widget buildBuildingsList(BuildContext context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children:
          ListTile.divideTiles(tiles: buildingsList(context), context: context)
              .toList(),
    );
  }

  List<Widget> buildingsList(BuildContext context) {
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
    // list.add(Container(
    //   decoration: BoxDecoration(
    //     border: Border(
    //       bottom: BorderSide(
    //         color: Colors.grey.shade400,
    //       ),
    //     ),
    //   ),
    //   margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
    // ));

    for (var i = 0; i < 5; i++) {
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

    return list;
  }
}

// Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
// children: [
// // text
// Container(
// child: Align(
// alignment: Alignment.centerLeft,
// child: Text('Atkinson Hall'),
// ),
// margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
// ),
//
// // right arrow icon
// Container(
// margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
// child: Icon(
// Icons.arrow_forward_ios,
// ),
// ),
// ],
// ),

// Container(
// alignment: Alignment.topLeft,
// child: Title(
// color: Colors.black,
// child: Container(
// child: Text(
// 'Building:',
// style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
// ),
// margin: EdgeInsets.fromLTRB(24, 24, 0, 19),
// ),
// ),
// )
