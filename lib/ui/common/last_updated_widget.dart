import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/app_styles.dart';

class LastUpdatedWidget extends StatelessWidget {
  const LastUpdatedWidget({Key? key, required this.time}) : super(key: key);

  /// STATES
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Text('Last updated: ' + determineText(time),
            style: TextStyle(
                fontSize: 16.0,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
                color: descriptiveTextColorLight)));
  }

  static String determineText(DateTime time) {
    Duration difference = DateTime.now().difference(time);
    final bool isWithinTwoMinutes = difference.compareTo(Duration(seconds: 120)) <= 0;
    final bool isWithinOneHour = difference.compareTo(Duration(minutes: 60)) <= 0;
    final bool isWithinTwoDays = difference.compareTo(Duration(hours: 48)) <= 0;
    if (isWithinTwoMinutes) return 'a few seconds ago';
    if (isWithinOneHour) return '${difference.inMinutes} minutes ago';
    if (isWithinTwoDays) return '${difference.inHours} hours ago';
    return '${difference.inDays} days ago';
  }
}
