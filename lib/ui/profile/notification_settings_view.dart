import 'package:campus_mobile_experimental/core/providers/notifications.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsSettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: buildSettingsList(context, getTopics(context)),
    );
  }

  Widget buildSettingsList(BuildContext context, List<String?>? topicsData) {
    return (topicsData ?? []).isNotEmpty
        ? ListView(children: createList(context, topicsData as List<String?>))
        : Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary));
  }

  List<Widget> createList(BuildContext context, List<String?> topicsAvailable) {
    List<Widget> list = [];
    for (String? topic in topicsAvailable) {
      list.add(ListTile(
        key: Key(topic!),
        leading: Icon(chooseIcon(topic),
            color: Theme.of(context).colorScheme.secondary, size: 30),
        title: Text(getTopicName(context, topic)!),
        trailing: Switch(
          value: Provider.of<PushNotificationDataProvider>(context)
              .topicSubscriptionState[topic]!,
          onChanged: (_) {
            Provider.of<UserDataProvider>(context, listen: false)
                .toggleNotifications(topic);
          },
          // activeColor: Theme.of(context).buttonColor,
          activeColor: Theme.of(context).colorScheme.background,
        ),
      ));
    }
    return list;
  }

  List<String?> getTopics(BuildContext context) {
    UserDataProvider _userDataProvider = Provider.of<UserDataProvider>(context);
    PushNotificationDataProvider _pushNotificationDataProvider =
        Provider.of<PushNotificationDataProvider>(context);
    if (_userDataProvider.userProfileModel!.classifications?.student ?? false) {
      return _pushNotificationDataProvider.publicTopics() +
          _pushNotificationDataProvider.studentTopics();
    } else if (_userDataProvider.userProfileModel!.classifications?.staff ??
        false) {
      return _pushNotificationDataProvider.publicTopics() +
          _pushNotificationDataProvider.staffTopics();
    } else {
      return _pushNotificationDataProvider.publicTopics();
    }
  }

  String? getTopicName(BuildContext context, String topicId) {
    return Provider.of<PushNotificationDataProvider>(context)
        .getTopicName(topicId);
  }
}

IconData chooseIcon(String messageType) {
  if (messageType == "studentAnnouncements" ||
      messageType == "testStudentAnnouncements") {
    return Icons.school_outlined;
  } else if (messageType == "freeFood" ||
      messageType == "testFreeFood") {
    return Icons.restaurant_outlined;
  } else if (messageType == "campusAnnouncements" ||
      messageType == "testCampusAnnouncements") {
    return Icons.campaign_outlined;
  } else if (messageType == "campusInnovationEvents" ||
      messageType == "testCampusInnovationEvents") {
    return Icons.event_outlined;
  } else { // if messageType == "DM" or anything else
    return Icons.info_outline;
  }
}