import 'package:campus_mobile_experimental/core/data_providers/class_schedule_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/class_schedule_model.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/time_range_widget.dart';

import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/last_updated_widget.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:intl/intl.dart';
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
          Provider.of<ClassScheduleDataProvider>(context)
              .classScheduleModel
              .data[0],
          Provider.of<ClassScheduleDataProvider>(context).lastUpdated),
      actionButtons: buildActionButtons(context),
    );
  }

  Widget buildClassScheduleCard(ClassData classData, DateTime lastUpdated) {
    return Column(
      children: [
        buildWeekdayText(),
        buildClassTitle(classData.subjectCode + classData.courseCode),
        buildClassType('Lecture'),
        buildTimeRow('17:00 - 20:00'),
        buildLocationRow('Solis 104'),
        buildGradeEvaluationRow('Letter Grade'),
        LastUpdatedWidget(time: lastUpdated),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget buildWeekdayText() {
    return Text(
      DateFormat('EEEE').format(DateTime.now()).toString(),
      style: TextStyle(color: Colors.grey, fontSize: 16),
    );
  }

  Widget buildClassTitle(String className) {
    return Text(
      className,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  Widget buildClassType(String classType) {
    return Text(classType, style: TextStyle(color: Colors.grey, fontSize: 16));
  }

  Widget buildTimeRow(String time) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.access_time,
          color: ColorPrimary,
          size: 40,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Start and Finish Time',
              style: TextStyle(color: Colors.grey),
            ),
            TimeRangeWidget(
              time: time,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildLocationRow(String location) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.location_city,
          size: 40,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Class Room Location',
              style: TextStyle(color: Colors.grey),
            ),
            Text(location),
          ],
        ),
      ],
    );
  }

  Widget buildGradeEvaluationRow(String gradEvaluation) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.check_box,
          size: 40,
          color: Colors.green,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Evaluation Option',
              style: TextStyle(color: Colors.grey),
            ),
            Text(gradEvaluation),
          ],
        ),
      ],
    );
  }
}
