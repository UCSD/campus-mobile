import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/app_styles.dart';

class TritonCredits extends StatelessWidget {
  const TritonCredits({Key? key}) : super(key: key);

  static const List<String> _credits = [
    'This page was suggested by Kristhian Ortiz Alvarado and built by Prisha Jain.',
    'Test credit #2',
    'Test credit #3',
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ColorSecondary,
    appBar: AppBar(
      titleTextStyle: TextStyle(color: Colors.white),
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [Text('TRITON CREDITS')],
      ),
    ),
    body: ListView.separated(
      itemCount: _credits.length,
      itemBuilder: (context, index) =>
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Text(_credits[index])),
      separatorBuilder: (context, index) => const Divider(height: 1),
    ),
  );
}
