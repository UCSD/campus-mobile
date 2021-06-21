import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageParkingView extends StatefulWidget {
  _ManageParkingViewState createState() => _ManageParkingViewState();
}

class _ManageParkingViewState extends State<ManageParkingView> {
  late ParkingDataProvider parkingDataProvider;
  @override
  Widget build(BuildContext context) {
    parkingDataProvider = Provider.of<ParkingDataProvider>(context);
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
    List<ParkingModel> newOrder = parkingDataProvider.parkingModels;
    ParkingModel item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);
    List<String?> orderedLocationNames = [];
    for (ParkingModel item in newOrder) {
      orderedLocationNames.add(item.locationName);
    }
    // parkingDataProvider.reorderLots(orderedLocationNames);
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = [];
    for (ParkingModel model in parkingDataProvider.parkingModels) {
      list.add(ListTile(
          key: Key(model.locationId.toString()),
          title: Text(model.locationName!),
          leading: Icon(Icons.reorder),
          trailing: Switch(
            value: Provider.of<ParkingDataProvider>(context)
                .parkingViewState![model.locationName]!,
            onChanged: (_) {
              parkingDataProvider.toggleLot(model.locationName);
            },
            activeColor: Theme.of(context).buttonColor,
          )));
    }
    return list;
  }
}
