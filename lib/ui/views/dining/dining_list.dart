import 'package:flutter/material.dart';
import 'package:campus_mobile_beta/ui/widgets/image_loader.dart';
import 'package:campus_mobile_beta/core/models/dining_model.dart';
import 'package:campus_mobile_beta/ui/widgets/container_view.dart';
import 'package:campus_mobile_beta/core/constants/app_constants.dart';

class DiningList extends StatelessWidget {
  const DiningList({Key key, @required this.data, this.listSize})
      : super(key: key);

  final List<DiningModel> data;
  final int listSize;

  @override
  Widget build(BuildContext context) {
    return buildEventsList(data, context);
  }

  Widget buildEventsList(List<DiningModel> listOfDiners, BuildContext context) {
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
        Navigator.pushNamed(context, RoutePaths.EventDetailView,
            arguments: data);
      },
      title: Text(
        data.name,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: getHoursForToday(data.regularHours),
      trailing: Icon(Icons.directions_walk),
    );
  }
}
