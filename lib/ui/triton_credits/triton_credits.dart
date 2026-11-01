import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/ui/triton_credits/credit.dart';

class TritonCredits extends StatelessWidget {
  const TritonCredits({Key? key}) : super(key: key);

  static final List<Credit> _credits = [
    credit(
      feature: 'Triton Credits',
      ideaOwner: 'Kristhian Ortiz Alvarado',
      devName: 'Prisha Jain',
      date: DateTime(2026, 10, 26), // First page implementation: commit 71ca34f4a.
    ),
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
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.all(20)),
          Image.asset('assets/images/UCSDMobile_sharp-removebg-preview.png', fit: BoxFit.cover, height: 80, width: 80),
          Padding(padding: EdgeInsets.all(20)),
          Image.asset('assets/images/UCSanDiego-Logo_White.png', fit: BoxFit.contain, height: 36),
          Padding(padding: EdgeInsets.all(12)),
          Text(
            'This page is dedicated to all the members of our Triton community who have helped to build and improve the mobile app.',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          for (final entry in _credits)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Text(
                entry.description,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          Padding(padding: EdgeInsets.all(16)),
        ],
      ),
    ),
  );
}
