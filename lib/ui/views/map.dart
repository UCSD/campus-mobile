import 'package:flutter/material.dart';

class Map extends StatelessWidget {
  final Color color;

  Map(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
          'Map'
      ),
      color: color,
    );
  }
}
