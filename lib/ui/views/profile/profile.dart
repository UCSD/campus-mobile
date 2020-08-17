import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/views/profile/login.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
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
         /* Card(
            child: ListTile(
              leading: Icon(Icons.bluetooth_searching),
              title: Text('Bluetooth Automatic Logger'),
              onTap:() {handleAutomaticBluetoothTap(context);},
            ),
          ),*/
        /*  Card(
            child: ListTile(
              leading: Icon(Icons.bluetooth_audio),
              title: Text('Bluetooth Beacon Testing'),
              onTap:() {handleBeaconTap(context);},
            ),
          ),*/
        ],
      ),
    );
  }

  handleNotificationsTap(BuildContext context) {
    Navigator.pushNamed(context, RoutePaths.NotificationsSettingsView);
  }

 /* handleBeaconTap(BuildContext context) {
    Navigator.pushNamed(context, RoutePaths.BeaconView);
  }*/
  handleFeedbackTap() async {
    const feedbackUrl = "https://eforms.ucsd.edu/view.php?id=175631";
    openLink(feedbackUrl);
  }

  handlePrivacyTap() async {
    const privacyUrl = "https://mobile.ucsd.edu/privacy-policy.html";
    openLink(privacyUrl);
  }

  openLink(String url) async {
    if (await canLaunch(url)) {
      launch(url);
    } else {
      // can't launch url, there is some error
    }
  }

  /*void handleAutomaticBluetoothTap(BuildContext context) {
    Navigator.pushNamed(context, RoutePaths.AutomaticBluetoothLoggerView);

  }*/


}
