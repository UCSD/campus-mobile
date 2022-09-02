import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/classes.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/common/last_updated_widget.dart';
import 'package:campus_mobile_experimental/ui/common/time_range_widget.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const String cardId = 'finals';

class FinalsCard extends StatelessWidget {
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
      child: () => buildFinalsCard(
          Provider.of<ClassScheduleDataProvider>(context).finals!,
          Provider.of<ClassScheduleDataProvider>(context).lastUpdated,
          Provider.of<ClassScheduleDataProvider>(context).nextDayWithClass,
          context),
    );
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
      case 'Other':
        return 'Other';
      default:
        return 'Other';
    }
  }

  Widget buildFinalsCard(Map<String, List<SectionData>> finalsData,
      DateTime? lastUpdated, String? nextDayWithClasses, BuildContext context) {
    try {
      List<Widget> listToReturn = [];
      finalsData.forEach((key, value) {
        for (SectionData data in value) {
          listToReturn.add(ListTile(
            title: buildWeekdayText(abbrevToFullWeekday(data.days)),
            subtitle: Column(
              children: [
                buildClassTitle(data.subjectCode! + ' ' + data.courseCode!),
                buildTimeRow(data.time),
                buildClassTitle(data.courseTitle!),
                buildLocationRow(data.building! + ' ' + data.room!),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ));
        }
      });
      listToReturn =
          ListTile.divideTiles(tiles: listToReturn, context: context).toList();
      listToReturn.add(
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: LastUpdatedWidget(time: lastUpdated),
        ),
      );
      return ListView(
        physics: NeverScrollableScrollPhysics(),
        children: listToReturn,
        shrinkWrap: true,
      );
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
          e, StackTrace.fromString(e.toString()),
          reason: "Finals Card: Failed to build card content.", fatal: false);
      return Container(
        width: double.infinity,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 32, bottom: 48),
            child: Container(
              child: Text(
                  "Your finals could not be displayed.\n\nIf the problem persists contact mobilesupport@ucsd.edu"),
            ),
          ),
        ),
      );
    }
  }

  Widget buildClassTitle(String title) {
    return Text(title);
  }

  Widget buildWeekdayText(String nextDayWithClasses) {
    return Text(
      nextDayWithClasses,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget buildClassCode(String className) {
    return Text(
      className,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  Widget buildTimeRow(String? time) {
    return Row(
      children: <Widget>[
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TimeRangeWidget(
                time: time,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildLocationRow(String location) {
    return Row(
      children: <Widget>[
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(location),
            ],
          ),
        ),
      ],
    );
  }
}
