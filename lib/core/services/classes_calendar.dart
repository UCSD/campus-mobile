import 'dart:convert';

import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/scheduled_class.dart';
import 'package:crypto/crypto.dart';
import 'package:timezone/data/latest_all.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

/// Frozen academic dates for the supported 2026-27 quarters, all inclusive.
///
/// Dates verified against https://blink.ucsd.edu/instructors/resources/academic/calendars/2026.html
/// on 2026-11-13. The FA26 and WI27 term codes were also verified directly at
/// https://classplanner.apps.ucsd.edu/search. SP27 follows the official
/// season-plus-two-digit-year scheme documented at
/// https://act.ucsd.edu/scheduleOfClasses/scheduleOfClassesStudent.htm and was
/// not yet directly published at verification time.
final Map<String, ClassCalendarQuarter> _verifiedQuarters = {
  'FA26': ClassCalendarQuarter(
    termCode: 'FA26',
    label: 'Fall 2026',
    start: DateTime.utc(2026, 9, 21),
    end: DateTime.utc(2026, 12, 12),
    instructionStart: DateTime.utc(2026, 9, 24),
    instructionEnd: DateTime.utc(2026, 12, 4),
  ),
  'WI27': ClassCalendarQuarter(
    termCode: 'WI27',
    label: 'Winter 2027',
    start: DateTime.utc(2027, 1, 4),
    end: DateTime.utc(2027, 3, 20),
    instructionStart: DateTime.utc(2027, 1, 4),
    instructionEnd: DateTime.utc(2027, 3, 12),
  ),
  'SP27': ClassCalendarQuarter(
    termCode: 'SP27',
    label: 'Spring 2027',
    start: DateTime.utc(2027, 3, 24),
    end: DateTime.utc(2027, 6, 11),
    instructionStart: DateTime.utc(2027, 3, 29),
    instructionEnd: DateTime.utc(2027, 6, 4),
  ),
};

final Map<String, Set<DateTime>> _quarterHolidays = {
  'FA26': {DateTime.utc(2026, 11, 11), DateTime.utc(2026, 11, 26), DateTime.utc(2026, 11, 27)},
  'WI27': {DateTime.utc(2027, 1, 18), DateTime.utc(2027, 2, 15)},
  'SP27': {DateTime.utc(2027, 3, 26), DateTime.utc(2027, 5, 31)},
};

const Map<String, int> _weekdayCodes = {
  'MO': DateTime.monday,
  'TU': DateTime.tuesday,
  'WE': DateTime.wednesday,
  'TH': DateTime.thursday,
  'FR': DateTime.friday,
  'SA': DateTime.saturday,
  'SU': DateTime.sunday,
};

class ClassCalendarQuarter {
  const ClassCalendarQuarter({
    required this.termCode,
    required this.label,
    required this.start,
    required this.end,
    required this.instructionStart,
    required this.instructionEnd,
  });

  final String termCode;
  final String label;

  /// Campus calendar day bounds at UTC midnight.
  final DateTime start;
  final DateTime end;
  final DateTime instructionStart;
  final DateTime instructionEnd;
}

class ClassOccurrence {
  const ClassOccurrence({
    required this.scheduledClass,
    required this.date,
    required this.start,
    required this.end,
    required this.courseKey,
    required this.uid,
    required this.isAllDay,
  });

  final ScheduledClass scheduledClass;

  /// Campus calendar day at UTC midnight.
  final DateTime date;

  /// Actual UTC instants; null for all-day/TBA meetings.
  final DateTime? start;
  final DateTime? end;
  final String courseKey;
  final String uid;
  final bool isAllDay;
}

class ClassCalendarData {
  const ClassCalendarData({
    required this.quarter,
    this.occurrences = const [],
    this.undated = const [],
    this.omissions = const [],
  });

  final ClassCalendarQuarter? quarter;
  final List<ClassOccurrence> occurrences;
  final List<ScheduledClass> undated;
  final List<String> omissions;

  /// Dated meetings whose campus date components match [campusCalendarDay],
  /// all-day meetings first, then timed meetings in chronological order.
  List<ClassOccurrence> meetingsOn(DateTime campusCalendarDay) => occurrences
      .where(
        (occurrence) =>
            occurrence.date.year == campusCalendarDay.year &&
            occurrence.date.month == campusCalendarDay.month &&
            occurrence.date.day == campusCalendarDay.day,
      )
      .toList();
}

