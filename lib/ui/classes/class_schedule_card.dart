import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/scheduled_class.dart';
import 'package:campus_mobile_experimental/core/services/classes_calendar.dart';
import 'package:campus_mobile_experimental/ui/common/time_range_widget.dart';
import 'package:flutter/material.dart';

/// Full informational card for one scheduled class section. It has no tap
/// action; the Classes list and the calendar agenda share this rendering.
class ClassSectionCard extends StatelessWidget {
  const ClassSectionCard({super.key, this.scheduledClass, this.isMidterm = false});

  final ScheduledClass? scheduledClass;
  final bool isMidterm;

  static final RegExp _timeDisplayPattern = RegExp(
    r'^\s*(\d{1,2}:\d{2})(?::\d{2})?\s*-\s*(\d{1,2}:\d{2})(?::\d{2})?\s*$',
  );

  @override
  Widget build(BuildContext context) {
    final classEntry = scheduledClass;
    final sectionData = classEntry?.section;
    if (classEntry == null || sectionData == null) return const Card();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleStyle = isDark ? titleSmallDark : titleSmallLight;
    final detailStyle = (isDark ? descriptiveTextSmallDark : descriptiveTextSmallLight).copyWith(fontSize: 16);
    final meetingType = sectionData.meetingType?.trim() ?? '';
    final meetingLabel = isMidterm
        ? '${abbrevToFullWeekday(sectionData.days)}, ${formatSectionDate(sectionData.date) ?? 'TBD'}'
        : classEntry.displayDays;
    final meetingTypeLabel = meetingType.toLowerCase() == 'unknown' ? '' : meetingType;

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
                    '${classEntry.subjectCode ?? ''} ${classEntry.courseCode ?? ''}'.trim(),
                    style: titleStyle,
                  ),
                ),
                if (meetingTypeLabel.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(meetingTypeLabel, textAlign: TextAlign.end, style: detailStyle),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            // Course Title:
            Text(classEntry.courseTitle ?? 'Course title unavailable', style: detailStyle),
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
                  _buildTime(context, sectionData.time, detailStyle),
                  Text('· $meetingLabel', style: detailStyle),
                ],
              ),
            ),
            // Classroom Location:
            _detailRow(Icons.location_on_outlined, 'Location: ${_formatLocation(classEntry)}', detailStyle),
            // Evaluation Option:
            if (!isMidterm) _detailRow(Icons.check_box_outlined, 'Evaluation: ${classEntry.gradeOption}', detailStyle),
          ],
        ),
      ),
    );
  }

  // Validity comes from the shared classMeetingTimeRange parser so malformed
  // or reversed ranges render as TBA instead of reaching TimeRangeWidget.
  Widget _buildTime(BuildContext context, String? time, TextStyle detailStyle) {
    if (time == null || classMeetingTimeRange(time) == null) return Text('TBA', style: detailStyle);
    final match = _timeDisplayPattern.firstMatch(time);
    if (match == null) return Text('TBA', style: detailStyle);
    return TimeRangeWidget(time: '${match.group(1)} - ${match.group(2)}');
  }

  Widget _detailRow(IconData icon, String? text, TextStyle style, {Widget? trailing}) {
    final value = text?.trim() ?? '';
    final hasValue = value.isNotEmpty;
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
                if (hasValue) Text(value, style: style) else if (trailing == null) Text('TBD', style: style),
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
    if (building.isEmpty) return room;

    final upperCaseRoom = room.toUpperCase();
    final upperCaseBuilding = building.toUpperCase();
    final roomIncludesBuilding = upperCaseRoom.startsWith(upperCaseBuilding);
    if (roomIncludesBuilding) return room;
    return '$building $room';
  }
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

String? formatSectionDate(String? date) {
  if (date == null) return null;

  String month = date.substring(5, 7);
  String day = date.substring(8);
  if (day.startsWith('0')) day = day.substring(1);

  switch (month) {
    case '01':
      month = 'January';
      break;
    case '02':
      month = 'February';
      break;
    case '03':
      month = 'March';
      break;
    case '04':
      month = 'April';
      break;
    case '05':
      month = 'May';
      break;
    case '06':
      month = 'June';
      break;
    case '07':
      month = 'July';
      break;
    case '08':
      month = 'August';
      break;
    case '09':
      month = 'September';
      break;
    case '10':
      month = 'October';
      break;
    case '11':
      month = 'November';
      break;
    case '12':
      month = 'December';
      break;
  }

  return month + ' ' + day;
}
