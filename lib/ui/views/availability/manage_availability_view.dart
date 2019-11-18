import 'package:campus_mobile_experimental/core/services/availability_service.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/widgets/container_view.dart';
import 'package:campus_mobile_experimental/core/models/availability_model.dart';
import 'package:provider/provider.dart';

class ManageAvailabilityView extends StatelessWidget {
  AvailabilityService _availabilityService;
  @override
  Widget build(BuildContext context) {
    _availabilityService = Provider.of<AvailabilityService>(context);
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
    List<AvailabilityModel> newOrder = _availabilityService.data;
    AvailabilityModel item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);
    _availabilityService.data = newOrder;
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = List<Widget>();
    for (AvailabilityModel model in _availabilityService.data) {
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