/// Builds calendar occurrences from canonical course/section records.
///
/// Returns an unavailable calendar when the schedule is missing or its
/// enrolled records do not agree on one supported term code; no guess is made.
ClassCalendarData buildClassCalendar(ClassScheduleModel? schedule) {
  final courses = schedule?.data ?? const <ClassData>[];
  final enrolled = courses.where((course) => course.enrollmentStatus == 'Booked').toList();
  final termCode = enrolled.isEmpty ? null : enrolled.first.termCode;
  final termCodesAgree = enrolled.every((course) => course.termCode == termCode);
  final quarter = termCode == null || !termCodesAgree ? null : _verifiedQuarters[termCode];
  if (quarter == null) {
    return const ClassCalendarData(quarter: null);
  }
  _ensureTimezoneDatabase();

  final holidays = _quarterHolidays[termCode!] ?? const <DateTime>{};
  final seen = <String>{};
  final occurrences = <ClassOccurrence>[];
  final undated = <ScheduledClass>[];
  final omissions = <String>[];

  for (final course in enrolled) {
    final courseKey = _courseKeyOf(course);
    for (final section in course.sectionData ?? const <SectionData>[]) {
      if (!seen.add(_canonicalSignature(course, section))) continue;
      if (_isExam(section)) continue;
      final scheduledClass = ScheduledClass(course: course, section: section);

      final date = _parseCampusDate(section.date);
      if (section.date != null && date == null) {
        omissions.add('${_meetingLabel(courseKey, section)}: unusable meeting date ${section.date}');
        continue;
      }
      if (date != null) {
        if (date.isBefore(quarter.start) || date.isAfter(quarter.end)) {
          omissions.add('${_meetingLabel(courseKey, section)}: dated ${section.date} outside ${quarter.label}');
          continue;
        }
        // Published holidays are expected exclusions like exams, not
        // invalid-data omissions.
        if (holidays.contains(date)) continue;
        occurrences.add(_buildOccurrence(scheduledClass, date, termCode, courseKey));
        continue;
      }

      final weekdays = _parseWeekdays(section.days);
      if (weekdays == null || weekdays.isEmpty) {
        undated.add(scheduledClass);
        continue;
      }
      var day = quarter.instructionStart;
      while (!day.isAfter(quarter.instructionEnd)) {
        if (weekdays.contains(day.weekday) && !holidays.contains(day)) {
          occurrences.add(_buildOccurrence(scheduledClass, day, termCode, courseKey));
        }
        day = day.add(const Duration(days: 1));
      }
    }
  }

  occurrences.sort(_compareOccurrences);
  undated.sort(_compareUndated);
  return ClassCalendarData(quarter: quarter, occurrences: occurrences, undated: undated, omissions: omissions);
}

/// Parses a `h:mm[:ss] - h:mm[:ss]` meeting time into same-day endpoints in
/// seconds since midnight. Returns null for missing, malformed, out-of-bounds,
/// or non-increasing endpoints so callers can treat the meeting as all-day.
({int startSeconds, int endSeconds})? classMeetingTimeRange(String? value) {
  final parts = value?.split('-') ?? const [];
  if (parts.length != 2) return null;
  final start = _parseTimeOfDay(parts[0]);
  final end = _parseTimeOfDay(parts[1]);
  if (start == null || end == null || end <= start) return null;
  return (startSeconds: start, endSeconds: end);
}

/// Serializes the full loaded quarter as one RFC 5545 snapshot with explicit
/// events. Returns null when the quarter is unavailable or nothing is dated.
String? createClassesCalendarIcs(ClassCalendarData calendar, {DateTime? generatedAt}) {
  final quarter = calendar.quarter;
  if (quarter == null || calendar.occurrences.isEmpty) return null;
  _ensureTimezoneDatabase();

  final stamp = (generatedAt ?? DateTime.now()).toUtc();
  final lines = <String>['BEGIN:VCALENDAR', 'VERSION:2.0', 'PRODID:-//UC San Diego//Campus Mobile//EN'];
  for (final occurrence in calendar.occurrences) {
    final course = occurrence.scheduledClass.course;
    final section = occurrence.scheduledClass.section;
    final courseTitle = _nonEmpty(course.courseTitle);
    final summary = [
      occurrence.courseKey,
      if (courseTitle != null && courseTitle != occurrence.courseKey) courseTitle,
      _nonEmpty(section.meetingType) ?? 'Class meeting',
    ].join(' - ');
    final location = [_nonEmpty(section.building), _nonEmpty(section.room)].whereType<String>().join(' ');
    final description = [
      courseTitle ?? occurrence.courseKey,
      _nonEmpty(location),
      _nonEmpty(section.instructorName),
    ].whereType<String>().join(' - ');

    lines.addAll([
      'BEGIN:VEVENT',
      'UID:${occurrence.uid}',
      'DTSTAMP:${_formatUtcInstant(stamp)}',
      if (occurrence.isAllDay) ...[
        'DTSTART;VALUE=DATE:${_formatCampusDate(occurrence.date)}',
        'DTEND;VALUE=DATE:${_formatCampusDate(occurrence.date.add(const Duration(days: 1)))}',
      ] else ...[
        'DTSTART:${_formatUtcInstant(occurrence.start!)}',
        'DTEND:${_formatUtcInstant(occurrence.end!)}',
      ],
      'SUMMARY:${_escapeIcsText(summary)}',
      if (description.isNotEmpty) 'DESCRIPTION:${_escapeIcsText(description)}',
      if (location.isNotEmpty) 'LOCATION:${_escapeIcsText(location)}',
      'END:VEVENT',
    ]);
  }
  lines.add('END:VCALENDAR');
  return lines.map(_foldIcsLine).join('\r\n') + '\r\n';
}

