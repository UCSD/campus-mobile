import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TopContent extends StatelessWidget {
  TopContent({this.title, this.action, required this.hasAction});

  final String? title;
  final Widget? action;
  final bool hasAction;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: AppBar(
        elevation: 0,
        backgroundColor: ColorPrimary,
        foregroundColor: lightTextColor,
        primary: true,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: title == null
              ? Image.asset('assets/images/UCSanDiegoLogo-nav.png', fit: BoxFit.contain, height: 28)
              : Text(title!, style: appBarTitleStyle),
        ),
        actions: hasAction ? <Widget>[action!] : <Widget>[],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}
