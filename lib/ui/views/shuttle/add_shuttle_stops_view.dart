import 'package:campus_mobile_experimental/core/data_providers/shuttle_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival_model.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop_model.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/dots_indicator.dart';
import 'package:campus_mobile_experimental/ui/cards/shuttle/shuttle_display.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddShuttleStopsView extends StatelessWidget {
  ShuttleDataProvider _shuttleDataProvider;

  @override
  Widget build(BuildContext context) {
    _shuttleDataProvider = Provider.of<ShuttleDataProvider>(context);
    return Stack(children: <Widget>[
      ContainerView(
        child: buildAllLocationsList(context),
      ),
    ]);
  }

  Widget buildAllLocationsList(BuildContext context) {
    return ReorderableListView(
      children: createList(context),
      onReorder: _onReorder,
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    List<ShuttleStopModel> newOrder = _shuttleDataProvider.stopsToRender;
    List<ShuttleStopModel> toRemove = List<ShuttleStopModel>();

    for (ShuttleStopModel item in newOrder) {
      if (_shuttleDataProvider.stopsToRender == null) {
        toRemove.add(item);
      }
    }
    newOrder.removeWhere((element) => toRemove.contains(element));
    ShuttleStopModel item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);
    List<int> orderedStopNames = List<int>();
    for (ShuttleStopModel item in newOrder) {
      orderedStopNames.add(item.id);
    }
    _shuttleDataProvider.reorderStops(orderedStopNames);
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = List<Widget>();
    _shuttleDataProvider.fetchedStops.forEach((key, value) {
      ShuttleStopModel model = value;
      if (model != null) {
        list.add(ListTile(
          key: Key(model.id.toString()),
          title: Text(
            model.name,
          ),
          leading: Icon(
            Icons.reorder,
          ),
          trailing: Switch(
            value: _shuttleDataProvider.stopsToRender.contains(value),
            activeColor: Theme.of(context).buttonColor,
            onChanged: (_) {
              _shuttleDataProvider.stopsToRender.add(value);
            },
          ),
        ));
      }
    });

    return list;
  }
}
