

import 'package:flutter/material.dart';

class LastUpdatedWidget extends StatelessWidget {
  const LastUpdatedWidget({
    Key? key,
    required this.time,
  }) : super(key: key);

  final DateTime? time;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        'Last updated: ' + determineText(time!),
        style: TextStyle(
            color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 16),
      ),
    );
  }

  String determineText(DateTime time) {
    Duration difference = DateTime.now().difference(time);
    if (difference.compareTo(Duration(seconds: 120)) <= 0) {
      return 'A few seconds ago';
    } else if (difference.compareTo(Duration(minutes: 60)) <= 0) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.compareTo(Duration(hours: 48)) <= 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
