import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/notifications.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsFilterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContainerView(child: buildSettingsList(context, getTopics(context)));
  }

  Widget buildSettingsList(BuildContext context, List<String?>? topicsData) {
    return (topicsData ?? []).isNotEmpty
        ? Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: createList(context, topicsData as List<String?>),
                color: Theme.of(context).brightness == Brightness.dark
                    ? listTileDividerColorDark
                    : listTileDividerColorLight,
              ).toList(),
            ),
          )
        : Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary));
  }

  List<Widget> createList(BuildContext context, List<String?> topicsAvailable) {
    List<Widget> list = [];
    for (String? topic in topicsAvailable) {
      list.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            horizontalTitleGap: 0,
            contentPadding: EdgeInsets.all(0),
            visualDensity: VisualDensity.compact,
            key: Key(topic!),
            leading: Icon(
              chooseIcons(topic),
              color: Theme.of(context).iconTheme.color,
              size: 30,
            ),
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                getTopicName(context, topic)!,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            trailing: Transform.scale(
              scale: 0.9,
              child: Switch.adaptive(
                value: Provider.of<PushNotificationDataProvider>(context)
                    .topicSubscriptionState[topic]!,
                onChanged: (_) {
                  Provider.of<UserDataProvider>(context, listen: false).toggleNotifications(topic);
                },
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return Colors.white;
                  return null;
                }),
                activeColor: toggleActiveColor,
              ),
            ),
          ),
        ),
      );
    }
    return list;
  }

  static IconData chooseIcons(String messageType) {
    switch (messageType) {
      case "studentAnnouncements":
      case "testStudentAnnouncements":
        return Icons.school_outlined;
      case "freeFood":
      case "testFreeFood":
        return Icons.restaurant_outlined;
      case "campusAnnouncements":
      case "testCampusAnnouncements":
        return Icons.campaign_outlined;
      case "DM":
        return Icons.info_outline;
      default:
        return Icons.info_outline;
    }
  }

  List<String?> getTopics(BuildContext context) {
    UserDataProvider _userDataProvider = Provider.of<UserDataProvider>(context);
    PushNotificationDataProvider _pushNotificationDataProvider =
        Provider.of<PushNotificationDataProvider>(context);
    if (_userDataProvider.userProfileModel.classifications?.student ?? false) {
      return _pushNotificationDataProvider.publicTopics() +
          _pushNotificationDataProvider.studentTopics();
    } else if (_userDataProvider.userProfileModel.classifications?.staff ?? false) {
      return _pushNotificationDataProvider.publicTopics() +
          _pushNotificationDataProvider.staffTopics();
    } else {
      return _pushNotificationDataProvider.publicTopics();
    }
  }

  String? getTopicName(BuildContext context, String topicId) =>
      Provider.of<PushNotificationDataProvider>(context).getTopicName(topicId);
}
