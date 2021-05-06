

import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/providers/classes.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/common/time_range_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';

class ClassList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child: buildSchedule(context),
    );
  }

  Widget buildSchedule(BuildContext context) {
    List<Widget> list = [];
    Provider.of<ClassScheduleDataProvider>(context)
        .enrolledClasses!
        .addAll(Provider.of<ClassScheduleDataProvider>(context).midterms!);
    Provider.of<ClassScheduleDataProvider>(context)
        .enrolledClasses!
        .keys
        .forEach(
      (key) {
        if (Provider.of<ClassScheduleDataProvider>(context)
            .enrolledClasses![key]!
            .isNotEmpty) {
          list.add(SliverStickyHeader(
            header: buildWeekDayHeader(context, key),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (key == 'MI') {
                  return buildMidterm(
                      Provider.of<ClassScheduleDataProvider>(context)
                          .enrolledClasses![key]!
                          .elementAt(index));
                }
                return buildClass(
                    Provider.of<ClassScheduleDataProvider>(context)
                        .enrolledClasses![key]!
                        .elementAt(index));
              },
                  childCount: Provider.of<ClassScheduleDataProvider>(context)
                      .enrolledClasses![key]!
                      .length),
            ),
          ));
        }
      },
    );
    return CustomScrollView(slivers: list);
  }

//  Widget buildHeader(
//      BuildContext context, String weekday, String specialMtgCode) {
//    if (specialMtgCode == null) {
//      buildWeekDayHeader(context, weekday);
//    } else {
//      return Container(
//        color: Theme.of(context).secondaryHeaderColor,
//        child: Padding(
//          padding: const EdgeInsets.all(12.0),
//          child: Text(
//            "Midterm",
//            style: TextStyle(
//              fontSize: 20.0,
//              color: Colors.white,
//            ),
//          ),
//        ),
//      );
//    }
//  }

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
                    sectionData.subjectCode! + ' ' + sectionData.courseCode!,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                  Text(
                    sectionData.courseTitle!,
                    style: TextStyle(fontSize: 17.0),
                  ),
                  Text(sectionData.instructorName!,
                      style: TextStyle(fontSize: 17.0)),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Row(children: [
                      Text(sectionData.meetingType! + ' '),
                      TimeRangeWidget(
                        time: sectionData.time,
                      )
                    ]),
                  ),
                  Text(sectionData.building! + ' ' + sectionData.room!),
                  Text(sectionData.gradeOption)
                ],
              ),
            ),
          )
        : null;
  }

  String abbrevToFullWeekday(String? abbreviation) {
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
      case 'MI':
        return 'Midterms';
      default:
        return 'Other';
    }
  }

  Widget buildMidterm(SectionData sectionData) {
    return sectionData != null
        ? Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    sectionData.subjectCode! + ' ' + sectionData.courseCode!,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                  Text(
                    sectionData.courseTitle!,
                    style: TextStyle(fontSize: 17.0),
                  ),
                  Text(sectionData.instructorName!),
                  Text(sectionData.building! + ' ' + sectionData.room!),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Row(children: [
                      Text(abbrevToFullWeekday(sectionData.days) +
                          ", " +
                          formatDate(sectionData.date)! +
                          ' from '),
                      TimeRangeWidget(
                        time: sectionData.time,
                      )
                    ]),
                  ),
                ],
              ),
            ),
          )
        : null;
  }

  String? formatDate(String? date) {
    if (date == null) {
      return null;
    }

    String month = date.substring(5, 7);
    String day = date.substring(8);
    if (day.startsWith("0")) {
      day = day.substring(1);
    }

    switch (month) {
      case "01":
        month = "January";
        break;
      case "02":
        month = "February";
        break;
      case "03":
        month = "March";
        break;
      case "04":
        month = "April";
        break;
      case "05":
        month = "May";
        break;
      case "06":
        month = "June";
        break;
      case "07":
        month = "July";
        break;
      case "08":
        month = "August";
        break;
      case "09":
        month = "September";
        break;
      case "10":
        month = "October";
        break;
      case "11":
        month = "November";
        break;
      case "12":
        month = "December";
        break;
    }

    return month + " " + day;
  }
}
