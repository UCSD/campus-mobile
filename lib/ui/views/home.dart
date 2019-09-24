import 'package:flutter/material.dart';

class Home extends StatelessWidget {
    final Color color;

    Home(this.color);

    @override
    Widget build(BuildContext context) {
        return Container(
            child: Text(
                'Home'
            ),
            color: color,
        );
    }
}
