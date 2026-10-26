import 'package:flutter/material.dart';

class TritonCredits extends StatelessWidget {
  const TritonCredits({Key? key}) : super(key: key);

  static const List<String> _credits = [
    'This page was suggested by Kristhian Ortiz Alvarado and built by Prisha Jain.',
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('UC San Diego'),
          Text('Triton Credits', style: Theme.of(context).textTheme.bodySmall),
        ],
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
