import 'package:campus_mobile_experimental/core/data_providers/class_schedule_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/class_schedule_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpcomingCoursesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<SectionData> data =
        Provider.of<ClassScheduleDataProvider>(context).upcomingCourses;
    int selectedCourseIndex =
        Provider.of<ClassScheduleDataProvider>(context).selectedCourse;
    return buildListOfCourses(data, selectedCourseIndex, context);
  }

  Widget buildListOfCourses(
      List<SectionData> data, int selectedCourse, BuildContext context) {
    List<Widget> listOfCourses = List.generate(data.length, (int index) {
      return buildTile(index, selectedCourse, data[index], context);
    });
    return ListView(
      children: listOfCourses,
      shrinkWrap: true,
    );
  }

  Widget buildTile(
      int index, int selectedCourse, SectionData data, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Container(
        constraints: BoxConstraints.tightFor(height: 65),
        decoration: createBorder(),
        child: ListTile(
          dense: true,
          onTap: () =>
              Provider.of<ClassScheduleDataProvider>(context, listen: false)
                  .selectCourse(index),
          title: buildClassTitle(data),
          subtitle: buildClassTimeText(data, context),
          selected: index == selectedCourse,
          enabled: true,
        ),
      ),
    );
  }

  BoxDecoration createBorder() {
    return BoxDecoration(
      border: Border.all(width: 1),
    );
  }

  Widget buildClassTimeText(SectionData sectionData, BuildContext context) {
    return Text(
      sectionData.days + ' @ ' + getStartTime(sectionData.time, context),
    );
  }

  Widget buildClassTitle(SectionData sectionData) {
    return Text(
      sectionData.subjectCode + ' ' + sectionData.courseCode,
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  String getStartTime(String time, BuildContext context) {
    List<String> times = time.split("-");
    return stringToTimeOfDay(times[0]).format(context);
  }

  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.Hm();
    return TimeOfDay.fromDateTime(format.parse(tod));
  }
}
