import 'package:flutter/material.dart';

class CMAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(42),
      child: AppBar(
        primary: true,
        centerTitle: true,
        title: Image.asset(
          'assets/images/UCSanDiegoLogo-nav.png',
          fit: BoxFit.contain,
          height: 28,
        ),
      ),
    );
  }
}
