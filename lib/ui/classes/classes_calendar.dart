import 'package:campus_mobile_experimental/core/services/classes_calendar.dart';
import 'package:campus_mobile_experimental/ui/classes/class_schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Month grid and selected-day agenda for the quarter loaded by Classes.
///
/// The widget never mutates the schedule. Date-only values use UTC midnight
/// components of the campus calendar day so day arithmetic cannot repeat a
/// day across DST. Neighboring-month and out-of-quarter dates are dimmed and
/// disabled.
class ClassesCalendar extends StatefulWidget {
  const ClassesCalendar({super.key, required this.calendar, required this.courseColors, this.now});

  final ClassCalendarData calendar;

  /// Course marker colors from the approved design palette. An empty palette
  /// renders a plain meeting count per day instead of colored dots.
  final List<Color> courseColors;

  /// Instant used to determine campus "today". Defaults to the current
  /// instant converted to America/Los_Angeles.
  final DateTime? now;

  @override
  State<ClassesCalendar> createState() => _ClassesCalendarState();
}

class _ClassesCalendarState extends State<ClassesCalendar> {
  static const List<String> _weekdayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const int _maxVisibleDots = 3;
  static const double _minGridWidth = 336;
  static final DateFormat _fullDateFormat = DateFormat('EEEE, MMMM d, y');

  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _resetSelection();
  }

  @override
  void didUpdateWidget(ClassesCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.calendar.quarter?.termCode != widget.calendar.quarter?.termCode) _resetSelection();
  }

  // The calendar helper initializes the timezone database for supported
  // quarters; when no quarter exists this widget renders its unavailable
  // message before any timezone work, so no device fallback is needed here.
  DateTime _campusToday() {
    final instant = widget.now ?? DateTime.now();
    final campus = tz.TZDateTime.from(instant, tz.getLocation('America/Los_Angeles'));
    return DateTime.utc(campus.year, campus.month, campus.day);
  }

  void _resetSelection() {
    final quarter = widget.calendar.quarter;
    if (quarter == null) {
      // No grid or agenda is rendered for a missing quarter.
      _selectedDate = _displayedMonth = DateTime.utc(1970, 1, 1);
      return;
    }
    final today = _campusToday();
    if (_onOrAfter(today, quarter.start) && _onOrBefore(today, quarter.end)) {
      _selectedDate = today;
    } else if (widget.calendar.occurrences.isNotEmpty) {
      final first = widget.calendar.occurrences.first.date;
      _selectedDate = DateTime.utc(first.year, first.month, first.day);
    } else {
      final fallback = quarter.instructionStart;
      _selectedDate = DateTime.utc(fallback.year, fallback.month, fallback.day);
    }
    _displayedMonth = DateTime.utc(_selectedDate.year, _selectedDate.month, 1);
  }

  void _select(DateTime date) {
    setState(() {
      _selectedDate = DateTime.utc(date.year, date.month, date.day);
      _displayedMonth = DateTime.utc(date.year, date.month, 1);
    });
  }

  /// Moves the displayed month and keeps the selected day in the destination
  /// month, clamped to the month length and the quarter boundaries so the
  /// agenda never lags in a different month.
  void _shiftMonth(int months) {
    final quarter = widget.calendar.quarter;
    if (quarter == null) return;
    final targetMonth = DateTime.utc(_displayedMonth.year, _displayedMonth.month + months, 1);
    var day = _selectedDate.day;
    final lastDay = _daysInMonth(targetMonth.year, targetMonth.month);
    if (day > lastDay) day = lastDay;
    var candidate = DateTime.utc(targetMonth.year, targetMonth.month, day);
    if (_isSameMonth(quarter.end, targetMonth) && _compareDate(candidate, quarter.end) > 0) {
      candidate = DateTime.utc(quarter.end.year, quarter.end.month, quarter.end.day);
    }
    if (_isSameMonth(quarter.start, targetMonth) && _compareDate(candidate, quarter.start) < 0) {
      candidate = DateTime.utc(quarter.start.year, quarter.start.month, quarter.start.day);
    }
    setState(() {
      _selectedDate = candidate;
      _displayedMonth = targetMonth;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quarter = widget.calendar.quarter;
    if (quarter == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Academic dates unavailable for this term.', style: Theme.of(context).textTheme.bodyMedium),
      );
    }
    // One global course order keeps each course's marker color stable no
    // matter which subset of courses meets on a given day.
    final courseKeys = widget.calendar.occurrences.map((occurrence) => occurrence.courseKey).toSet().toList()..sort();
    final courseKeyIndex = <String, int>{
      for (var index = 0; index < courseKeys.length; index++) courseKeys[index]: index,
    };
    final today = _campusToday();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(quarter.label, style: Theme.of(context).textTheme.titleSmall),
        ),
        _buildControls(context, quarter, today),
        _buildGrid(context, quarter, today, courseKeyIndex),
        _buildAgenda(context),
      ],
    );
  }

  Widget _buildControls(BuildContext context, ClassCalendarQuarter quarter, DateTime today) {
    final showToday = _onOrAfter(today, quarter.start) && _onOrBefore(today, quarter.end);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous month',
            icon: const Icon(Icons.chevron_left),
            onPressed: _monthOfIsBefore(quarter.start, _displayedMonth) ? () => _shiftMonth(-1) : null,
          ),
          Expanded(
            child: Text(
              DateFormat('MMMM y').format(_displayedMonth),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: 'Next month',
            icon: const Icon(Icons.chevron_right),
            onPressed: _monthOfIsBefore(_displayedMonth, quarter.end) ? () => _shiftMonth(1) : null,
          ),
          if (showToday) ...[
            const SizedBox(width: 4),
            TextButton(onPressed: () => _select(today), child: const Text('Today')),
          ],
        ],
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    ClassCalendarQuarter quarter,
    DateTime today,
    Map<String, int> courseKeyIndex,
  ) {
    final gridStart = _firstSunday(_displayedMonth);
    final grid = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (final label in _weekdayLabels)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                ),
              ),
          ],
        ),
        for (var row = 0; row < 6; row++)
          Row(
            children: [
              for (var column = 0; column < 7; column++)
                Expanded(
                  child: _buildDayCell(
                    context,
                    quarter,
                    today,
                    gridStart.add(Duration(days: row * 7 + column)),
                    courseKeyIndex,
                  ),
                ),
            ],
          ),
      ],
    );
    // Keep seven readable columns; scroll horizontally only when the screen
    // is narrower than the minimum grid width.
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? (constraints.maxWidth < _minGridWidth ? _minGridWidth : constraints.maxWidth)
            : _minGridWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: width, child: grid),
        );
      },
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    ClassCalendarQuarter quarter,
    DateTime today,
    DateTime date,
    Map<String, int> courseKeyIndex,
  ) {
    final inDisplayedMonth = date.year == _displayedMonth.year && date.month == _displayedMonth.month;
    final selectable = inDisplayedMonth && _onOrAfter(date, quarter.start) && _onOrBefore(date, quarter.end);
    final meetings = widget.calendar.meetingsOn(date);
    final isSelected = _isSameDay(date, _selectedDate);
    final isToday = _isSameDay(date, today);
    final marker = _buildMarker(meetings, courseKeyIndex);
    final countLabel = meetings.isEmpty
        ? 'no meetings'
        : '${meetings.length} meeting${meetings.length == 1 ? '' : 's'}';
    final labelParts = <String>[_fullDateFormat.format(date), if (isToday) 'Today', countLabel];
    final theme = Theme.of(context);

    return Semantics(
      label: labelParts.join(', '),
      selected: isSelected,
      button: selectable,
      enabled: selectable,
      child: Opacity(
        opacity: selectable ? 1.0 : 0.38,
        child: InkWell(
          onTap: selectable ? () => _select(date) : null,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? theme.colorScheme.primary : null,
                border: isToday
                    ? Border.all(color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary)
                    : null,
              ),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: ExcludeSemantics(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${date.day}', style: TextStyle(color: isSelected ? theme.colorScheme.onPrimary : null)),
                    if (marker != null) marker,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildMarker(List<ClassOccurrence> meetings, Map<String, int> courseKeyIndex) {
    if (meetings.isEmpty) return null;
    if (widget.courseColors.isEmpty) return Text('${meetings.length}', style: const TextStyle(fontSize: 10));

    final dayCourseKeys = meetings.map((meeting) => meeting.courseKey).toSet().toList()
      ..sort((a, b) => courseKeyIndex[a]!.compareTo(courseKeyIndex[b]!));
    final shownCount = dayCourseKeys.length < _maxVisibleDots ? dayCourseKeys.length : _maxVisibleDots;
    final overflowCount = dayCourseKeys.length - shownCount;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < shownCount; index++)
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: widget.courseColors[courseKeyIndex[dayCourseKeys[index]]! % widget.courseColors.length],
              shape: BoxShape.circle,
            ),
          ),
        if (overflowCount > 0) Text('+$overflowCount', style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildAgenda(BuildContext context) {
    final theme = Theme.of(context);
    final meetings = widget.calendar.meetingsOn(_selectedDate);
    final allDayMeetings = meetings.where((meeting) => meeting.isAllDay).toList();
    final timedMeetings = meetings.where((meeting) => !meeting.isAllDay).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(_fullDateFormat.format(_selectedDate), style: theme.textTheme.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
          child: Text('Pacific Time', style: theme.textTheme.bodySmall),
        ),
        if (meetings.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('No meetings on this day.', style: theme.textTheme.bodyMedium),
          )
        else ...[
          if (allDayMeetings.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text('All-day / TBA', style: theme.textTheme.titleSmall),
            ),
            for (final meeting in allDayMeetings) ClassSectionCard(scheduledClass: meeting.scheduledClass),
          ],
          for (final meeting in timedMeetings) ClassSectionCard(scheduledClass: meeting.scheduledClass),
        ],
        if (widget.calendar.undated.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text('Undated meetings', style: theme.textTheme.titleSmall),
          ),
          for (final undated in widget.calendar.undated) ClassSectionCard(scheduledClass: undated),
        ],
      ],
    );
  }

  DateTime _firstSunday(DateTime month) {
    final first = DateTime.utc(month.year, month.month, 1);
    return first.subtract(Duration(days: first.weekday % 7));
  }

  int _daysInMonth(int year, int month) {
    if (month == 2) return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 29 : 28;
    const monthLengths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return monthLengths[month - 1];
  }

  int _compareDate(DateTime a, DateTime b) {
    final aValue = a.year * 10000 + a.month * 100 + a.day;
    final bValue = b.year * 10000 + b.month * 100 + b.day;
    return aValue.compareTo(bValue);
  }

  bool _onOrAfter(DateTime date, DateTime bound) => _compareDate(date, bound) >= 0;

  bool _onOrBefore(DateTime date, DateTime bound) => _compareDate(date, bound) <= 0;

  bool _isSameDay(DateTime a, DateTime b) => _compareDate(a, b) == 0;

  bool _isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

  bool _monthOfIsBefore(DateTime boundDate, DateTime month) =>
      boundDate.year < month.year || (boundDate.year == month.year && boundDate.month < month.month);
}
