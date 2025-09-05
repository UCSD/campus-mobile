import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app_constants.dart';
import 'package:campus_mobile_experimental/core/navigator_keys.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';

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
    return PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: AppBar(
        elevation: 0,
        backgroundColor: ColorPrimary,
        foregroundColor: lightTextColor,
        primary: true,
        centerTitle: true,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back_sharp),
                onPressed: () {
                  final provider = Provider.of<BottomNavigationBarProvider>(
                      context,
                      listen: false);
                  final tabKeys = [
                    TabNavigatorKeys.homeTabKey,
                    TabNavigatorKeys.mapTabKey,
                    TabNavigatorKeys.notificationsTabKey,
                    TabNavigatorKeys.profileTabKey,
                  ];
                  final currentTabKey = tabKeys[provider.currentIndex];
                  final currentRoute = ModalRoute.of(context)?.settings.name;
                  print("\x1B[32mCurrent route name: " + (currentRoute ?? "null") + "\x1B[0m");
                  if (currentTabKey.currentState?.canPop() ?? false) {
                    currentTabKey.currentState?.pop();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              )
            : null,
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
                  )),
        actions: has_action ? <Widget>[action!] : <Widget>[],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}
