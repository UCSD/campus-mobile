import 'package:campus_mobile_experimental/core/data_providers/push_notifications_data_provider.dart';
import 'package:campus_mobile_experimental/core/navigation/bottom_tab_bar/bottom_navigation_bar_model.dart';
import 'package:campus_mobile_experimental/core/services/bottom_navigation_bar_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PushNotificationWrapper extends StatefulWidget {
  PushNotificationWrapper({Widget this.child});
  final Widget child;

  @override
  _PushNotificationWrapperState createState() =>
      _PushNotificationWrapperState();
}

class _PushNotificationWrapperState extends State<PushNotificationWrapper> {
  @override
  void didChangeDependencies() {
    Provider.of<PushNotificationDataProvider>(context)
        .initPlatformState(context);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
