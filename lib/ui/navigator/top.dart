import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';

class CMAppBar extends StatelessWidget {
  final String? title;
  final bool? doneButton;
  final bool? notificationsFilterButton;

  CMAppBar({this.title, this.doneButton, this.notificationsFilterButton});

  @override
  Widget build(BuildContext context) {
    if (doneButton == true) {
      return PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: lightTextColor),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
          backgroundColor: ColorPrimary,
          foregroundColor: lightTextColor,
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: title == null
                ? Image.asset(
              'assets/images/UCSanDiegoLogo-nav.png',
              fit: BoxFit.contain,
              height: 28,
            )
                : Text(title!, style: appBarTitleStyle),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 8, right: 20),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: darkButtonColor,
                ),
                child: Text('Done'),
                onPressed: () {
                  Provider.of<BottomNavigationBarProvider>(context, listen: false)
                      .currentIndex = NavigatorConstants.HomeTab;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      RoutePaths.BottomNavigationBar, (Route<dynamic> route) => false);
                  Provider.of<CustomAppBar>(context, listen: false)
                      .changeTitle(CustomAppBar().appBar.title);
                },
              ),
            )
          ],
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      );
    } else if (notificationsFilterButton == true) {
      return PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: lightTextColor),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
          backgroundColor: ColorPrimary,
          foregroundColor: lightTextColor,
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: title == null
                ? Image.asset(
              'assets/images/UCSanDiegoLogo-nav.png',
              fit: BoxFit.contain,
              height: 28,
            )
                : Text(title!, style: appBarTitleStyle),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: IconButton(
                icon: Icon(Icons.filter_list_outlined, color: lightTextColor),
                onPressed: () => Navigator.pushNamed(context, RoutePaths.NotificationsFilter),
              ),
            )
          ],
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      );
    } else {
      return PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: lightTextColor),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
          backgroundColor: ColorPrimary,
          foregroundColor: lightTextColor,
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: title == null
                ? Image.asset(
              'assets/images/UCSanDiegoLogo-nav.png',
              fit: BoxFit.contain,
              height: 28,
            )
                : Text(title!, style: appBarTitleStyle),
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      );
    }
  }
}

class CustomAppBar extends ChangeNotifier {
  CustomAppBar() {
    makeAppBar();
  }

  String? title;
  bool? doneButton;
  bool? notificationsFilterButton;
  late CMAppBar appBar;

  void makeAppBar() {
    appBar = CMAppBar(
      title: title,
      doneButton: doneButton,
      notificationsFilterButton: notificationsFilterButton,
    );
  }

  void changeTitle(String? newTitle, {bool done = false, bool notification = false}) {
    title = RouteTitles.titleMap[newTitle];
    doneButton = done;
    notificationsFilterButton = notification;
    makeAppBar();
  }
}