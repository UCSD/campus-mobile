import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app_constants.dart';
import '../navigator/top.dart';

class TopContent extends StatelessWidget {

  TopContent({
    this.title,
    this.action,
    required this.has_action,
    required this.filter,
  });

  final String? title;
  final Widget? action;
  final bool has_action;
  final bool filter;

  @override
  Widget build(BuildContext context) {
    return PreferredSize
      (preferredSize: Size.fromHeight(50),
        child: AppBar(
          automaticallyImplyLeading: !filter,
          leading: filter ?
              IconButton(icon: Icon(Icons.arrow_back_ios),
                onPressed: (){
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      RoutePaths.DiningViewAll, (Route<dynamic> route) => false);
                }
              )
          :
              null,
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
