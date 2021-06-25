import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// This object takes a String that represents a time range in 24 hour format
/// e.g. 17:01 - 19:20
/// be cautious of the spacing, it must be exactly as shown above
/// The TimeRangeWidget will build a Text Widget that displays 5:01 PM - 8:20 PM
class TimeRangeWidget extends StatelessWidget {
  const TimeRangeWidget({
    Key? key,
    required this.time,
  }) : super(key: key);

  final String? time;
  @override
  Widget build(BuildContext context) {
    return Text(
      getStartTime(context) + ' - ' + getStopTime(context),
    );
  }

  String getStartTime(BuildContext context) {
    List<String> times = time!.split("-");
    return stringToTimeOfDay(times[0]).format(context);
  }

  String getStopTime(BuildContext context) {
    List<String> times = time!.split("- ");
    return stringToTimeOfDay(times[1]).format(context);
  }

  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.Hm();
    return TimeOfDay.fromDateTime(format.parse(tod));
  }
}
