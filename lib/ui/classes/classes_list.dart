import 'package:campus_mobile_experimental/core/models/scheduled_class.dart';
import 'package:campus_mobile_experimental/core/providers/classes.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/common/time_range_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/app_styles.dart';

class ClassList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContainerView(child: buildSchedule(context));
  }

  Widget buildSchedule(BuildContext context) {
    List<Widget> list = [];
    Provider.of<ClassScheduleDataProvider>(
      context,
    ).enrolledClasses.addAll(Provider.of<ClassScheduleDataProvider>(context).midterms);
    Provider.of<ClassScheduleDataProvider>(context).enrolledClasses.keys.forEach((key) {
      final bool hasClasses = Provider.of<ClassScheduleDataProvider>(context).enrolledClasses[key]!.isNotEmpty;
      if (hasClasses) {
        list.add(
          SliverStickyHeader(
            header: buildWeekDayHeader(context, key),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (key == 'MI') {
                  return buildMidterm(
                    context,
                    Provider.of<ClassScheduleDataProvider>(context).enrolledClasses[key]!.elementAt(index),
                  );
                }
                return buildClass(
                  context,
                  Provider.of<ClassScheduleDataProvider>(context).enrolledClasses[key]!.elementAt(index),
                );
              }, childCount: Provider.of<ClassScheduleDataProvider>(context).enrolledClasses[key]!.length),
            ),
          ),
        );
      }
    });
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
      color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : descriptiveTextColorLight,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(weekday, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget buildClass(BuildContext context, ScheduledClass? scheduledClass) => _buildClassCard(context, scheduledClass);

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

  Widget buildMidterm(BuildContext context, ScheduledClass? scheduledClass) =>
      _buildClassCard(context, scheduledClass, isMidterm: true);

  Widget _buildClassCard(BuildContext context, ScheduledClass? scheduledClass, {bool isMidterm = false}) {
    final sectionData = scheduledClass?.section;
    if (scheduledClass == null || sectionData == null) return Card();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleStyle = isDark ? titleSmallDark : titleSmallLight;
    final detailStyle = (isDark ? descriptiveTextSmallDark : descriptiveTextSmallLight).copyWith(fontSize: 16);
    final meetingType = sectionData.meetingType?.trim();
    final meetingLabel = isMidterm
        ? '${abbrevToFullWeekday(sectionData.days)}, ${formatDate(sectionData.date) ?? 'TBD'}'
        : scheduledClass.displayDays;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Code and Meeting Type:
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${scheduledClass.subjectCode ?? ''} ${scheduledClass.courseCode ?? ''}'.trim(),
                    style: titleStyle,
                  ),
                ),
                if (meetingType != null && meetingType.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(meetingType, textAlign: TextAlign.end, style: detailStyle),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            // Course Title:
            Text(scheduledClass.courseTitle ?? 'Course title unavailable', style: detailStyle),
            const SizedBox(height: 8),
            // Instructor:
            _detailRow(Icons.person_outline, 'Instructor: ${sectionData.instructorName}', detailStyle),
            // Meeting Time, Days, and Date:
            _detailRow(
              Icons.schedule_outlined,
              null,
              detailStyle,
              trailing: Wrap(
                spacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  sectionData.time == null ? Text('TBD', style: detailStyle) : TimeRangeWidget(time: sectionData.time!),
                  Text('· $meetingLabel', style: detailStyle),
                ],
              ),
            ),
            // Classroom Location:
            _detailRow(Icons.location_on_outlined, 'Location: ${_formatLocation(scheduledClass)}', detailStyle),
            // Evaluation Option:
            if (!isMidterm)
              _detailRow(Icons.check_box_outlined, 'Evaluation: ${scheduledClass.gradeOption}', detailStyle),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String? text, TextStyle style, {Widget? trailing}) {
    final value = text?.trim();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 17, color: style.color),
          const SizedBox(width: 7),
          Expanded(
            child: Wrap(
              spacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (value != null && value.isNotEmpty)
                  Text(value, style: style)
                else if (trailing == null)
                  Text('TBD', style: style),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLocation(ScheduledClass scheduledClass) {
    final building = scheduledClass.section.building?.trim() ?? '';
    final room = scheduledClass.section.room?.trim() ?? '';
    if (room.isEmpty) return building.isEmpty ? 'TBD' : building;
    if (building.isEmpty || room.toUpperCase().startsWith(building.toUpperCase())) return room;
    return '$building $room';
  }

  String? formatDate(String? date) {
    if (date == null) return null;

    String month = date.substring(5, 7);
    String day = date.substring(8);
    if (day.startsWith("0")) day = day.substring(1);

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
