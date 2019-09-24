import 'package:flutter/material.dart';

class Notifications extends StatelessWidget {
  final Color color;

  Notifications(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        'Notifications'
      ),
      color: color,
    );
  }
}
