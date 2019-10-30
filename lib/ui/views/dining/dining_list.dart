import 'package:flutter/material.dart';
import 'package:campus_mobile_beta/core/models/dining_model.dart';
import 'package:campus_mobile_beta/ui/widgets/container_view.dart';
import 'package:campus_mobile_beta/core/constants/app_constants.dart';

class DiningList extends StatelessWidget {
  const DiningList({
    Key key,
    @required this.data,
    this.listSize,
  }) : super(key: key);

  final Future<List<DiningModel>> data;
  final int listSize;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DiningModel>>(
        future: data,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? buildDiningList(snapshot.data, context)
              : CircularProgressIndicator();
        });
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
        Navigator.pushNamed(context, RoutePaths.DiningDetailView,
            arguments: Future<DiningModel>(() => data));
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
