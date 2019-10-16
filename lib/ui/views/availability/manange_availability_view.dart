import 'package:flutter/material.dart';
import 'package:campus_mobile/ui/widgets/container_view.dart';
import 'package:campus_mobile/core/models/availability_model.dart';

class ManageAvailabilityView extends StatelessWidget {
  const ManageAvailabilityView({Key key, @required this.data})
      : super(key: key);

  final List<AvailabilityModel> data;
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: buildLocationsList(context),
    );
  }

  Widget buildLocationsList(BuildContext context) {
    return ReorderableListView(
      children: createList(context),
      onReorder: _onReorder,
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final AvailabilityModel item = data.removeAt(oldIndex);
    data.insert(newIndex, item);
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = List<Widget>();
    for (AvailabilityModel model in data) {
      list.add(ListTile(
        key: Key(model.locationId.toString()),
        title: Text(model.locationName),
        trailing: Icon(Icons.reorder),
      ));
    }

    /// ListTile.divideTiles(tiles: list, context: context).toList()
    /// the line above doesn't work because ReorderableListView requires that all
    /// elements have a unique key but when we run ListTile.divideTiles it
    /// it returns a list of widgets that do not have a key
    return list;
  }
}
