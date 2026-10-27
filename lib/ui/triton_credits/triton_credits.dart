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
    backgroundColor: ColorPrimary,
    appBar: AppBar(
      titleTextStyle: appBarTitleStyle,
      centerTitle: true,
      elevation: 0,
      backgroundColor: ColorPrimary,
      foregroundColor: lightTextColor,
      title: Text('TRITON CREDITS'),
    ),
    body: ListView.separated(
      itemCount: _credits.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          color: triton_credits_color,
          elevation: 6,
          margin: EdgeInsets.zero,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: actionButtonBackgroundColor,
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  _credits[index]
                ),
              ),
            ],
          ),
        ),
      ),
      separatorBuilder: (context, index) => const Divider(height: 1),
    ),
  );
}
