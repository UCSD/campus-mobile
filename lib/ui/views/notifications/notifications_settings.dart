import 'package:campus_mobile_experimental/core/data_providers/push_notifications_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';

class NotificationsSettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: buildSettingsList(context, getTopics(context)),
    );
  }

  Widget buildSettingsList(BuildContext context, List<String> topicsData) {
    return (topicsData ?? []).isNotEmpty
        ? ListView(children: createList(context, topicsData))
        : Center(child: CircularProgressIndicator());
  }

  List<Widget> createList(BuildContext context, List<String> topicsAvailable) {
    List<Widget> list = List<Widget>();
    for (String topic in topicsAvailable) {
      list.add(ListTile(
        key: Key(topic),
        title: Text(getTopicName(context, topic)),
        trailing: Switch(
          value: Provider.of<PushNotificationDataProvider>(context)
              .topicSubscriptionState[topic],
          onChanged: (_) {
            Provider.of<UserDataProvider>(context, listen: false)
                .toggleNotifications(topic);
          },
          activeColor: ColorPrimary,
        ),
      ));
    }
    return list;
  }

  List<String> getTopics(BuildContext context) {
    UserDataProvider _userDataProvider = Provider.of<UserDataProvider>(context);
    PushNotificationDataProvider _pushNotificationDataProvider =
        Provider.of<PushNotificationDataProvider>(context);
    if (_userDataProvider.userProfileModel.classifications?.student ?? false) {
      return _pushNotificationDataProvider.publicTopics() +
          _pushNotificationDataProvider.studentTopics();
    } else {
      return _pushNotificationDataProvider.publicTopics();
    }
  }

  String getTopicName(BuildContext context, String topicId) {
    return Provider.of<PushNotificationDataProvider>(context)
        .getTopicName(topicId);
  }
}
