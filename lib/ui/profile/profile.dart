import 'dart:async';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/ui/common/build_info.dart';
import 'package:campus_mobile_experimental/ui/profile/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_links2/uni_links.dart';
import '../../core/utils/webview.dart';

class Profile extends StatelessWidget {
  /// deep links are received by this method
  /// the specific host needs to be added in AndroidManifest.xml and Info.plist
  /// currently, this method handles executing custom map query
  Future<Null> initUniLinks(BuildContext context) async {
    late StreamSubscription _sub;
    _sub = linkStream.listen((String? link) async {
      // map query handler
      if (link!.contains("deeplinking.searchmap")) {
        var uri = Uri.dataFromString(link);
        var query = uri.queryParameters['query']!;
        // redirect query to maps tab and search with query
        Provider.of<MapsDataProvider>(context, listen: false)
            .searchBarController
            .text = query;
        Provider.of<MapsDataProvider>(context, listen: false).fetchLocations();
        Provider.of<BottomNavigationBarProvider>(context, listen: false)
            .currentIndex = NavigatorConstants.MapTab;
        // received deeplink, cancel stream to prevent memory leaks
        _sub.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    initUniLinks(context);
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                Login(),
                Divider(
                  color:
                      listTileDividerColorLight, // Set the color of the divider
                  thickness: 0.5, // Set the thickness of the divider
                ),
                ListTile(
                  title: Text(
                    'SETTINGS & SUPPORT',
                    style: titleMediumLight,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.drag_handle, color: lightPrimaryColor),
                  title: Text(
                    'Card Settings',
                    style: TextStyle(
                        fontFamily: 'BrixSans',
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                        color: linkColorLight),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, RoutePaths.CardsView);
                  },
                ),
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: lightPrimaryColor,
                        width: 2.0, // Set the border width
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                          4.0), // Adjust the padding as needed
                      child:
                          Icon(Icons.question_mark, color: lightPrimaryColor),
                    ),
                  ),
                  title: Text(
                    'Get Mobile App Support',
                    style: TextStyle(
                        fontFamily: 'BrixSans',
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                        color: linkColorLight),
                  ),
                  onTap: handleFeedbackTap,
                ),
                ListTile(
                  leading: Icon(Icons.lock, color: lightPrimaryColor),
                  title: Text(
                    'View Privacy Policy',
                    style: TextStyle(
                        fontFamily: 'BrixSans',
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                        color: linkColorLight),
                  ),
                  onTap: handlePrivacyTap,
                ),
              ],
            ),
          ),
          BuildInfo(), // This will be at the bottom
        ],
      ),
    );
  }

  // handleNotificationsTap(BuildContext context) {
  //   Navigator.pushNamed(context, RoutePaths.NotificationsFilter);
  // }

  Future<void> handleFeedbackTap() async {
    const feedbackUrl = "https://eforms.ucsd.edu/view.php?id=668781";
    openLink(feedbackUrl);
  }

  Future<void> handlePrivacyTap() async {
    const privacyUrl = "https://mobile.ucsd.edu/privacy-policy.html";
    openLink(privacyUrl);
  }
}
