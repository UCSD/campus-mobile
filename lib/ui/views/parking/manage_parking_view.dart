import 'package:campus_mobile_experimental/core/models/parking_model.dart';
import 'package:campus_mobile_experimental/core/services/parking_service.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/widgets/container_view.dart';
import 'package:provider/provider.dart';

class ManageParkingView extends StatelessWidget {
  ParkingService _parkingService;
  @override
  Widget build(BuildContext context) {
    _parkingService = Provider.of<ParkingService>(context);
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
    List<ParkingModel> newOrder = _parkingService.data;
    ParkingModel item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);
    _parkingService.data = newOrder;
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = List<Widget>();
    for (ParkingModel model in _parkingService.data) {
      list.add(ListTile(
        key: Key(model.locationId.toString()),
        title: Text(model.locationName),
        trailing: Icon(Icons.reorder),
      ));
    }
    return list;
  }
}
