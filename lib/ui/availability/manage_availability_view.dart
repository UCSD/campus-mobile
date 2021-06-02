

import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/core/providers/availability.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageAvailabilityView extends StatefulWidget {
  _ManageAvailabilityViewState createState() => _ManageAvailabilityViewState();
}

class _ManageAvailabilityViewState extends State<ManageAvailabilityView> {
  late AvailabilityDataProvider _availabilityDataProvider;

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
    List<AvailabilityModel?> newOrder =
        _availabilityDataProvider.availabilityModels;
    List<AvailabilityModel> toRemove = [];

    for (AvailabilityModel? item in newOrder) {
      if (_availabilityDataProvider.availabilityModels == null) {
        toRemove.add(item!);
      }
    }
    newOrder.removeWhere((element) => toRemove.contains(element));
    AvailabilityModel? item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);
    List<String?> orderedLocationNames = [];
    for (AvailabilityModel? item in newOrder) {
      orderedLocationNames.add(item!.locationName);
    }
    _availabilityDataProvider.reorderLocations(orderedLocationNames);
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = [];
    for (AvailabilityModel? model
        in _availabilityDataProvider.availabilityModels) {
      if (model != null) {
        list.add(ListTile(
          key: Key(model.locationId.toString()),
          title: Text(
            model.locationName!,
          ),
          leading: Icon(
            Icons.reorder,
          ),
          trailing: Switch(
            value: Provider.of<AvailabilityDataProvider>(context)
                .locationViewState[model.locationName]!,
            activeColor: Theme.of(context).buttonColor,
            onChanged: (_) {
              _availabilityDataProvider.toggleLocation(model.locationName);
            },
          ),
        ));
      }
    }
    return list;
  }
}
