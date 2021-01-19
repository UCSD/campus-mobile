import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_stop.dart';
import 'package:campus_mobile_experimental/core/providers/shuttle.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class ManageShuttleView extends StatelessWidget {
  ShuttleDataProvider _shuttleDataProvider;

  @override
  Widget build(BuildContext context) {
    _shuttleDataProvider = Provider.of<ShuttleDataProvider>(context);
    return Stack(children: <Widget>[
      ContainerView(
        child: buildLocationsList(context),
      ),
      buildAddStopsButton(context),
    ]);
  }

  Widget buildLocationsList(BuildContext context) {
    if (_shuttleDataProvider.stopsToRender.isEmpty) {
      return (Center(child: Text("No saved stops.")));
    } else {
      return ReorderableListView(
        children: createList(context),
        onReorder: _onReorder,
      );
    }
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
    print("is called");
    for (ShuttleStopModel model in _shuttleDataProvider.stopsToRender) {
      if (model != null) {
        list.add(ListTile(
            key: Key(model.id.toString()),
            title: Text(
              model.name,
            ),
            leading: Icon(
              Icons.reorder,
            ),
            trailing: IconButton(
                icon: Icon(Icons.delete_forever),
                onPressed: () async {
                  await _shuttleDataProvider.removeStop(model.id);
                })));
      }
    }
    return list;
  }

  Widget buildAddStopsButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, bottom: 40.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: ColorPrimary,
          onPressed: () {
            Navigator.pushNamed(context, RoutePaths.AddShuttleStopsView);
          },
        ),
      ),
    );
  }
}
