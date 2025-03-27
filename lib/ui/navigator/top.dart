import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CMAppBar extends StatelessWidget {
  CMAppBar({
    this.title,
    this.doneButton,
    this.notificationsFilterButton,
  });

  final String? title;
  final bool? doneButton;
  final bool? notificationsFilterButton;

  @override
  Widget build(BuildContext context) {
    if (doneButton == true) {
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
                    ? Image.asset(
                  'assets/images/UCSanDiegoLogo-nav.png',
                  fit: BoxFit.contain,
                  height: 28,
                )
                    : Text(
                  title!,
                  style: appBarTitleStyle,
                ),
              ),
              actions: <Widget>[
                Padding(
                    padding: EdgeInsets.only(bottom: 8, right: 20),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: darkButtonColor,
                      ),
                      child: Text(
                        'Done',
                      ),
                      onPressed: () {
                        // Set tab bar index to the Home tab
                        Provider.of<BottomNavigationBarProvider>(context,
                            listen: false)
                            .currentIndex = NavigatorConstants.HomeTab;

                        // Navigate to Home tab
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            RoutePaths.BottomNavigationBar,
                                (Route<dynamic> route) => false);

                        // change the appBar title to the ucsd logo
                        Provider.of<CustomAppBar>(context, listen: false)
                            .changeTitle(CustomAppBar().appBar.title);
                      },
                    ))
              ],
              systemOverlayStyle: SystemUiOverlayStyle.light));
    } else if (notificationsFilterButton == true) {
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
                    ? Image.asset(
                  'assets/images/UCSanDiegoLogo-nav.png',
                  fit: BoxFit.contain,
                  height: 28,
                )
                    : Text(
                  title!,
                  style: appBarTitleStyle,
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: IconButton(
                    icon: Icon(Icons.filter_list_outlined),
                    onPressed: () {
                      Navigator.pushNamed(
                          context, RoutePaths.NotificationsFilter);
                    },
                  ),
                )
              ],
              systemOverlayStyle: SystemUiOverlayStyle.light));
    } else {
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
                ? Image.asset(
              'assets/images/UCSanDiegoLogo-nav.png',
              fit: BoxFit.contain,
              height: 28,
            )
                : Text(
              title!,
              style: appBarTitleStyle,
            ),
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

  /// STATES
  String? title;
  bool? doneButton;
  bool? notificationsFilterButton;
  late CMAppBar appBar;

  makeAppBar() {
    appBar = CMAppBar(
      title: title,
      doneButton: doneButton,
      notificationsFilterButton: notificationsFilterButton,
    );
  }

  changeTitle(String? newTitle, {done = false, notification = false}) {
    title = RouteTitles.titleMap[newTitle];
    doneButton = done;
    notificationsFilterButton = notification;

    // if (newTitle == "Notifications") {
    //   notificationsFilterButton = true;
    // } else {
    //   notificationsFilterButton = false;
    // }

    makeAppBar();
  }
}