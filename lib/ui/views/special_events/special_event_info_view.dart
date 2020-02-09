import 'package:campus_mobile_experimental/core/data_providers/special_events_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/special_events_model.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SpecialEventsInfoView extends StatelessWidget {
  final String argument;
  const SpecialEventsInfoView({Key key, this.argument}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return addScaffold(
        context,
        Provider.of<SpecialEventsDataProvider>(context).specialEventsModel.name,
        argument);
  }

  Widget addScaffold(context, String title, uid) {
    SpecialEventsModel data =
        Provider.of<SpecialEventsDataProvider>(context).specialEventsModel;
    Schedule event = data.schedule[uid];
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: ListView(children: <Widget>[
            ListTile(
              title: buildHeader(event),
              trailing: Text('Icon'),
            ),
            ListTile(
              title: buildEventTitle(event),
            ),
            ListTile(
              title: buildLocationTile(event),
            ),
            ListTile(
              title: buildInfoTile(event),
            ),
            ListTile(
              title: new Text('Hosted By',
                  style: TextStyle(color: Colors.black87)),
            ),
            ListTile(
              title: buildHostTile(event),
            ),
          ]),
        ));
  }

  Widget buildHeader(Schedule event) {
    Color labelTheme = HexColor(event.labelTheme);
    // epoch time diff in Milliseconds -> to minutes
    num time = (event.endTime - event.startTime) / (1000 * 60);

    num hours = (time / 60).floor();
    num mins = (time % 60).floor();
    String timeString = ' - ';
    if (hours == 1)
      timeString = timeString + hours.toString() + " hour";
    else if (hours > 1) timeString = timeString + hours.toString() + " hours";

    if (mins > 0) timeString = timeString + " " + mins.toString() + " minutes";

    return RichText(
        text: TextSpan(
            text: event.label,
            style: TextStyle(color: labelTheme),
            children: <TextSpan>[
          TextSpan(text: timeString, style: TextStyle(color: Colors.black54)),
        ]));
  }
}

Widget buildEventTitle(Schedule event) {
  return RichText(
      text: TextSpan(
          text: event.talkTitle,
          style: TextStyle(color: ColorSecondary[900], fontSize: 25)));
}

Widget buildInfoTile(Schedule event) {
  return RichText(
      text: TextSpan(
          text: event.fullDescription,
          style: TextStyle(color: Colors.black54)));
}

Widget buildHostTile(Schedule event) {
  return RichText(
      text: TextSpan(
          text: event.speakerShortdesc,
          style: TextStyle(color: ColorSecondary)));
}

Widget buildLocationTile(Schedule event) {
  DateTime date = new DateTime.fromMillisecondsSinceEpoch(event.startTime);
  String time = DateFormat.jm().format(date);
  //String dateString = (DateFormat('yMMMd').format(date));
  String dateString = (DateFormat("MMM d'th' y").format(date));
  String locDateString = event.location + " - " + dateString + ", " + time;
  return RichText(
      text:
          TextSpan(text: locDateString, style: TextStyle(color: Colors.grey)));
}

//Helper class to convert RGB to ARGB for flutter
//TODO - Add to like a shared library
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
