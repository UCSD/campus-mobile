import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/classes.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:campus_mobile_experimental/ui/common/last_updated_widget.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/app_styles.dart';

const cardId = 'finals';

class FinalsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false).toggleCard(cardId),
      reload: () {
        final bool isLoading = Provider.of<ClassScheduleDataProvider>(context, listen: false).isLoading;
        if (isLoading) {
          return null;
        } else {
          Provider.of<ClassScheduleDataProvider>(context, listen: false).fetchData();
        }
      },
      isLoading: Provider.of<ClassScheduleDataProvider>(context).isLoading,
      titleText: CardTitleConstants.TITLE_MAP[cardId]!,
      errorText: Provider.of<ClassScheduleDataProvider>(context).error,
      child: () => buildFinalsCard(
          Provider.of<ClassScheduleDataProvider>(context).finals,
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

  Widget buildFinalsCard(Map<String, List<SectionData>> finalsData, DateTime lastUpdated, String? nextDayWithClasses,
      BuildContext context) {
    try {
      var finalsCount = 0, i = 1;
      // Iterate through the map and count the number Finals
      finalsData.forEach((key, value) {
        finalsCount += value.length;
      });

      List<Widget> listToReturn = [];
      finalsData.forEach((key, value) {
        for (SectionData data in value) {
          listToReturn.add(ListTile(
            // Friday
            title: buildWeekdayText(context, abbrevToFullWeekday(data.days)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 7),
                // CSE 127  19:00 - 21:59
                Row(
                  children: [
                    buildClassCode(context, data.subjectCode! + ' ' + data.courseCode!),
                    SizedBox(width: 10), // 10 logical pixels
                    buildTimeRow(context, data.time),
                  ],
                ),
                SizedBox(height: 2),
                // Intro to Computer Security
                buildClassTitle(context, data.courseTitle!),
                SizedBox(height: 2),
                // WLH 2005
                buildLocationRow(context, data.building! + ' ' + data.room!),
                ///////////////// Horizontal Division ///////////////////
                if (i < finalsCount) Divider(color: listTileDividerColorLight, thickness: 0.7),
              ],
            ),
          ));
          i++;
        }
      });
      listToReturn.add(
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 22.0),
          child: LastUpdatedWidget(time: lastUpdated),
        ),
      );
      return ListView(
        physics: NeverScrollableScrollPhysics(),
        children: listToReturn,
        shrinkWrap: true,
      );
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.fromString(e.toString()),
          reason: "Finals Card: Failed to build card content.", fatal: false);
      return Container(
        width: double.infinity,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 12, top: 32, bottom: 48),
            child: Container(
              child:
                  Text("Your finals could not be displayed.\n\nIf the problem persists contact mobilesupport@ucsd.edu"),
            ),
          ),
        ),
      );
    }
  }

  // Subheading i.e. "Monday"
  Widget buildWeekdayText(BuildContext context, String nextDayWithClasses) {
    return Text(
      nextDayWithClasses,
      style: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : darkPrimaryColor2,
      ),
    );
  }

  // Heading 3 i.e. "CSE 140"
  Widget buildClassCode(BuildContext context, String className) {
    return Text(className,
        style: TextStyle(
          fontSize: 18.0,
          fontFamily: 'Refrigerator Deluxe',
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
          color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : darkPrimaryColor2,
        ));
  }

  // Small body text i.e. 15:00 - 17:59 (24hr format)
  Widget buildTimeRow(BuildContext context, String? time) {
    return Text(
      time ?? 'TBA', // TBA if time is null or empty
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).brightness == Brightness.light ? descriptiveTextColorLight : descriptiveTextColorDark,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // Medium Body text i.e. "Intro to Computer Security"
  Widget buildClassTitle(BuildContext context, String title) {
    return Text(title,
        style: TextStyle(
            fontSize: 18.0,
            color:
                Theme.of(context).brightness == Brightness.light ? descriptiveTextColorLight : descriptiveTextColorDark,
            fontWeight: FontWeight.w400));
  }

  // Medium Body Text i.e. "WLH 2005"
  Widget buildLocationRow(BuildContext context, String location) {
    return Row(
      children: <Widget>[
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(location,
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Theme.of(context).brightness == Brightness.light
                          ? descriptiveTextColorLight
                          : descriptiveTextColorDark,
                      fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ],
    );
  }
}
