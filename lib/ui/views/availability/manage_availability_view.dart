import 'package:campus_mobile_experimental/core/data_providers/availability_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/widgets/container_view.dart';
import 'package:campus_mobile_experimental/core/models/availability_model.dart';
import 'package:provider/provider.dart';

class ManageAvailabilityView extends StatelessWidget {
  AvailabilityDataProvider _availabilityDataProvider;
  @override
  Widget build(BuildContext context) {
    _availabilityDataProvider = Provider.of<AvailabilityDataProvider>(context);
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
    List<AvailabilityModel> newOrder =
        _availabilityDataProvider.availabilityModels;
    AvailabilityModel item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);
    List<String> orderedLocationNames = List<String>();
    for (AvailabilityModel item in newOrder) {
      orderedLocationNames.add(item.locationName);
    }
    _availabilityDataProvider.reorderLocations(orderedLocationNames);
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = List<Widget>();
    for (AvailabilityModel model
        in _availabilityDataProvider.availabilityModels) {
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
