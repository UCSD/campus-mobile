import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/providers/classes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_styles.dart';

class UpcomingCoursesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<SectionData> data = Provider.of<ClassScheduleDataProvider>(context).upcomingCourses;
    int? selectedCourseIndex = Provider.of<ClassScheduleDataProvider>(context).selectedCourse;
    return buildListOfCourses(data, selectedCourseIndex, context);
  }

  // Right Hand Side of Classes Card //
  Widget buildListOfCourses(List<SectionData> data, int? selectedCourse, BuildContext context) {
    // Builds Today's Schedule using buildTile
    List<Widget> listOfCourses = List.generate(
      data.length * 2 - 1, // Adjust length to account for dividers
          (int index) {
        if ((data.length * 2 - 1).isEven) {
          int itemIndex = index ~/ 2; // Convert index back to original data index
          return buildTile(itemIndex, selectedCourse, data[itemIndex], context);
        } else {
          ///////////////// Horizontal Division ///////////////////
          return Divider(color: listTileDividerColorDark, thickness: 0.6);
        }
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            'Today\'s Schedule',
            style: TextStyle(
              fontSize: 22.0,
              color: lightPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ListView(
          children: listOfCourses,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
        ),
      ],
    );

  }

  Widget buildTile(int index, int? selectedCourse, SectionData data, BuildContext context) {
    // Builds each class as a tile in today's schedule
    return ListTile(
          dense: true,
          onTap: () =>
              Provider.of<ClassScheduleDataProvider>(context, listen: false)
                  .selectCourse(index),
          // "CSE 141L"
          title: buildClassCode(data),
          // "WE @ 10:00"
          subtitle: buildClassTimeText(data),
          // Logic to change the color of the selected tile
          selected: index == selectedCourse,
          selectedColor: toggleActiveColor,
          enabled: true,
    );
  }

  // Heading 3 "CSE 141L"
  Widget buildClassCode(SectionData sectionData) {
    return Text(
        sectionData.subjectCode! + ' ' + sectionData.courseCode!,
      style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          color: lightPrimaryColor
      )
    );
  }

  // Small Body "WE @ 10:00"
  Widget buildClassTimeText(SectionData sectionData)
  => Text(
      sectionData.days! + ' @ ' + getStartTime(sectionData.time!),
    style: TextStyle(
      fontSize: 16,
      color: descriptiveTextColorLight,
      fontWeight: FontWeight.w400,
    )
  );

  String getStartTime(String time) {
    List<String> times = time.split("-");
    return times[0];
  }

  // TimeOfDay stringToTimeOfDay(String tod) {
  //   final format = DateFormat.Hm();
  //   return TimeOfDay.fromDateTime(format.parse(tod));
  // } Potentially needed for class schedule page?
}
