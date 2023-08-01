import 'package:campus_mobile_experimental/core/models/dining.dart' as prefix0;
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/common/image_loader.dart';
import 'package:campus_mobile_experimental/ui/common/time_range_widget.dart';
import 'package:campus_mobile_experimental/ui/dining/dining_menu_list.dart';
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
        padding: const EdgeInsets.all(8),
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
        model.name!,
        textAlign: TextAlign.start,
        style: TextStyle(fontSize: 26),
      ),
      Text(
        model.description!,
        textAlign: TextAlign.start,
        style: TextStyle(fontSize: 15),
      ),
      buildHours(context, model),
      buildPaymentOptions(context, model),
      buildPictures(model),
      Divider(),
      buildDirectionsButton(context, model),
      Divider(),
      buildWebsiteButton(context, model),
      buildMenu(context, model),
    ];
  }

  Widget buildDirectionsButton(
      BuildContext context, prefix0.DiningModel model) {
    if (model.coordinates != null &&
        model.coordinates!.lat != null &&
        model.coordinates!.lon != null) {
      return TextButton(
        style: TextButton.styleFrom(
          // primary: Theme.of(context).buttonColor,
          primary: Theme.of(context).backgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Directions',
              style: TextStyle(fontSize: 25),
            ),
            Column(
              children: <Widget>[
                Icon(
                  Icons.directions_walk,
                  size: 30,
                ),
                model.distance != null
                    ? Text(num.parse(model.distance!.toStringAsFixed(1))
                            .toString() +
                        ' mi')
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
      );
    } else {
      return Center(child: Text('Directions not available.'));
    }
  }

  Widget buildWebsiteButton(BuildContext context, prefix0.DiningModel model) {
    if (model.url != null && model.url != '') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Theme.of(context).primaryColor, // foreground
          // primary: Theme.of(context).buttonColor,
          primary: Theme.of(context).backgroundColor,
        ),
        child: Text('Visit Website',
            style: TextStyle(
              color: Theme.of(context).textTheme.button!.color,
            )),
        onPressed: () {
          try {
            launch(model.url!, forceSafariVC: true);
          } catch (e) {
            // an error occurred, do nothing
          }
        },
      );
    } else
      return Container();
  }

  Widget buildMenu(BuildContext context, prefix0.DiningModel model) {
    if (model.menuWebsite != null && model.menuWebsite!.isNotEmpty) {
      return ElevatedButton(
        child: Text('View Menu',
            style: TextStyle(
              color: Theme.of(context).textTheme.button!.color,
            )),
        style: ElevatedButton.styleFrom(
          onPrimary: Theme.of(context).primaryColor, // foreground
          // primary: Theme.of(context).buttonColor,
          primary: Theme.of(context).backgroundColor,
        ),
        onPressed: () {
          try {
            launch(model.menuWebsite!, forceSafariVC: true);
          } catch (e) {
            // an error occurred, do nothing
          }
        },
      );
    } else
      return DiningMenuList(
        model: model,
      );
  }

  Widget buildHours(BuildContext context, prefix0.DiningModel model) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "Hours:",
        textAlign: TextAlign.start,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      Divider(height: 6),
      HoursOfDay(model: model, weekday: 1),
      Divider(height: 10),
      HoursOfDay(model: model, weekday: 2),
      Divider(height: 10),
      HoursOfDay(model: model, weekday: 3),
      Divider(height: 10),
      HoursOfDay(model: model, weekday: 4),
      Divider(height: 10),
      HoursOfDay(model: model, weekday: 5),
      Divider(height: 10),
      HoursOfDay(model: model, weekday: 6),
      Divider(height: 10),
      HoursOfDay(model: model, weekday: 7),
      Divider(height: 10),
    ]);
  }

  Widget buildPaymentOptions(BuildContext context, prefix0.DiningModel model) {
    String options = model.paymentOptions!.join(', ');
    return RichText(
      text: TextSpan(
        style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyText2!.fontSize,
            color: Theme.of(context).textTheme.bodyText2!.color),
        children: [
          TextSpan(
            text: "Payment Options:\n",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          TextSpan(text: options),
        ],
      ),
    );
  }

  Widget buildPictures(prefix0.DiningModel model) {
    List<ImageLoader> images = [];
    if (model.images != null && model.images!.length > 0) {
      for (prefix0.Image item in model.images!) {
        images.add(ImageLoader(
          url: item.small,
        ));
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
    String? theDay;
    String? theHours;
    switch (weekday) {
      case 1:
        theDay = 'Monday';
        theHours = model!.regularHours!.mon == null
            ? 'Closed'
            : model!.regularHours!.mon;
        break;
      case 2:
        theDay = 'Tuesday';
        theHours = model!.regularHours!.tue == null
            ? 'Closed'
            : model!.regularHours!.tue;
        break;
      case 3:
        theDay = 'Wednesday';
        theHours = model!.regularHours!.wed == null
            ? 'Closed'
            : model!.regularHours!.wed;
        break;
      case 4:
        theDay = 'Thursday';
        theHours = model!.regularHours!.thu == null
            ? 'Closed'
            : model!.regularHours!.thu;
        break;
      case 5:
        theDay = 'Friday';
        theHours = model!.regularHours!.fri == null
            ? 'Closed'
            : model!.regularHours!.fri;
        break;
      case 6:
        theDay = 'Saturday';
        theHours = model!.regularHours!.sat == null
            ? 'Closed'
            : model!.regularHours!.sat;
        break;
      case 7:
        theDay = 'Sunday';
        theHours = model!.regularHours!.sun == null
            ? 'Closed'
            : model!.regularHours!.sun;
        break;
    }
    /*As of 05/05/2020, API may return 'Closed-Closed' as a value. If it does,
    correct it to look right.*/
    if (theHours == 'Closed-Closed') theHours = 'Closed';
    return Stack(
      children: [
        Text('$theDay: '),
        Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RegExp(r"\b[0-9]{2}").allMatches(theHours!).length != 2
                      ? Text(theHours)
                      : TimeRangeWidget(
                          time: theHours
                              .replaceAllMapped(
                                  //Add colon in between each time
                                  RegExp(r"\b[0-9]{2}"),
                                  (match) => "${match.group(0)}:")
                              .replaceAllMapped(
                                  //Add space around hyphen
                                  RegExp(r"-"),
                                  (match) => " ${match.group(0)} ")),
                  SizedBox(width: 4),
                  weekday == DateTime.now().weekday
                      ? buildGreenDot(theHours)
                      : Container(width: 10),
                ],
              ),
            ),
          ],
        )
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
      List<String> times = hours.split('-');
      int start = int.parse(times[0]);
      int end = int.parse(times[1]);
      if (end < start) end += 2300; //If time goes into next day, prevent wrap
      int timeNow;
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
