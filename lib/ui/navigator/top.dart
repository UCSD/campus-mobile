import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/ui/common/top_content.dart';

class CMAppBar extends StatelessWidget {
  CMAppBar({this.title, this.doneButton, this.notificationsFilterButton});

  final String? title;
  final bool? doneButton;
  final bool? notificationsFilterButton;

  @override
  Widget build(BuildContext context) {
    if (doneButton == true) {
      return TopContent(
        title: title,
        action: Padding(
          padding: EdgeInsets.only(bottom: 8, right: 20),
          child: TextButton(
            style: TextButton.styleFrom(foregroundColor: darkButtonColor),
            child: Text('Done'),
            onPressed: () {
              // Set tab bar index to the Home tab
              Provider.of<BottomNavigationBarProvider>(context, listen: false).currentIndex =
                  NavigatorConstants.HOME_TAB;
              // Navigate to Home tab
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(RoutePaths.BOTTOM_NAVIGATION_BAR, (Route<dynamic> route) => false);
              // change the appBar title to the ucsd logo
              Provider.of<CustomAppBar>(context, listen: false).changeTitle(CustomAppBar().appBar.title);
            },
          ),
        ),
        hasAction: true,
      );
    } else if (notificationsFilterButton == true) {
      return TopContent(
        title: title,
        action: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: IconButton(
            icon: Icon(Icons.filter_list_outlined),
            onPressed: () {
              Navigator.pushNamed(context, RoutePaths.NOTIFICATIONS_FILTER);
            },
          ),
        ),
        hasAction: true,
      );
    } else {
      return TopContent(title: title, action: null, hasAction: false);
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
    appBar = CMAppBar(title: title, doneButton: doneButton, notificationsFilterButton: notificationsFilterButton);
  }

  changeTitle(String? newTitle, {done = false, notification = false}) {
    // print("\x1B[34m[CustomAppBar] new route is " + (newTitle ?? 'null') + "\x1B[0m, done=$done, notification=$notification");
    title = RouteTitles.TITLE_MAP[newTitle];
    doneButton = done;
    notificationsFilterButton = notification;
    makeAppBar();
  }
}
