import 'package:campus_mobile_experimental/core/models/dining_model.dart'
    as prefix0;
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/image_loader.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/time_range_widget.dart';
import 'package:campus_mobile_experimental/ui/views/dining/dining_menu_list.dart';
import 'package:flutter/material.dart';

class DiningDetailView extends StatelessWidget {
  const DiningDetailView({Key key, @required this.data}) : super(key: key);
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
        model.name,
        textAlign: TextAlign.start,
        style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 26),
      ),
      Text(
        model.description,
        textAlign: TextAlign.start,
        style: TextStyle(
            color: Theme.of(context).textTheme.subtitle.color, fontSize: 15),
      ),
      buildHours(context, model),
      buildPaymentOptions(context, model),
      buildPictures(model),
      DiningMenuList(
        id: model.id,
      ),
    ];
  }

  Widget buildHours(BuildContext context, prefix0.DiningModel model) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "Hours:",
        textAlign: TextAlign.start,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      Divider(height: 6),
      HoursOfDay(model: model, weekday: 0),
      Divider(height: 10),
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
    ]);
  }

  Widget buildPaymentOptions(BuildContext context, prefix0.DiningModel model) {
    String options = model.paymentOptions.join(', ');
    return RichText(
      text: TextSpan(
        style: TextStyle(
            fontSize: Theme.of(context).textTheme.body1.fontSize,
            color: Theme.of(context).textTheme.body1.color),
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
    List<ImageLoader> images = List<ImageLoader>();
    if (model.images != null && model.images.length > 0) {
      for (prefix0.Image item in model.images) {
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
  final int weekday;
  final prefix0.DiningModel model;

  const HoursOfDay({Key key, this.weekday, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String theDay;
    String theHours;
    switch (weekday) {
      case 0:
        theDay = 'Sunday';
        theHours =
            model.regularHours.sun == null ? 'Closed' : model.regularHours.sun;
        break;
      case 1:
        theDay = 'Monday';
        theHours = model.regularHours.mon;
        break;
      case 2:
        theDay = 'Tuesday';
        theHours = model.regularHours.tue;
        break;
      case 3:
        theDay = 'Wednesday';
        theHours = model.regularHours.wed;
        break;
      case 4:
        theDay = 'Thursday';
        theHours = model.regularHours.thu;
        break;
      case 5:
        theDay = 'Friday';
        theHours = model.regularHours.fri;
        break;
      case 6:
        theDay = 'Saturday';
        theHours =
            model.regularHours.sat == null ? 'Closed' : model.regularHours.sat;
        break;
    }
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
                  RegExp(r"\b[0-9]{2}").allMatches(theHours).length != 2
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
    List<String> times = hours.split('-');
    int start = int.parse(times[0]);
    int end = int.parse(times[1]);
    if (end < start) end += 2300; //If time goes into next day, prevent wrap
    int timeNow = int.parse('${DateTime.now().hour}${DateTime.now().minute}');
    if (timeNow >= start && timeNow < end)
      color = Colors.green;
    else
      color = Colors.red;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
