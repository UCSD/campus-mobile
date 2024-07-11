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
    RegExp multiPager = RegExp(r' \((\d+)/(\d+)\)$');
    List<AvailabilityModel?> newOrder =
        _availabilityDataProvider.availabilityModels;
    List<AvailabilityModel?> extraPages = [];
    // -----Must remove pages after head of multi pagers and reinsert later to avoid reordering errors-----
    for (AvailabilityModel? item in newOrder) {
      RegExpMatch? match = multiPager.firstMatch(item!.name!);
      if (match != null) {
        if (match.group(1) != "1") {
          extraPages.add(item);
        }
      }
    }
    for (AvailabilityModel? item in extraPages) {
      newOrder.remove(item);
    }
    // ----------------------------------------------------------------------------------------------------
    List<AvailabilityModel> toRemove = [];
    newOrder.removeWhere((element) => toRemove.contains(element));
    AvailabilityModel? item = newOrder.removeAt(oldIndex);
    if (newIndex > oldIndex) {
      newIndex--;
    }
    newOrder.insert(newIndex, item);
    List<String?> orderedLocationNames = [];
    for (AvailabilityModel? item in newOrder) {
      orderedLocationNames.add(item!.name);
    }
    for (int index = 0; index < orderedLocationNames.length; index++) {
      RegExpMatch? match = multiPager.firstMatch(orderedLocationNames[index]!);
      if (match != null) {
        if (match.group(1) == "1") {
          String baseName = orderedLocationNames[index]!
              .replaceRange(match.start, match.end, '');
          int curPageIndex = 2;
          int maxPageIndex = int.parse(match.group(2)!);
          while (curPageIndex <= maxPageIndex) {
            index++;
            orderedLocationNames.insert(
                index, baseName + " ($curPageIndex/$maxPageIndex)");
            curPageIndex++;
          }
        } else {
          orderedLocationNames.removeAt(index);
          index--;
        }
      }
    }
    _availabilityDataProvider.reorderLocations(orderedLocationNames);
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = [];
    Set<String> existingKeys = {};
    RegExp multiPager = RegExp(r' \(\d+/\d+\)$');
    for (AvailabilityModel? model
        in _availabilityDataProvider.availabilityModels) {
      if (model != null) {
        String curName = model.name!;
        RegExpMatch? match = multiPager.firstMatch(curName);
        if (match != null) {
          curName = curName.replaceRange(match.start, match.end, '');
        }
        if (existingKeys.contains(curName)) {
          continue;
        }
        existingKeys.add(curName);
        list.add(ListTile(
          key: Key(curName),
          title: Text(
            curName,
          ),
          leading: Icon(
            Icons.reorder,
          ),
          trailing: Switch(
            value: Provider.of<AvailabilityDataProvider>(context)
                .locationViewState[curName]!,
            // activeColor: Theme.of(context).buttonColor,
            activeColor: Theme.of(context).colorScheme.background,
            onChanged: (_) {
              _availabilityDataProvider.toggleLocation(curName);
            },
          ),
        ));
      }
    }
    return list;
  }
}
