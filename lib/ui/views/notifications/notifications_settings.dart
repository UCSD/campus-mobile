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
      child: FutureBuilder(
        future: getTopics(context),
        builder: buildSettingsList,
      ),
    );
  }

  Widget buildSettingsList(BuildContext context, AsyncSnapshot topicsData) {
    return topicsData.hasData
        ? ListView(children: createList(context, topicsData.data))
        : CircularProgressIndicator();
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
            print(Provider.of<PushNotificationDataProvider>(context,
                    listen: false)
                .topicSubscriptionState);
          },
          activeColor: ColorPrimary,
        ),
      ));
    }
    return list;
  }

  Future<List<String>> getTopics(BuildContext context) async {
    UserDataProvider _userDataProvider = Provider.of<UserDataProvider>(context);
    PushNotificationDataProvider _pushNotificationDataProvider =
        Provider.of<PushNotificationDataProvider>(context);
    if (_userDataProvider.userProfileModel.classifications.student) {
      return await _pushNotificationDataProvider.publicTopics() +
          await _pushNotificationDataProvider.studentTopics();
    } else {
      return await _pushNotificationDataProvider.publicTopics();
    }
  }

  String getTopicName(BuildContext context, String topicId) {
    return Provider.of<PushNotificationDataProvider>(context)
        .getTopicName(topicId);
  }
}
