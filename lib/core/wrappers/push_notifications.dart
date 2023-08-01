import 'package:campus_mobile_experimental/core/providers/notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PushNotificationWrapper extends StatefulWidget {
  PushNotificationWrapper({this.child});
  final Widget? child;

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
    return widget.child!;
  }
}
