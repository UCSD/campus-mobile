import 'package:campus_mobile_experimental/core/data_providers/messages_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/ui/views/notifications/notifications_detail_view.dart';

class Notifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Expanded(
        flex: 1, 
        child: NotificationsDetailView()
        )
      ],
    );
  }
}
