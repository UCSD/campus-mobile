import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/dining_data_proivder.dart';
import 'package:campus_mobile_experimental/core/models/dining_model.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/time_range_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        ? ListView(
            primary: false,
            shrinkWrap: true,
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
    String dayHours;
    switch (weekday) {
      case 1:
        dayHours = hours.mon;
        break;
      case 2:
        dayHours = hours.tue;
        break;
      case 3:
        dayHours = hours.wed;
        break;
      case 4:
        dayHours = hours.thu;
        break;
      case 5:
        dayHours = hours.fri;
        break;
      case 6:
        if (hours.sat != null)
          dayHours = hours.sat;
        else
          return Text('closed');
        break;
      case 7:
        if (hours.sun != null)
          dayHours = hours.sun;
        else
          return Text('closed');
        break;
      default:
        {
          return Text('closed');
        }
    }
    if (RegExp(r"\b[0-9]{2}").allMatches(dayHours).length != 2)
      return Text(dayHours);
    return TimeRangeWidget(
        time: dayHours
            .replaceAllMapped(
                //Add colon in between each time
                RegExp(r"\b[0-9]{2}"),
                (match) => "${match.group(0)}:")
            .replaceAllMapped(
                //Add space around hyphen
                RegExp(r"[-]"),
                (match) => " ${match.group(0)} "));
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
        //overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 20, color: Theme.of(context).buttonColor),
      ),
      subtitle: getHoursForToday(data.regularHours),
      trailing: buildIconWithDistance(data.distance, context),
    );
  }

  Widget buildIconWithDistance(double distance, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.directions_walk,
          color: Theme.of(context).buttonColor,
        ),
        Text(
          distance != null ? distance.toStringAsPrecision(3) : '--',
          style: TextStyle(color: Theme.of(context).buttonColor),
        ),
      ],
    );
  }
}
