import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/app_styles.dart';

class _Credit {
  /* the person's name */
  final String name;

  /* what they contributed */
  final String contribution;

  const _Credit({required this.name, required this.contribution});
}

class TritonCredits extends StatelessWidget {
  const TritonCredits({Key? key}) : super(key: key);

  static List<_Credit> _credits = [
    _Credit(name: 'Kristhian Ortiz Alvarado', contribution: 'Suggested this page'),
    _Credit(name: 'Prisha Jain', contribution: 'Built this page'),
  ];

  @override
  Widget build(BuildContext context) =>
      Scaffold(
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
              Text('This page is dedicated to all the members of our Triton community who have helped to build and improve the mobile app.',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center),
              for (final credit in _credits)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        credit.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        credit.contribution,
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              Padding(padding: EdgeInsets.all(16),)
            ],
          ),
        ),
      );
}
