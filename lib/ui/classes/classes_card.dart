import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/classes.dart';
import 'package:campus_mobile_experimental/ui/classes/upcoming_classes.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/common/last_updated_widget.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/action_button.dart';

const cardId = 'schedule';

class ClassScheduleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () {
        if (Provider.of<ClassScheduleDataProvider>(context, listen: false)
            .isLoading) return null;
        else
          Provider.of<ClassScheduleDataProvider>(context, listen: false)
              .fetchData();
      },
      isLoading: Provider.of<ClassScheduleDataProvider>(context).isLoading,
      titleText: CardTitleConstants.titleMap[cardId]!,
      errorText: Provider.of<ClassScheduleDataProvider>(context).error,
      child: () => buildClassScheduleCard(
        Provider.of<ClassScheduleDataProvider>(context).upcomingCourses,
        Provider.of<ClassScheduleDataProvider>(context).selectedCourse,
        Provider.of<ClassScheduleDataProvider>(context).lastUpdated,
        Provider.of<ClassScheduleDataProvider>(context).nextDayWithClass,
      ),
      actionButtons: [
        ActionButton(
          buttonText: 'VIEW ALL CLASSES',
          onPressed: () {
            Navigator.pushNamed(context, RoutePaths.ClassScheduleViewAll);
          },
        ),
      ],
    );
  }

  Widget buildClassScheduleCard(List<SectionData> courseData, int selectedCourse, DateTime lastUpdated, String nextDayWithClasses) {
    try {
      final section = courseData[selectedCourse];
      return Padding(
        padding: const EdgeInsets.only(left: 4.0, top: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Class',
                        style: TextStyle(
                          fontSize: 24.0,
                          color: lightPrimaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      // CSE 141L
                      buildClassCode('${section.subjectCode} ${section.courseCode}'),
                      SizedBox(height: 3),
                      // Laboratory
                      buildClassType(section.meetingType!),
                      SizedBox(height: 3),
                      // Start and Finish Time:
                      buildTimeRow(section.days!, section.time),
                      SizedBox(height: 3),
                      // Classroom Location:
                      buildLocationRow('${section.building} ${section.room}'),
                      SizedBox(height: 3),
                      // Evaluation Option:
                      buildGradeEvaluationRow(section.gradeOption),
                      // "Last updated: A few seconds ago
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, top: 24.0),
                        child: LastUpdatedWidget(time: lastUpdated),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Vertical Divider
            SizedBox(
              height: 260,
              child: VerticalDivider(
                color: Colors.grey,
                thickness: 0.7,
              ),
            ),
            // Right-hand side of the card //
            Flexible(
              flex: 4, // Adjusts width of Right Hand Side
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Aligns content to the top
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                children: [
                  UpcomingCoursesList(),
                ],
              ),
            ),

          ],
        ),
      );
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e, StackTrace.fromString(e.toString()),
        reason: "Classes Card: Failed to build card content.", fatal: false,
      );

      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 32, bottom: 48, left: 12),
          child: Text(
            "Your classes could not be displayed.\n\nIf the problem persists contact mobilesupport@ucsd.edu",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }


  // Heading 3 i.e. "CSE 141L"
  Widget buildClassCode(String className) {
    return Text(
        className,
        style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: lightPrimaryColor
        )
    );
  }

  // Small body text i.e. "Laboratory"
  Widget buildClassType(String classType) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
      child:
          Text(classType,
              style: TextStyle(
                fontSize: 16,
                color: descriptiveTextColorLight,
                fontWeight: FontWeight.w400,
              ),
          ),
    );
  }

  // Start and Finish Time:
  Widget buildTimeRow(String? day, String? time) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.access_time,
            color: lightPrimaryColor,
            size: 34,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Start and Finish Time:',
                style: TextStyle(
                  fontSize: 16,
                  color: descriptiveTextColorLight,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 3),
              Text(
                  (day ?? 'TBA') + ' @ ' + (time ?? 'TBA'),
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: lightPrimaryColor
                  )
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLocationRow(String location) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.location_city,
            size: 34,
            color: lightPrimaryColor,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Classroom Location:',
                style: TextStyle(
                  fontSize: 16,
                  color: descriptiveTextColorLight,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 3),
              Text(location,
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: lightPrimaryColor
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildGradeEvaluationRow(String gradeEvaluation) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.check_box_outlined,
            size: 34,
            color: lightPrimaryColor,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Evaluation Option:',
                style: TextStyle(
                  fontSize: 16,
                  color: descriptiveTextColorLight,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 3),
              Text(gradeEvaluation,
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: lightPrimaryColor
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
