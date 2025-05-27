import 'package:campus_mobile_experimental/core/models/dining.dart' as prefix0;
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/common/image_loader.dart';
import 'package:campus_mobile_experimental/ui/common/time_range_widget.dart';
import 'package:campus_mobile_experimental/ui/dining/dining_menu_list.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DiningDetailView extends StatelessWidget {
  const DiningDetailView({Key? key, required this.data}) : super(key: key);
  final prefix0.DiningModel data;
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: ListView.separated(
        itemCount: buildDetailView(context, data).length,
        separatorBuilder: (context, index) {
          return SizedBox(height: 8);
        },
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) {
          return buildDetailView(context, data)[index];
        },
      ),
    );
  }

  List<Widget> buildDetailView(
      BuildContext context, prefix0.DiningModel model) {
    return [
      Text(
        model.name,
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Text(
        model.description,
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      buildHours(context, model),
      if (model.specialHours != null) buildSpecialHours(context, model),
      buildPaymentOptions(context, model),
      //buildPictures(model),
      SizedBox(height: 10),
      Text(
        'Location',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      buildDirectionsButton(context, model),
      Row(
        children: [
          buildWebsiteButton(context, model),
          SizedBox(width: 15),
          buildMenuButton(context, model),
        ],
      ),
      // TODO: removed the menu on March 25, 2025
      //SizedBox(height: 20),
      //buildMenu(context, model),
    ];
  }

  Widget buildDirectionsButton(
      BuildContext context, prefix0.DiningModel model) {
    if (model.coordinates != null &&
        model.coordinates!.lat != null &&
        model.coordinates!.lon != null) {
      return TextButton(
        child: Row(
          children: <Widget>[
            Text(
              'Get Directions',
              style: linkTextDark.copyWith(fontSize: 14.0),
            ),
            Row(
              children: <Widget>[
                Icon(
                  Icons.directions_walk,
                  color: Theme.of(context).iconTheme.color,
                ),
                model.distance != null
                    ? Text(
                        num.parse(model.distance!.toStringAsFixed(1))
                                .toString() +
                            ' mi',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14.0,
                            ))
                    : Text('--'),
              ],
            ),
          ],
        ),
        onPressed: () {
          try {
            launch(
                'https://www.google.com/maps/dir/?api=1&destination=${model.coordinates!.lat},${model.coordinates!.lon}&travelmode=walking',
                forceSafariVC: true);
          } catch (e) {
            // an error occurred, do nothing
          }
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(0.0),
        ),
      );
    } else {
      return Text('Directions not available.',
          style: Theme.of(context).textTheme.bodySmall);
    }
  }

  Widget buildWebsiteButton(BuildContext context, prefix0.DiningModel model) {
    if (model.url != null && model.url != '') {
      return TextButton(
        child: Text('Visit Website'),
        onPressed: () {
          try {
            launch(model.url!, forceSafariVC: true);
          } catch (e) {
            // an error occurred, do nothing
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: actionButtonBackgroundColor,
          foregroundColor: lightPrimaryColor,
          padding: EdgeInsets.fromLTRB(20.0, 10, 20.0, 10),
        ),
      );
    } else
      return Container();
  }

  Widget buildMenuButton(BuildContext context, prefix0.DiningModel model) {
    if (model.menuWebsite != null && model.menuWebsite!.isNotEmpty) {
      return TextButton(
        child: Row(
          children: [
            Text('View Menu'),
            SizedBox(width: 5),
            Icon(Icons.open_in_new, size: 16),
          ],
        ),
        onPressed: () {
          try {
            launch(model.menuWebsite!, forceSafariVC: true);
          } catch (e) {
            // an error occurred, do nothing
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: Color(0xFF00629B),
          foregroundColor: Colors.white,
          padding: EdgeInsets.fromLTRB(20.0, 10, 20.0, 10),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget buildMenu(BuildContext context, prefix0.DiningModel model) {
    if (model.meals != null) {
      return DiningMenuList(
        model: model,
      );
    } else {
      return Container();
    }
  }

  Widget buildHours(BuildContext context, prefix0.DiningModel model) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 20),
      Text(
        "Hours",
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      SizedBox(height: 10),
      HoursOfDay(model: model, weekday: 1),
      buildDivider(context),
      HoursOfDay(model: model, weekday: 2),
      buildDivider(context),
      HoursOfDay(model: model, weekday: 3),
      buildDivider(context),
      HoursOfDay(model: model, weekday: 4),
      buildDivider(context),
      HoursOfDay(model: model, weekday: 5),
      buildDivider(context),
      HoursOfDay(model: model, weekday: 6),
      buildDivider(context),
      HoursOfDay(model: model, weekday: 7),
      SizedBox(height: 20),
    ]);
  }

  static Widget buildDivider(BuildContext context) {
    return Divider(
      height: 10,
      color: Theme.of(context).brightness == Brightness.dark
          ? listTileDividerColorDark
          : listTileDividerColorLight,
    );
  }

  Widget buildSpecialHours(BuildContext context, prefix0.DiningModel model) {
    var specialHoursDuration = "";
    if (model.specialHours?.specialHoursValidFrom != null &&
        model.specialHours?.specialHoursValidTo != null) {
      specialHoursDuration = model.specialHours!.specialHoursValidFrom! +
          " to " +
          model.specialHours!.specialHoursValidTo! +
          "\n";
    }
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "Special Hours",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 10),
        Text(
          model.specialHours!.specialHoursEvent,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          model.specialHours!.specialHoursEventDetails,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          specialHoursDuration,
          style: Theme.of(context).textTheme.bodySmall,
        )
      ]),
    );
  }

  Widget buildPaymentOptions(BuildContext context, prefix0.DiningModel model) {
    String options = model.paymentOptions.join(', ');
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Options",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 10),
          Text(
            options,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget buildPictures(prefix0.DiningModel model) {
    List<ImageLoader> images = [];
    if (model.images != null && model.images!.length > 0) {
      for (prefix0.Image item in model.images!) {
        if (item.small != null) images.add(ImageLoader(url: item.small!));
      }
      return Center(
        child: Container(
          height: 100,
          child: ListView.separated(
            itemCount: images.length,
            itemBuilder: (BuildContext context, int index) {
              return images[index];
            },
            separatorBuilder: (BuildContext context, int index) {
              return Container(width: 10);
            },
            scrollDirection: Axis.horizontal,
          ),
        ),
      );
    }
    return Container(height: 10);
  }
}

class HoursOfDay extends StatelessWidget {
  final int? weekday;
  final prefix0.DiningModel? model;

  const HoursOfDay({Key? key, this.weekday, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theDay;
    String? theHours;
    switch (weekday) {
      case 1:
        theDay = 'Monday';
        theHours = model!.regularHours.mon == null
            ? 'Closed'
            : model!.regularHours.mon;
        break;
      case 2:
        theDay = 'Tuesday';
        theHours = model!.regularHours.tue == null
            ? 'Closed'
            : model!.regularHours.tue;
        break;
      case 3:
        theDay = 'Wednesday';
        theHours = model!.regularHours.wed == null
            ? 'Closed'
            : model!.regularHours.wed;
        break;
      case 4:
        theDay = 'Thursday';
        theHours = model!.regularHours.thu == null
            ? 'Closed'
            : model!.regularHours.thu;
        break;
      case 5:
        theDay = 'Friday';
        theHours = model!.regularHours.fri == null
            ? 'Closed'
            : model!.regularHours.fri;
        break;
      case 6:
        theDay = 'Saturday';
        theHours = model!.regularHours.sat == null
            ? 'Closed'
            : model!.regularHours.sat;
        break;
      case 7:
        theDay = 'Sunday';
        theHours = model!.regularHours.sun == null
            ? 'Closed'
            : model!.regularHours.sun;
        break;
    }
    /*As of 05/05/2020, API may return 'Closed-Closed' as a value. If it does,
    correct it to look right.*/
    if (theHours == 'Closed-Closed') theHours = 'Closed';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 3,
              child: Row(
                children: [
                  weekday == DateTime.now().weekday
                      ? buildGreenDot(theHours!)
                      : Container(width: 10),
                  SizedBox(width: 5),
                  Text(
                    '$theDay: ',
                    style: weekday == DateTime.now().weekday
                        ? Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold)
                        : Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RegExp(r"\b[0-9]{2}").allMatches(theHours!).length != 2
                      ? Text(
                          theHours,
                          style: weekday == DateTime.now().weekday
                              ? Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.bold)
                              : Theme.of(context).textTheme.bodySmall,
                        )
                      : TimeRangeWidget(
                          time: theHours
                              .replaceAllMapped(
                                  //Add colon in between each time
                                  RegExp(r"\b[0-9]{2}"),
                                  (match) => "${match.group(0)}:")
                              .replaceAllMapped(
                                  //Add space around hyphen
                                  RegExp(r"-"),
                                  (match) => " ${match.group(0)} "),
                        ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildGreenDot(String hours) {
    MaterialColor color;
    if (RegExp(r"\b[0-9]{2}").allMatches(hours).length != 2) {
      //If the hours are a special string (not a time)
      /*If there are new strings that get returned instead of a time,
      put the strings here. This is a weird way to do it, but
      we're not in control of the API, so we have to manually determine
      if this means the establishment is open or not. The 'Closed' case is
      of my doing however as that simply denotes the establishment is closed.*/
      switch (hours) {
        case 'Closed':
          color = Colors.red;
          break;
        case 'Open 24/7':
          color = Colors.green;
          break;
        default:
          return Container();
      }
    } else {
      var times = hours.split('-');
      var start = int.parse(times[0]);
      var end = int.parse(times[1]);
      var timeNow;
      if (end < start) end += 2300; // If time goes into next day, prevent wrap
      if (DateTime.now().minute.toString().length == 1)
        timeNow = int.parse('${DateTime.now().hour}0${DateTime.now().minute}');
      else
        timeNow = int.parse('${DateTime.now().hour}${DateTime.now().minute}');
      if (timeNow >= start && timeNow < end)
        color = Colors.green;
      else
        color = Colors.red;
    }
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
