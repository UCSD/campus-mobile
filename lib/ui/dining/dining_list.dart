import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/dining.dart';
import 'package:campus_mobile_experimental/core/providers/dining.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/common/time_range_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DiningList extends StatelessWidget {
  const DiningList({
    Key? key,
    this.listSize,
  }) : super(key: key);

  final int? listSize;

  @override
  Widget build(BuildContext context) {
    List<DiningModel> data =
        Provider.of<DiningDataProvider>(context).diningModels;
    return data.length > 0
        ? buildDiningList(data, context)
        : CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary);
  }

  Widget buildDiningList(List<DiningModel> listOfDiners, BuildContext context) {
    final List<Widget> diningTiles = [];

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
            physics: NeverScrollableScrollPhysics(),
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

  Widget getHoursForToday(RegularHours? hours) {
    int weekday = DateTime.now().weekday;
    String? dayHours;

    switch (weekday) {
      case 1:
        if (hours!.mon != null)
          dayHours = hours.mon;
        else
          return Text('Closed');
        break;
      case 2:
        if (hours!.tue != null)
          dayHours = hours.tue;
        else
          return Text('Closed');
        break;
      case 3:
        if (hours!.wed != null)
          dayHours = hours.wed;
        else
          return Text('Closed');
        break;
      case 4:
        if (hours!.thu != null)
          dayHours = hours.thu;
        else
          return Text('Closed');
        break;
      case 5:
        if (hours!.fri != null)
          dayHours = hours.fri;
        else
          return Text('Closed');
        break;
      case 6:
        if (hours!.sat != null)
          dayHours = hours.sat;
        else
          return Text('Closed');
        break;
      case 7:
        if (hours!.sun != null)
          dayHours = hours.sun;
        else
          return Text('Closed');
        break;
      default:
        return Text('Closed');
    }
    if (RegExp(r"\b[0-9]{2}").allMatches(dayHours!).length != 2) {
      if (dayHours == 'Closed-Closed') {
        return Text('Closed');
      } else {
        return Text(dayHours);
      }
    }

    return TimeRangeWidget(
        time: dayHours
            .replaceAllMapped(
                //Add colon in between each time
                RegExp(r"\b[0-9]{2}"),
                (match) => "${match.group(0)}:")
            .replaceAllMapped(
                //Add space around hyphen
                RegExp(r"-"),
                (match) => " ${match.group(0)} "));
  }

  Widget buildDiningTile(DiningModel data, BuildContext context) {
    return ListTile(
      onTap: () {
        if (data.id != null) {
          Provider.of<DiningDataProvider>(context, listen: false)
              .fetchDiningMenu(data.id!);
        }
        Navigator.pushNamed(context, RoutePaths.DiningDetailView,
            arguments: data);
      },
      title: Text(
        data.name!,
        textAlign: TextAlign.start,
        //overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 18),
      ),
      subtitle: getHoursForToday(data.regularHours),
      trailing: buildIconWithDistance(data, context),
    );
  }

  Widget buildIconWithDistance(DiningModel data, BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        // primary: Theme.of(context).buttonColor,
        primary: Theme.of(context).backgroundColor,
      ),
      onPressed: () {
        try {
          launch(
              'https://www.google.com/maps/dir/?api=1&travelmode=walking&destination=${data.coordinates!.lat},${data.coordinates!.lon}',
              forceSafariVC: true);
        } catch (e) {
          // an error occurred, do nothing
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Icon(Icons.directions_walk),
          ),
          Padding(padding: EdgeInsets.only(bottom: 7.0)),
          Expanded(
            child: Text(
              data.distance != null
                  ? (num.parse(data.distance!.toStringAsFixed(1)).toString() +
                      ' mi')
                  : '--',
            ),
          ),
        ],
      ),
    );
  }
}
