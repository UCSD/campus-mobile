import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/models/dining_model.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/dining_data_proivder.dart';

class DiningList extends StatelessWidget {
  const DiningList({
    Key key,
    this.listSize,
  }) : super(key: key);

  final int listSize;

  @override
  Widget build(BuildContext context) {
    List<DiningModel> data =
        Provider.of<DiningDataProvider>(context).diningModels;
    return data.length > 0
        ? buildDiningList(data, context)
        : CircularProgressIndicator();
  }

  Widget buildDiningList(List<DiningModel> listOfDiners, BuildContext context) {
    final List<Widget> diningTiles = List<Widget>();

    /// check to see if we want to display only a limited number of elements
    /// if no constraint is given on the size of the list then all elements
    /// are rendered
    var size;
    if (listSize == null)
      size = listOfDiners.length;
    else
      size = listSize;
    for (int i = 0; i < size; i++) {
      final DiningModel item = listOfDiners[i];
      final tile = buildDiningTile(item, context);
      diningTiles.add(tile);
    }

    return listSize != null
        ? Column(
            children: ListTile.divideTiles(tiles: diningTiles, context: context)
                .toList(),
          )
        : ContainerView(
            child: ListView(
              children:
                  ListTile.divideTiles(tiles: diningTiles, context: context)
                      .toList(),
            ),
          );
  }

  Widget getHoursForToday(RegularHours hours) {
    int weekday = DateTime.now().weekday;
    switch (weekday) {
      case 1:
        {
          return Text(hours.mon);
        }
        break;

      case 2:
        {
          return Text(hours.tue);
        }
        break;
      case 3:
        {
          return Text(hours.wed);
        }
        break;
      case 4:
        {
          return Text(hours.thu);
        }
        break;
      case 5:
        {
          return Text(hours.fri);
        }
        break;
      case 6:
        {
          return Text(hours.sat);
        }
        break;
      case 7:
        {
          return Text(hours.sun);
        }
        break;

      default:
        {
          return Text('closed');
        }
    }
  }

  Widget buildDiningTile(DiningModel data, BuildContext context) {
    return ListTile(
      onTap: () {
        if (data.id != null) {
          Provider.of<DiningDataProvider>(context, listen: false)
              .fetchDiningMenu(data.id);
        }
        Navigator.pushNamed(context, RoutePaths.DiningDetailView,
            arguments: data);
      },
      title: Text(
        data.name,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: getHoursForToday(data.regularHours),
      trailing: buildIconWithDistance(data.distance),
    );
  }

  Widget buildIconWithDistance(double distance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.directions_walk,
        ),
        Text(
          distance != null ? distance.toStringAsPrecision(3) : '--',
        ),
      ],
    );
  }
}
