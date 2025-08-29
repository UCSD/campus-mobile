import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TopContent extends StatelessWidget {

  TopContent({
    this.title,
    this.action,
    required this.has_action,
  });

  final String? title;
  final Widget? action;
  final bool has_action;

  @override
  Widget build(BuildContext context) {
    return PreferredSize
      (preferredSize: Size.fromHeight(50),
        child: AppBar(
          elevation: 0,
          backgroundColor: ColorPrimary,
          foregroundColor: lightTextColor,
          primary: true,
          centerTitle: true,
          title: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
            child: title == null
              ? Image.asset(
              'assets/images/UCSanDiegoLogo-nav.png',
                fit: BoxFit.contain,
                height: 28,
            )
                : Text(
                  title!,
              style: appBarTitleStyle,
            )
          ),

          actions: has_action ?
            <Widget>[action!]
          : <Widget>[],

          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
    );
  }
}
