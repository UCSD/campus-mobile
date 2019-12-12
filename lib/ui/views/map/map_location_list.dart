import 'package:campus_mobile_experimental/core/models/map_search_model.dart';
import 'package:campus_mobile_experimental/ui/widgets/container_view.dart';
import 'package:flutter/material.dart';

class MapLocationList extends StatelessWidget {
  final List<MapSearchModel> data;
  final Function addMarker;
  const MapLocationList({Key key, this.data, this.addMarker}) : super(key: key);

  List<Widget> createTiles(BuildContext context) {
    List<Widget> list = List<Widget>();
    int listIndex = 0;
    for (var i in data) {
      list.add(aLocation(i, context, listIndex++));
    }
    return ListTile.divideTiles(tiles: list, context: context).toList();
  }

  Widget aLocation(MapSearchModel data, BuildContext context, int index) {
    return ListTile(
      leading: Icon(Icons.location_on),
      title: Text(data.title),
      trailing: Text('?? mi'),
      onTap: () {
        addMarker(index);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: ListView(
        children: createTiles(context),
      ),
    );
  }
}
