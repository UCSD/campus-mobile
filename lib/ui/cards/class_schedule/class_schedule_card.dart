import 'package:campus_mobile_experimental/core/data_providers/class_schedule_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/class_schedule_model.dart';

import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/last_updated_widget.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:provider/provider.dart';

class ClassScheduleCard extends StatelessWidget {
  List<Widget> buildActionButtons(BuildContext context) {
    List<Widget> actionButtons = List<Widget>();
    actionButtons.add(FlatButton(
      child: Text(
        'View All',
      ),
      onPressed: () {
        Navigator.pushNamed(context, RoutePaths.ClassScheduleViewAll);
      },
    ));
    return actionButtons;
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<UserDataProvider>(context).isLoggedIn &&
          Provider.of<UserDataProvider>(context).cardStates['schedule'],
      hide: () => Provider.of<UserDataProvider>(context).toggleCard('schedule'),
      reload: () =>
          Provider.of<ClassScheduleDataProvider>(context, listen: false)
              .fetchData(),
      isLoading: Provider.of<ClassScheduleDataProvider>(context).isLoading,
      title: Text("Schedule"),
      errorText: Provider.of<ClassScheduleDataProvider>(context).error,
      child: () => buildClassScheduleCard(
          Provider.of<ClassScheduleDataProvider>(context).classScheduleModel,
          Provider.of<ClassScheduleDataProvider>(context).lastUpdated),
      actionButtons: buildActionButtons(context),
    );
  }

  Widget buildClassScheduleCard(ClassScheduleModel data, DateTime lastUpdated) {
    return Column(
      children: [
        LastUpdatedWidget(time: lastUpdated),
      ],
    );
  }
}
