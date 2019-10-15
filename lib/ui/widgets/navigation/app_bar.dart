import 'package:flutter/material.dart';

class CMAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      primary: true,
      centerTitle: true,
      title: Image.asset(
        'assets/images/UCSanDiegoLogo-nav.png',
        fit: BoxFit.contain,
        height: 28,
      ),
    );
  }
}
