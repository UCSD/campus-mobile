import 'package:campus_mobile_experimental/core/data_providers/availability_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';

class NotificationsSettingsView extends StatelessWidget {
  UserDataProvider _userDataProvider;
  @override
  Widget build(BuildContext context) {
    _userDataProvider = Provider.of<UserDataProvider>(context);
    return ContainerView(
      child: buildSettingsList(context),
    );
  }

  Widget buildSettingsList(BuildContext context) {
    return ListView(
      children: createList(context),
    );
  }

  List<Widget> createList(BuildContext context) {
    List<Widget> list = List<Widget>();
    for (String topic in _userDataProvider.notificationsSettings) {
      list.add(ListTile(
        //leading: Icon(Icons.reorder),
        key: Key(topic),
        title: Text(getTopicName(topic)),
        trailing: Switch(
          value: _userDataProvider.notificationsSettingsStates[topic],
          onChanged: (_) {
            _userDataProvider.toggleNotifications(topic);
          },
          activeColor: ColorPrimary,
        ),
      ));
    }
    return list;
  }

  String getTopicName(String topic) {
    // todo: return something friendlier from metadata
    return topic;
  }
}
