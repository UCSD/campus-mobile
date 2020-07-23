import 'package:campus_mobile_experimental/core/data_providers/class_schedule_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/class_schedule_model.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/container_view.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/time_range_widget.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class ClassList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: buildSchedule(context),
    );
  }

  Widget buildSchedule(BuildContext context) {
    List<Widget> list = List<Widget>();
    Provider.of<ClassScheduleDataProvider>(context)
        .enrolledClasses
        .keys
        .forEach(
          (key) {
        if (Provider.of<ClassScheduleDataProvider>(context)
            .enrolledClasses[key]
            .isNotEmpty) {
          list.add(SliverStickyHeader(
            header: buildWeekDayHeader(context, key),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                      (context, index) => buildClass(
                      Provider.of<ClassScheduleDataProvider>(context)
                          .enrolledClasses[key]
                          .elementAt(index)),
                  childCount: Provider.of<ClassScheduleDataProvider>(context)
                      .enrolledClasses[key]
                      .length),
            ),
          ));
        }
      },
    );
    return CustomScrollView(slivers: list);
  }

  Widget buildWeekDayHeader(BuildContext context, String weekday) {
    weekday = abbrevToFullWeekday(weekday);
    return Container(
      color: Theme.of(context).secondaryHeaderColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          weekday,
          style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildClass(SectionData sectionData) {
    return sectionData != null
        ? Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    sectionData.subjectCode + ' ' + sectionData.courseCode,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                  Text(
                    sectionData.courseTitle,
                    style: TextStyle(fontSize: 17.0),
                  ),
                  Text(sectionData.instructorName,
                      style: TextStyle(fontSize: 17.0)),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Row(children: [
                      Text(sectionData.meetingType + ' '),
                      TimeRangeWidget(
                        time: sectionData.time,
                      )
                    ]),
                  ),
                  Text(sectionData.building + ' ' + sectionData.room),
                  Text(sectionData.gradeOption)
                ],
              ),
            ),
          )
        : null;
  }

  String abbrevToFullWeekday(String abbreviation) {
    switch (abbreviation) {
      case 'MO':
        return 'Monday';
      case 'TU':
        return 'Tuesday';
      case 'WE':
        return 'Wednesday';
      case 'TH':
        return 'Thursday';
      case 'FR':
        return 'Friday';
      case 'SA':
        return 'Saturday';
      case 'SU':
        return 'Sunday';
//      case 'Other':
//        return 'Other';
      default:
        return 'Other';
    }
  }
}
