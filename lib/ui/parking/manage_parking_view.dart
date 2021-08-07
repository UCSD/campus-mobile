import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/core/providers/parking.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageParkingView extends StatefulWidget {
  _ManageParkingViewState createState() => _ManageParkingViewState();
}

///OLD MANAGE
// class _ManageParkingViewState extends State<ManageParkingView> {
//   late ParkingDataProvider parkingDataProvider;
//   @override
//   Widget build(BuildContext context) {
//     parkingDataProvider = Provider.of<ParkingDataProvider>(context);
//     return ContainerView(
//       child: buildLocationsList(context),
//     );
//   }
//
//   Widget buildLocationsList(BuildContext context) {
//     return ReorderableListView(
//       children: createList(context),
//       onReorder: _onReorder,
//     );
//   }
//
//   void _onReorder(int oldIndex, int newIndex) {
//     if (newIndex > oldIndex) {
//       newIndex -= 1;
//     }
//     List<ParkingModel> newOrder = parkingDataProvider.parkingModels;
//     ParkingModel item = newOrder.removeAt(oldIndex);
//     newOrder.insert(newIndex, item);
//     List<String?> orderedLocationNames = [];
//     for (ParkingModel item in newOrder) {
//       orderedLocationNames.add(item.locationName);
//     }
//     //parkingDataProvider.reorderLots(orderedLocationNames);
//   }
//
//   List<Widget> createList(BuildContext context) {
//     List<Widget> list = [];
//     for (ParkingModel model in parkingDataProvider.parkingModels) {
//       list.add(ListTile(
//           key: Key(model.locationId.toString()),
//           title: Text(model.locationName!),
//           leading: Icon(Icons.reorder),
//           trailing: Switch(
//             value: Provider.of<ParkingDataProvider>(context)
//                 .parkingViewState![model.locationName]!,
//             onChanged: (_) {
//               parkingDataProvider.toggleLot(model.locationName);
//             },
//             activeColor: Theme.of(context).buttonColor,
//           )));
//     }
//     return list;
//   }
// }
///
class _ManageParkingViewState extends State<ManageParkingView> {
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: buildLocationsList(context),
    );
  }

  Widget buildLocationsList(BuildContext context) {
    // creates a list that will hold the list of building names
    List<Widget> list = [];

    List<String> parkingType = [
      "Neighborhoods",
      "Parking Structure",
      "Parking Lots"
    ];

    List<String> parkingTypeViews = [
      "NeighborhoodsView",
      "ParkingStructureView",
      "ParkingLotsView"
    ];

    // loops through and adds buttons for the user to click on
    for (var i = 0; i < parkingType.length; i++) {
      var type = parkingTypeViews[i];
      list.add(ListTile(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: Text(
            "${parkingType[i]}",
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary, fontSize: 20),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).iconTheme.color,
        ),
        onTap: () {
          if (i == 0) {
            Navigator.pushNamed(
              context,
              RoutePaths.NeighborhoodsView,
            );
          }
          if (i == 1) {
            Navigator.pushNamed(
              context,
              RoutePaths.ParkingStructureView,
            );
          }
          if (i == 2) {
            Navigator.pushNamed(
              context,
              RoutePaths.ParkingLotsView,
            );
          }
        },
      ));
    }

    // adds SizedBox to have a grey underline for the last item in the list
    list.add(SizedBox());

    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: ListTile.divideTiles(tiles: list, context: context).toList(),
    );
  }
}
