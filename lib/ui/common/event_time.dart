import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventTime extends StatelessWidget {
  final EventModel? data;
  const EventTime({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      // Separate dates from times
      var startMonthDay = DateFormat.MMMd().format(data!.startDate!.toLocal());
      var endMonthDay = DateFormat.MMMd().format(data!.endDate!.toLocal());
      var startTime = DateFormat.jm().format(data!.startDate!.toLocal());
      var endTime = DateFormat.jm().format(data!.endDate!.toLocal());

      // Mark any special types of events
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
