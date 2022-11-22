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

    newOrder.removeWhere((element) => toRemove.contains(element));
    AvailabilityModel? item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);
    List<String?> orderedLocationNames = [];
    for (AvailabilityModel? item in newOrder) {
      orderedLocationNames.add(item!.name);
    }
    _availabilityDataProvider.reorderLocations(orderedLocationNames);
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = [];
    for (AvailabilityModel? model
        in _availabilityDataProvider.availabilityModels) {
      if (model != null) {
        list.add(ListTile(
          key: Key(model.name.toString()),
          title: Text(
            model.name!,
          ),
          leading: Icon(
            Icons.reorder,
          ),
          trailing: Switch(
            value: Provider.of<AvailabilityDataProvider>(context)
                .locationViewState[model.name]!,
            // activeColor: Theme.of(context).buttonColor,
            activeColor: Theme.of(context).backgroundColor,
            onChanged: (_) {
              _availabilityDataProvider.toggleLocation(model.name);
            },
          ),
        ));
      }
    }
    return list;
  }
}
