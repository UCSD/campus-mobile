import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campus_mobile_experimental/app_styles.dart';

/// This object takes a String that represents a time range in 24 hour format
/// e.g. 17:01 - 19:20
/// be cautious of the spacing, it must be exactly as shown above
/// The TimeRangeWidget will build a Text Widget that displays 5:01 PM - 8:20 PM
class TimeRangeWidget extends StatelessWidget {
  const TimeRangeWidget({
    Key? key,
    required this.time,
  }) : super(key: key);

  final String time;

  @override
  Widget build(BuildContext context) {
    return Text(
      getStartTime(context) + ' - ' + getStopTime(context),
      style: Theme.of(context).brightness == Brightness.dark
          ? descriptiveTextSmallDark
          : descriptiveTextSmallLight,
    );
  }

  String getStartTime(BuildContext context) {
    var times = time.split("-");
    return stringToTimeOfDay(times[0]).format(context);
  }

  String getStopTime(BuildContext context) {
    var times = time.split("- ");
    return stringToTimeOfDay(times[1]).format(context);
  }

  static TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.Hm();
    return TimeOfDay.fromDateTime(format.parse(tod));
  }
}

/// Returns time in the format of HH:MM AM - HH:MM PM
String? formattedTimeRange(String? theHours) {
  if (theHours == null) return theHours;
  final match = RegExp(r'^(\d{2})(\d{2})-(\d{2})(\d{2})$').firstMatch(theHours);
  if (match == null) return theHours;

  try {
    final now = DateTime.now();
    final startTime = DateTime(
      now.year, now.month, now.day,
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
    );
    final endTime = DateTime(
      now.year, now.month, now.day,
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
    );
    return '${DateFormat.jm().format(startTime)} - ${DateFormat.jm().format(endTime)}';
  } catch (_) {
    return theHours;
  }
}
