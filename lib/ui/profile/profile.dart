import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/ui/common/build_info.dart';
import 'package:campus_mobile_experimental/ui/profile/login.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
