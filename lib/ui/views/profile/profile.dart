import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/views/profile/login.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';

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
              onTap: () {},
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
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.lock),
              title: Text('Privacy Policy'),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