bool _isExam(SectionData section) {
  final meetingType = (section.meetingType ?? '').toLowerCase();
  final specialCode = (section.specialMtgCode ?? '').trim().toUpperCase();
  return specialCode == 'MI' ||
      specialCode == 'FI' ||
      meetingType.contains('midterm') ||
      meetingType.contains('final') ||
      meetingType.contains('exam');
}

/// Strictly accepts `yyyy-M-dd` and rejects impossible calendar dates
/// such as 2026-2-30 that Dart would silently roll over.
DateTime? _parseCampusDate(String? value) {
  final match = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(value?.trim() ?? '');
  if (match == null) return null;
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  if (month < 1 || month > 12 || day < 1) return null;
  final parsed = DateTime.utc(year, month, day);
  return parsed.year == year && parsed.month == month && parsed.day == day ? parsed : null;
}

/// Recognizes exact MO/TU/WE/TH/FR/SA/SU tokens, space separated or
/// concatenated. Any unrecognized letter fragment makes the whole value
/// unusable so malformed schedules never invent weekday occurrences.
Set<int>? _parseWeekdays(String? days) {
  final text = days?.trim();
  if (text == null || text.isEmpty) return null;
  final weekdays = <int>{};
  var index = 0;
  while (index < text.length) {
    if (_isDaySeparator(text.codeUnitAt(index))) {
      index++;
      continue;
    }
    if (index + 2 > text.length) return null;
    final weekday = _weekdayCodes[text.substring(index, index + 2)];
    if (weekday == null) return null;
    weekdays.add(weekday);
    index += 2;
  }
  return weekdays.isEmpty ? null : weekdays;
}

bool _isDaySeparator(int unit) {
  const separators = {0x09, 0x0a, 0x0d, 0x20, 0x2c, 0x2d, 0x2f, 0x3b};
  return separators.contains(unit);
}

int? _parseTimeOfDay(String value) {
  final match = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?$').firstMatch(value.trim());
  if (match == null) return null;
  final hours = int.parse(match.group(1)!);
  final minutes = int.parse(match.group(2)!);
  final seconds = int.parse(match.group(3) ?? '0');
  if (hours > 23 || minutes > 59 || seconds > 59) return null;
  return hours * 3600 + minutes * 60 + seconds;
}

ClassOccurrence _buildOccurrence(ScheduledClass scheduledClass, DateTime date, String termCode, String courseKey) {
  final section = scheduledClass.section;
  final timeRange = classMeetingTimeRange(section.time);
  final discriminator = timeRange == null ? 'allday' : 't${timeRange.startSeconds}-${timeRange.endSeconds}';
  final uidSeed =
      'campus-mobile-classes|$termCode|$courseKey|${section.sectionCode}|${section.section}'
      '|${section.meetingType}'
      '|${section.specialMtgCode}|${_formatCampusDate(date)}|$discriminator';
  return ClassOccurrence(
    scheduledClass: scheduledClass,
    date: date,
    start: timeRange == null ? null : _campusTimeToUtc(date, timeRange.startSeconds),
    end: timeRange == null ? null : _campusTimeToUtc(date, timeRange.endSeconds),
    courseKey: courseKey,
    uid: sha256.convert(utf8.encode(uidSeed)).toString(),
    isAllDay: timeRange == null,
  );
}

bool _timezoneInitialized = false;

void _ensureTimezoneDatabase() {
  if (_timezoneInitialized) return;
  timezone_data.initializeTimeZones();
  _timezoneInitialized = true;
}

timezone.Location get _campusLocation {
  _ensureTimezoneDatabase();
  return timezone.getLocation('America/Los_Angeles');
}

