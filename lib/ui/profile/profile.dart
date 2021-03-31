import 'dart:async';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/bottom_nav.dart';
import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/ui/common/build_info.dart';
import 'package:campus_mobile_experimental/ui/profile/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_links2/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatelessWidget {
  StreamSubscription _sub;

  Future<Null> initUniLinks(BuildContext context) async {
    // deep links are received by this method
    // the specific host needs to be added in AndroidManifest.xml and Info.plist
    // currently, this method handles executing custom map query
    _sub = linkStream.listen((String link) async {
      // handling for map query
      if (link.contains("deeplinking.searchmap")) {
        var uri = Uri.dataFromString(link);
        var query = uri.queryParameters['query'];
        // redirect query to maps tab and search with query
        Provider.of<MapsDataProvider>(context, listen: false)
            .searchBarController
            .text = query;
        Provider.of<MapsDataProvider>(context, listen: false).fetchLocations();
        Provider.of<BottomNavigationBarProvider>(context, listen: false)
            .currentIndex = NavigatorConstants.MapTab;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    initUniLinks(context);
    return Container(
      child: ListView(
        children: <Widget>[
          Login(),
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () {
                handleNotificationsTap(context);
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.menu),
              title: Text('Cards'),
              onTap: () {
                Navigator.pushNamed(context, RoutePaths.CardsView);
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Feedback'),
              onTap: handleFeedbackTap,
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.lock),
              title: Text('Privacy Policy'),
              onTap: handlePrivacyTap,
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.wifi_tethering),
              title: Text('Advanced Wayfinding'),
              onTap: () {
                Navigator.pushNamed(
                    context, RoutePaths.BluetoothPermissionsView);
              },
            ),
          ),
          BuildInfo(),
        ],
      ),
    );
  }

  handleNotificationsTap(BuildContext context) {
    Navigator.pushNamed(context, RoutePaths.NotificationsSettingsView);
  }

  handleFeedbackTap() async {
    const feedbackUrl = "https://eforms.ucsd.edu/view.php?id=175631";
    openLink(feedbackUrl);
  }

  handlePrivacyTap() async {
    const privacyUrl = "https://mobile.ucsd.edu/privacy-policy.html";
    openLink(privacyUrl);
  }

  openLink(String url) async {
    try {
      launch(url, forceSafariVC: true);
    } catch (e) {
      // an error occurred, do nothing
    }
  }
}
