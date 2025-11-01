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
    return buildListOfCourses(context, data, selectedCourseIndex);
  }

  // Right Hand Side of Classes Card //
  Widget buildListOfCourses(BuildContext context, List<SectionData> data, int? selectedCourse) {
    // Builds Today's Schedule using buildTile
    List<Widget> listOfCourses = List.generate(
      data.length * 2 - 1, // Adjust length to account for dividers
      (int index) {
        if (index.isEven) {
          // Show a tile at even indexes
          int itemIndex = index ~/ 2; // Convert index back to original data index
          return buildTile(itemIndex, selectedCourse, data[itemIndex], context);
        } else {
          ///////////////// Horizontal Division ///////////////////
          return Divider(
            color: listTileDividerColorDark,
            thickness: 0.7,
            endIndent: 16, // right padding
          );
        }
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 4),
          child: Text(
            'Today\'s Schedule',
            style: TextStyle(
              fontSize: 22.0,
              color: Theme.of(context).brightness == Brightness.light
                  ? lightPrimaryColor
                  : darkPrimaryColor2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ListView(children: listOfCourses, shrinkWrap: true),
      ],
    );
  }

  Widget buildTile(int index, int? selectedCourse, SectionData data, BuildContext context) {
    bool isSelected = index == selectedCourse;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 0),
      onTap: () =>
          Provider.of<ClassScheduleDataProvider>(context, listen: false).selectCourse(index),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading 3 i.e. "CSE 141L"
          Text(
            '${data.subjectCode} ${data.courseCode}',
            style: TextStyle(
              fontSize: 17.0,
              fontFamily: 'Refrigerator Deluxe',
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: isSelected
                  ? toggleActiveColor
                  : Theme.of(context).brightness == Brightness.light
                  ? lightPrimaryColor
                  : darkPrimaryColor2,
            ),
          ),
          SizedBox(height: 5),
          // Small Body i.e. "WE @ 10:00"
          Text(
            '${data.days} @ ${getStartTime(data.time!)}',
            style: TextStyle(
              fontSize: 16,
              color: isSelected
                  ? toggleActiveColor
                  : Theme.of(context).brightness == Brightness.light
                  ? descriptiveTextColorLight
                  : descriptiveTextColorDark,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      selected: isSelected,
      selectedColor: toggleActiveColor,
      enabled: true,
    );
  }

  String getStartTime(String time) {
    List<String> times = time.split("-");
    return times[0];
  }

  // TimeOfDay stringToTimeOfDay(String tod) {
  //   final format = DateFormat.Hm();
  //   return TimeOfDay.fromDateTime(format.parse(tod));
  // } Potentially needed for class schedule page?
}