DateTime _campusTimeToUtc(DateTime date, int secondsOfDay) {
  final campus = timezone.TZDateTime(
    _campusLocation,
    date.year,
    date.month,
    date.day,
    secondsOfDay ~/ 3600,
    secondsOfDay % 3600 ~/ 60,
    secondsOfDay % 60,
  );
  return campus.toUtc();
}

String _courseKeyOf(ClassData course) {
  final subject = _nonEmpty(course.subjectCode);
  final code = _nonEmpty(course.courseCode);
  if (subject != null && code != null) return '$subject $code';
  return subject ?? code ?? _nonEmpty(course.courseTitle) ?? 'Unknown course';
}

String _meetingLabel(String courseKey, SectionData section) {
  final identifier = _nonEmpty(section.sectionCode) ?? _nonEmpty(section.section);
  return identifier == null ? courseKey : '$courseKey $identifier';
}

String _canonicalSignature(ClassData course, SectionData section) {
  String field(String? value) => value ?? '';
  // Scheduling identity only: records differing solely in display metadata
  // (title, building, room, instructor) are the same meeting.
  return [
    field(course.termCode),
    field(course.subjectCode),
    field(course.courseCode),
    field(section.section),
    field(section.sectionCode),
    field(section.meetingType),
    field(section.date),
    field(section.time),
    field(section.days),
    field(section.specialMtgCode),
  ].join('\x1f');
}

int _compareOccurrences(ClassOccurrence a, ClassOccurrence b) {
  final byDate = a.date.compareTo(b.date);
  if (byDate != 0) return byDate;
  if (a.isAllDay != b.isAllDay) return a.isAllDay ? -1 : 1;
  final byStart = _compareInstants(a.start, b.start);
  if (byStart != 0) return byStart;
  final byEnd = _compareInstants(a.end, b.end);
  if (byEnd != 0) return byEnd;
  return a.uid.compareTo(b.uid);
}

int _compareInstants(DateTime? a, DateTime? b) {
  if (a == b) return 0;
  if (a == null) return -1;
  if (b == null) return 1;
  return a.compareTo(b);
}

int _compareUndated(ScheduledClass a, ScheduledClass b) {
  final byCourse = _courseKeyOf(a.course).compareTo(_courseKeyOf(b.course));
  if (byCourse != 0) return byCourse;
  return (a.section.sectionCode ?? '').compareTo(b.section.sectionCode ?? '');
}

String _escapeIcsText(String value) => value
    .replaceAll('\\', '\\\\')
    .replaceAll(';', '\\;')
    .replaceAll(',', '\\,')
    .replaceAll('\r\n', '\\n')
    .replaceAll('\r', '\\n')
    .replaceAll('\n', '\\n');

String _foldIcsLine(String line) {
  if (utf8.encode(line).length <= 75) return line;
  final segments = <String>[];
  var remaining = line;
  var first = true;
  while (remaining.isNotEmpty) {
    final budget = first ? 75 : 74;
    final take = _takeUtf8Prefix(remaining, budget);
    segments.add(first ? take : ' $take');
    remaining = remaining.substring(take.length);
    first = false;
  }
  return segments.join('\r\n');
}

/// Takes the longest code-point-safe prefix of at most [budget] UTF-8 octets.
String _takeUtf8Prefix(String text, int budget) {
  var octets = 0;
  var index = 0;
  while (index < text.length) {
    final unit = text.codeUnitAt(index);
    final codeUnits = _isSurrogatePairStart(text, index) ? 2 : 1;
    final byteSize = switch (unit) {
      < 0x80 => 1,
      < 0x800 => 2,
      _ when codeUnits == 2 => 4,
      _ => 3, // BMP non-ASCII; unpaired surrogates encode as U+FFFD (3 bytes)
    };
    if (octets + byteSize > budget) break;
    octets += byteSize;
    index += codeUnits;
  }
  return text.substring(0, index);
}

bool _isSurrogatePairStart(String text, int index) {
  final unit = text.codeUnitAt(index);
  return unit >= 0xd800 && unit < 0xdc00 && index + 1 < text.length && _isLowSurrogate(text.codeUnitAt(index + 1));
}

bool _isLowSurrogate(int unit) => unit >= 0xdc00 && unit <= 0xdfff;

String _formatCampusDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}'
    '${date.day.toString().padLeft(2, '0')}';

String _formatUtcInstant(DateTime instant) {
  final utc = instant.toUtc();
  return '${utc.year.toString().padLeft(4, '0')}${_twoDigits(utc.month)}${_twoDigits(utc.day)}'
      'T${_twoDigits(utc.hour)}${_twoDigits(utc.minute)}${_twoDigits(utc.second)}Z';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
