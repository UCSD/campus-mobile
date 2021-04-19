import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:flutter/material.dart';

class CMAppBar extends StatelessWidget {
  CMAppBar({
    this.title,
  });
  final String title;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(42),
      child: AppBar(
        primary: true,
        centerTitle: true,
        title: title == null
            ? Image.asset(
                'assets/images/UCSanDiegoLogo-nav.png',
                fit: BoxFit.contain,
                height: 28,
              )
            : Text(title),
      ),
    );
  }
}

class CustomAppBar extends ChangeNotifier {
  CMAppBar appBar;
  String title;
  CustomAppBar() {
    makeAppBar();
  }
  makeAppBar() {
    appBar = CMAppBar(
      title: title,
    );
  }

  changeTitle(String newTitle) {
    title = RouteTitles.titleMap[newTitle];
    makeAppBar();
  }
}
