import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/scheduled_class.dart';
import 'package:campus_mobile_experimental/core/providers/classes.dart';
import 'package:campus_mobile_experimental/core/services/classes_calendar.dart';
import 'package:campus_mobile_experimental/ui/classes/classes_calendar_export.dart';
import 'package:campus_mobile_experimental/ui/classes/class_schedule_card.dart';
import 'package:campus_mobile_experimental/ui/classes/classes_calendar.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';

class ClassList extends StatefulWidget {
  const ClassList({super.key});

  @override
  State<ClassList> createState() => _ClassListState();
}

class _ClassListState extends State<ClassList> {
  // TODO(MA-734): fill with the exact course colors from the approved Figma
  // frame (https://www.figma.com/design/GyPwWvEvtKG6pcCb1crFzH/UC-San-Diego-mobile-app?node-id=4188-13427)
  // once design Inspect access is available. Until then the empty palette
  // shows a plain meeting count per calendar day.
  static const List<Color> _approvedCourseColors = [];

  bool _showCalendar = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClassScheduleDataProvider>(context);
    final calendar = buildClassCalendar(provider.calendarSchedule);
    return ContainerView(
      child: Column(
        children: [
          // Export text grows with omissions and large text scale; cap its
          // share of the screen and scroll it internally so class content
          // below always stays reachable.
          Flexible(child: SingleChildScrollView(child: _buildViewToggle(context, calendar))),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Offstage(offstage: _showCalendar, child: _buildSchedule(context, provider)),
                ),
                Positioned.fill(
                  child: Offstage(
                    offstage: !_showCalendar,
                    child: SingleChildScrollView(
                      child: ClassesCalendar(calendar: calendar, courseColors: _approvedCourseColors),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context, ClassCalendarData calendar) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // At large text scale the segmented control can exceed the screen
        // width; scroll it horizontally instead of overflowing.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ToggleButtons(
            isSelected: [!_showCalendar, _showCalendar],
            onPressed: (index) => setState(() => _showCalendar = index == 1),
            children: const [
              Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('List')),
              Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Calendar')),
            ],
          ),
        ),
        ClassCalendarExportActions(calendar: calendar),
      ],
    ),
  );

  Widget _buildSchedule(BuildContext context, ClassScheduleDataProvider provider) {
    final mergedSections = _mergedSections(provider);
    final slivers = <Widget>[];
    mergedSections.forEach((key, classes) {
      if (classes.isEmpty) return;
      slivers.add(
        SliverStickyHeader(
          header: buildWeekDayHeader(context, key),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ClassSectionCard(scheduledClass: classes[index], isMidterm: key == 'MI'),
              childCount: classes.length,
            ),
          ),
        ),
      );
    });
    return CustomScrollView(slivers: slivers);
  }

  /// Local copy of the weekday buckets plus midterms. The provider's own maps
  /// must stay unmodified so repeated view changes cannot duplicate entries.
  Map<String, List<ScheduledClass>> _mergedSections(ClassScheduleDataProvider provider) {
    final merged = <String, List<ScheduledClass>>{
      for (final entry in provider.enrolledClasses.entries) entry.key: List<ScheduledClass>.of(entry.value),
    };
    for (final entry in provider.midterms.entries) {
      final existing = merged[entry.key];
      merged[entry.key] = existing == null ? List<ScheduledClass>.of(entry.value) : [...existing, ...entry.value];
    }
    return merged;
  }

  Widget buildWeekDayHeader(BuildContext context, String weekday) {
    final headerColor = Theme.of(context).brightness == Brightness.light
        ? lightPrimaryColor
        : descriptiveTextColorLight;
    return Container(
      color: headerColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          abbrevToFullWeekday(weekday),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
