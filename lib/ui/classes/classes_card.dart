import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/classes.dart';
import 'package:campus_mobile_experimental/ui/classes/upcoming_classes.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/common/last_updated_widget.dart';
import 'package:campus_mobile_experimental/ui/common/time_range_widget.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const String cardId = 'schedule';

class ClassScheduleCard extends StatelessWidget {
  List<Widget> buildActionButtons(BuildContext context) {
    List<Widget> actionButtons = [];
    actionButtons.add(TextButton(
      style: TextButton.styleFrom(
        // primary: Theme.of(context).buttonColor,
        primary: Theme.of(context).backgroundColor,
      ),
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
      active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () {
        if (Provider.of<ClassScheduleDataProvider>(context, listen: false)
            .isLoading!) {
          return null;
        } else {
          Provider.of<ClassScheduleDataProvider>(context, listen: false)
              .fetchData();
        }
      },
      isLoading: Provider.of<ClassScheduleDataProvider>(context).isLoading,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: Provider.of<ClassScheduleDataProvider>(context).error,
      child: () => buildClassScheduleCard(
        Provider.of<ClassScheduleDataProvider>(context).upcomingCourses,
        Provider.of<ClassScheduleDataProvider>(context).selectedCourse!,
        Provider.of<ClassScheduleDataProvider>(context).lastUpdated,
        Provider.of<ClassScheduleDataProvider>(context).nextDayWithClass!,
      ),
      actionButtons: buildActionButtons(context),
    );
  }

  Widget buildClassScheduleCard(List<SectionData> courseData,
      int selectedCourse, DateTime? lastUpdated, String nextDayWithClasses) {
    try {
      return Padding(
        padding: const EdgeInsets.only(left: 4.0, top: 4.0),
        child: Row(
          children: <Widget>[
            Flexible(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      buildWeekdayText(nextDayWithClasses),
                      buildClassTitle(courseData[selectedCourse].subjectCode! +
                          ' ' +
                          courseData[selectedCourse].courseCode!),
                      buildClassType(courseData[selectedCourse].meetingType!),
                      buildTimeRow(courseData[selectedCourse].time),
                      buildLocationRow(courseData[selectedCourse].building! +
                          ' ' +
                          courseData[selectedCourse].room!),
                      buildGradeEvaluationRow(
                          courseData[selectedCourse].gradeOption),
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0, top: 24.0),
                          child: LastUpdatedWidget(time: lastUpdated),
                        ),
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: UpcomingCoursesList(),
            ),
          ],
        ),
      );
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
          e, StackTrace.fromString(e.toString()),
          reason: "Classes Card: Failed to build card content.", fatal: false);
      return Container(
        width: double.infinity,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 32, bottom: 48),
            child: Container(
              child: Text(
                  "Your classes could not be displayed.\n\nIf the problem persists contact mobilesupport@ucsd.edu"),
            ),
          ),
        ),
      );
    }
  }

  Widget buildWeekdayText(String nextDayWithClasses) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        nextDayWithClasses,
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  Widget buildClassTitle(String className) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        className,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget buildClassType(String classType) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
      child:
          Text(classType, style: TextStyle(color: Colors.grey, fontSize: 16)),
    );
  }

  Widget buildTimeRow(String? time) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Row(
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
      ),
    );
  }

  Widget buildGradeEvaluationRow(String gradeEvaluation) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Row(
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
              Text(gradeEvaluation),
            ],
          ),
        ],
      ),
    );
  }
}
