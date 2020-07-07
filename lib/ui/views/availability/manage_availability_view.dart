import 'package:campus_mobile_experimental/core/data_providers/availability_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/ui/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:campus_mobile_experimental/core/models/availability_model.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';

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
      if (item != null) {
        orderedLocationNames.add(item.locationName);
      }
    }
    _availabilityDataProvider.reorderLocations(orderedLocationNames);
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = List<Widget>();
    for (AvailabilityModel model
        in _availabilityDataProvider.availabilityModels) {
      if (model != null) {
        list.add(ListTile(
          key: Key(model.locationId.toString()),
          title: Text(
            model.locationName,
          ),
          leading: Icon(
            Icons.reorder,
          ),
          trailing: Switch(
            value: Provider.of<AvailabilityDataProvider>(context)
                .locationViewState[model.locationName],
            activeColor: Theme.of(context).textTheme.button.color,
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
