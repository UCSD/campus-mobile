import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventTime extends StatelessWidget {
  final EventModel data;
  const EventTime({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      // Extract only the times (String)
      var startTime = DateFormat.jm().format(data.startDate.toLocal());
      var endTime = DateFormat.jm().format(data.endDate.toLocal());

      return Text(startTime + ' - ' + endTime); // ex: "8:00 AM - 12:00 PM"
    } catch (e) {
      print(e);
      return Container();
    }
  }
}

class EventDate extends StatelessWidget {
  final EventModel data;
  const EventDate({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      // Extract only the dates (String)
      var startMonthDay = DateFormat.MMMd().format(data.startDate.toLocal());
      var endMonthDay = DateFormat.MMMd().format(data.endDate.toLocal());

      return Text(startMonthDay + ' - ' + endMonthDay); // ex: "Jan. 1 - Jan. 2"
    } catch (e) {
      print(e);
      return Container();
    }
  }
}

class EventDateTime extends StatelessWidget {
  final EventModel data;
  const EventDateTime({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      // Separate dates from times (String)
      var startMonthDay = DateFormat.MMMd().format(data.startDate.toLocal());
      var endMonthDay = DateFormat.MMMd().format(data.endDate.toLocal());
      var startTime = DateFormat.jm().format(data.startDate.toLocal());
      var endTime = DateFormat.jm().format(data.endDate.toLocal());

      // Mark any special types of events (bool)
      var sameDay = (startMonthDay == endMonthDay);
      var unspecifiedTime = (startTime == '12:00 AM' && endTime == '12:00 AM');

      if (sameDay) {
        if (!unspecifiedTime) {
          return Text(startMonthDay +
              ', ' +
              startTime +
              ' - ' +
              endTime); // ex: Jan. 1, 8:00 AM - 12:00 PM
        } else {
          return Text(startMonthDay); // ex: Jan. 1
        }
      } else {
        if (!unspecifiedTime) {
          return Text(startMonthDay +
              ', ' +
              startTime +
              ' - ' +
              endMonthDay +
              ', ' +
              endTime); // ex: Jan. 1, 8:00 AM - Jan. 2, 12:00 PM
        } else {
          return Text(
              startMonthDay + ' - ' + endMonthDay); // ex: Jan. 1 - Jan. 2
        }
      }
    } catch (e) {
      print(e);
      return Container();
    }
  }
}

class EventTileDateTime extends StatelessWidget {
  final EventModel data;
  const EventTileDateTime({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      // Separate dates from times
      var startMonthDayYear =
          DateFormat.yMMMMd('en_US').format(data.startDate.toLocal());
      var endMonthDayYear =
          DateFormat.yMMMMd('en_US').format(data.endDate.toLocal());
      var startTime = DateFormat.jm().format(data.startDate.toLocal());
      var endTime = DateFormat.jm().format(data.endDate.toLocal());

      // Mark any special types of events
      var sameDay = (startMonthDayYear == endMonthDayYear);
      var unspecifiedTime = (startTime == '12:00 AM' && endTime == '12:00 AM');
      Widget date, time;
      if (sameDay) {
        date = Text(
          startMonthDayYear,
          style: TextStyle(fontSize: 12),
        ); // Ex. June 11, 2021
      } else {
        // if not the same date, check if the same year
        var startYear = startMonthDayYear.substring(
            startMonthDayYear.indexOf(',') + 2, startMonthDayYear.length);
        var endYear = endMonthDayYear.substring(
            endMonthDayYear.indexOf(',') + 2, endMonthDayYear.length);
        if (startYear == endYear) {
          // if the same year, check if the same month
          var startMonth =
              startMonthDayYear.substring(0, startMonthDayYear.indexOf(' '));
          var endMonth =
              endMonthDayYear.substring(0, endMonthDayYear.indexOf(' '));
          if (startMonth == endMonth) {
            // if different date in the same month and year
            var startDay = startMonthDayYear.substring(
                startMonthDayYear.indexOf(' ') + 1,
                startMonthDayYear.indexOf(','));
            var endDay = endMonthDayYear.substring(
                endMonthDayYear.indexOf(' ') + 1, endMonthDayYear.indexOf(','));
            date = Text(
              startMonth + ' ' + startDay + ' - ' + endDay + ', ' + startYear,
              style: TextStyle(fontSize: 12),
            ); // Ex. September 11 - 26, 2021
          } else {
            // if different month in the same year
            var startMonthDay =
                startMonthDayYear.substring(0, startMonthDayYear.indexOf(','));
            var endMonthDay =
                endMonthDayYear.substring(0, endMonthDayYear.indexOf(','));
            date = Text(
              startMonthDay + ' - ' + endMonthDay + ', ' + startYear,
              style: TextStyle(fontSize: 12),
            ); // Ex. September 11 - October 26, 2021
          }
        } else {
          date = Text(
            startMonthDayYear + ' - ' + endMonthDayYear,
            style: TextStyle(fontSize: 12),
          ); // Ex. June 11, 2021 - May 12, 2023
        }
      }

      if (unspecifiedTime) {
        time = Text(
          '',
          style: TextStyle(fontSize: 12),
        );
      } else {
        time = Text(
          startTime + ' - ' + endTime,
          style: TextStyle(fontSize: 12),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          date,
          Padding(
            padding: EdgeInsets.only(bottom: 5),
          ),
          time
        ],
      );
    } catch (e) {
      print(e);
      return Container();
    }
  }
}
