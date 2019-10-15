import 'package:flutter/material.dart';

class HorizontalScrollView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 275,
        child: PageView(
          children: [Text('1'), Text('2'), Text('3')],
        ));
  }
}
