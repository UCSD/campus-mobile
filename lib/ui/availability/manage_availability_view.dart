import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import 'package:provider/provider.dart';

import '../../core/hooks/availability_query.dart';
import '../../core/providers/user.dart';

class ManageAvailabilityView extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final queryClient = useQueryClient();
    final availability = useFetchAvailabilityModels();

    return ContainerView(
      child: ReorderableListView(
        children: buildLocationsList(context, availability.data!),
        onReorder: (oldIndex, newIndex) {
          queryClient.setQueryData<List<AvailabilityModel>>(['availability'],
              (previous) {
            if (oldIndex < newIndex)
              previous!.insert(newIndex - 1, previous.removeAt(oldIndex));
            else //oldIndex > newIndex
              previous!.insert(newIndex, previous.removeAt(oldIndex));
            return previous;
          });
        },
      ),
    );
  }

  // void _onReorder(int oldIndex, int newIndex) {
  //   if (newIndex > oldIndex) {
  //     newIndex -= 1;
  //   }
  //   List<AvailabilityModel?> newOrder =
  //       _availabilityDataProvider.availabilityModels;
  //
  //   //TODO: what is the point of this??
  //   List<AvailabilityModel> toRemove = [];
  //   newOrder.removeWhere((element) => toRemove.contains(element));
  //
  //   AvailabilityModel? item = newOrder.removeAt(oldIndex);
  //   newOrder.insert(newIndex, item);
  //   List<String?> orderedLocationNames = [];
  //   for (AvailabilityModel? item in newOrder) {
  //     orderedLocationNames.add(item!.name);
  //   }
  //   _availabilityDataProvider.reorderLocations(orderedLocationNames);
  // }

  List<Widget> buildLocationsList(
      BuildContext context, List<AvailabilityModel> availabilityModels) {
    List<Widget> list = [];
    for (AvailabilityModel? model in availabilityModels) {
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
            value: !Provider.of<UserDataProvider>(context)
                .userProfileModel!
                .isOccuspaceLocationDisabled(model
                    .name!), // check if the user did not disable a location
            // activeColor: Theme.of(context).buttonColor,
            activeColor: Theme.of(context).backgroundColor,
            onChanged: (_) {
              Provider.of<UserDataProvider>(context, listen: false)
                  .toggleOccuspaceLocation(model.name!);
              //_availabilityDataProvider.toggleLocation(model.name);
            },
          ),
        ));
      }
    }
    return list;
  }
}
