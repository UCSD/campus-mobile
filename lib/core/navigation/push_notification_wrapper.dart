import 'package:campus_mobile_experimental/core/data_providers/push_notifications_data_provider.dart';
import 'package:campus_mobile_experimental/core/navigation/bottom_tab_bar/bottom_navigation_bar_model.dart';
import 'package:campus_mobile_experimental/core/services/bottom_navigation_bar_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PushNotificationWrapper extends StatelessWidget {
  PushNotificationWrapper({Widget child});
  Widget child;
  @override
  Widget build(BuildContext context) {
    Provider.of<PushNotificationDataProvider>(context)
        .initPlatformState(context);
    return child;
  }
}
