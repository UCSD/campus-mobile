import 'dart:convert';

import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/services/classes_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final generatedAt = DateTime.utc(2026, 11, 13, 10);

  ClassScheduleModel _schedule(List<ClassData> courses) => ClassScheduleModel(data: courses);

  ClassData _course({
    List<SectionData> sections = const [],
    String termCode = 'FA26',
    String enrollmentStatus = 'Booked',
    String courseTitle = 'Synthetic Course',
  }) => ClassData(
    termCode: termCode,
    subjectCode: 'CSE',
    courseCode: '100',
    units: 4,
    courseLevel: 'UG',
    gradeOption: 'L',
    courseTitle: courseTitle,
    enrollmentStatus: enrollmentStatus,
    sectionData: List<SectionData>.from(sections),
  );

  SectionData _section({
    String section = 'A00',
    String sectionCode = '10001',
    String meetingType = 'Lecture',
    String? date,
    String? time,
    String? days,
    String building = 'Synthetic Hall',
    String room = '100',
    String instructorName = 'Synthetic Instructor',
    String? specialMtgCode,
  }) => SectionData(
    section: section,
    sectionCode: sectionCode,
    meetingType: meetingType,
    date: date,
    time: time,
    days: days,
    building: building,
    room: room,
    instructorName: instructorName,
    specialMtgCode: specialMtgCode,
    enrollStatus: 'EN',
  );

  List<DateTime> _dates(ClassCalendarData calendar) =>
      calendar.occurrences.map((occurrence) => occurrence.date).toList();

  String _unfolded(String ics) => ics.split('\r\n').fold('', (content, line) {
    if (line.startsWith(' ')) return content + line.substring(1);
    return content.isEmpty ? line : '$content\r\n$line';
  });

  test('empty, unsupported, and mixed terms are safely unavailable', () {
    final empty = buildClassCalendar(ClassScheduleModel());
    expect(empty.quarter, isNull);
    expect(empty.occurrences, isEmpty);
    expect(empty.undated, isEmpty);
    expect(empty.omissions, isEmpty);
    expect(createClassesCalendarIcs(empty, generatedAt: generatedAt), isNull);

    final unsupported = buildClassCalendar(
      _schedule([
        _course(
          termCode: 'XX26',
          sections: [_section(date: '2026-9-25', time: '10:00 - 10:50', days: 'FR')],
        ),
      ]),
    );
    expect(unsupported.quarter, isNull);
    expect(unsupported.occurrences, isEmpty);
    expect(unsupported.undated, isEmpty);
    expect(unsupported.omissions, isEmpty);
    expect(createClassesCalendarIcs(unsupported, generatedAt: generatedAt), isNull);

    final mixed = buildClassCalendar(
      _schedule([
        _course(
          sections: [_section(date: '2026-9-25', time: '10:00 - 10:50', days: 'FR')],
        ),
        _course(
          termCode: 'WI27',
          sections: [_section(date: '2027-1-5', time: '10:00 - 10:50', days: 'TU')],
        ),
      ]),
    );
    expect(mixed.quarter, isNull);
    expect(mixed.occurrences, isEmpty);
    expect(mixed.undated, isEmpty);
    expect(mixed.omissions, isEmpty);
    expect(createClassesCalendarIcs(mixed, generatedAt: generatedAt), isNull);
  });

  test('only Booked courses are included', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          sections: [_section(date: '2026-9-25', time: '10:00 - 10:50', days: 'FR')],
        ),
        _course(
          enrollmentStatus: 'Planned',
          sections: [_section(date: '2026-9-25', time: '12:00 - 12:50', days: 'FR')],
        ),
      ]),
    );

    expect(calendar.quarter?.termCode, 'FA26');
    expect(calendar.occurrences, hasLength(1));
    expect(calendar.undated, isEmpty);
    expect(calendar.omissions, isEmpty);
  });

  test('midterms, finals, and exam meeting types are excluded and not omissions', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          sections: [
            _section(sectionCode: '10001', date: '2026-9-25', time: '10:00 - 10:50', days: 'FR'),
            _section(
              sectionCode: '10002',
              meetingType: 'Midterm',
              date: '2026-10-7',
              time: '10:00 - 11:50',
              days: 'WE',
              specialMtgCode: 'MI',
            ),
            _section(
              sectionCode: '10003',
              meetingType: 'Final',
              date: '2026-12-8',
              time: '10:00 - 12:50',
              days: 'TU',
              specialMtgCode: 'FI',
            ),
            _section(sectionCode: '10004', meetingType: 'Exam', date: '2026-10-14', time: '10:00 - 11:50', days: 'WE'),
          ],
        ),
      ]),
    );

    expect(calendar.occurrences, hasLength(1));
    expect(calendar.occurrences.single.scheduledClass.section.sectionCode, '10001');
    expect(calendar.undated, isEmpty);
    expect(calendar.omissions, isEmpty);
  });

  test('multiple weekdays and duplicate canonical records are not duplicated', () {
    final course = _course(
      sections: [_section(time: '10:00 - 10:50', days: 'MO WE FR')],
    );
    final calendar = buildClassCalendar(_schedule([course, course]));

    expect(calendar.occurrences, hasLength(29));
    expect(_dates(calendar), contains(DateTime.utc(2026, 9, 25)));
    expect(_dates(calendar), contains(DateTime.utc(2026, 9, 28)));
    expect(_dates(calendar), contains(DateTime.utc(2026, 9, 30)));
    expect(_dates(calendar).toSet(), hasLength(29));
  });

  test('Fall 2026 MO WE FR meetings cover teaching dates after published holidays', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          sections: [_section(time: '10:00 - 10:50', days: 'MO WE FR')],
        ),
      ]),
    );
    final dates = _dates(calendar);

    expect(calendar.quarter?.termCode, 'FA26');
    expect(calendar.quarter?.label, 'Fall 2026');
    expect(calendar.quarter?.start, DateTime.utc(2026, 9, 21));
    expect(calendar.quarter?.end, DateTime.utc(2026, 12, 12));
    expect(calendar.quarter?.instructionStart, DateTime.utc(2026, 9, 24));
    expect(calendar.quarter?.instructionEnd, DateTime.utc(2026, 12, 4));
    expect(dates, hasLength(29));
    expect(dates.toSet(), hasLength(29));
    expect(dates, contains(DateTime.utc(2026, 9, 25)));
    expect(dates, contains(DateTime.utc(2026, 12, 4)));
    expect(dates, isNot(contains(DateTime.utc(2026, 11, 11))));
    expect(dates, isNot(contains(DateTime.utc(2026, 11, 26))));
    expect(dates, isNot(contains(DateTime.utc(2026, 11, 27))));
    expect(
      dates.every((date) => !date.isBefore(DateTime.utc(2026, 9, 24)) && !date.isAfter(DateTime.utc(2026, 12, 4))),
      isTrue,
    );
  });

  test('Winter and Spring use their verified plan date ranges', () {
    final winter = buildClassCalendar(
      _schedule([
        _course(
          termCode: 'WI27',
          sections: [_section(time: '10:00 - 10:50', days: 'MO')],
        ),
      ]),
    );
    final winterDates = _dates(winter);

    expect(winter.quarter?.termCode, 'WI27');
    expect(winter.quarter?.label, 'Winter 2027');
    expect(winter.quarter?.start, DateTime.utc(2027, 1, 4));
    expect(winter.quarter?.end, DateTime.utc(2027, 3, 20));
    expect(winter.quarter?.instructionStart, DateTime.utc(2027, 1, 4));
    expect(winter.quarter?.instructionEnd, DateTime.utc(2027, 3, 12));
    expect(winterDates, hasLength(8));
    expect(winterDates, contains(DateTime.utc(2027, 1, 4)));
    expect(winterDates, contains(DateTime.utc(2027, 3, 8)));
    expect(winterDates, isNot(contains(DateTime.utc(2027, 1, 18))));
    expect(winterDates, isNot(contains(DateTime.utc(2027, 2, 15))));

    final spring = buildClassCalendar(
      _schedule([
        _course(
          termCode: 'SP27',
          sections: [_section(time: '10:00 - 10:50', days: 'MO')],
        ),
      ]),
    );
    final springDates = _dates(spring);

    expect(spring.quarter?.termCode, 'SP27');
    expect(spring.quarter?.label, 'Spring 2027');
    expect(spring.quarter?.start, DateTime.utc(2027, 3, 24));
    expect(spring.quarter?.end, DateTime.utc(2027, 6, 11));
    expect(spring.quarter?.instructionStart, DateTime.utc(2027, 3, 29));
    expect(spring.quarter?.instructionEnd, DateTime.utc(2027, 6, 4));
    expect(springDates, hasLength(9));
    expect(springDates, contains(DateTime.utc(2027, 3, 29)));
    expect(springDates, contains(DateTime.utc(2027, 5, 24)));
    expect(springDates, isNot(contains(DateTime.utc(2027, 5, 31))));
  });

  test('explicitly dated eligible meetings occur once', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          sections: [_section(date: '2026-10-7', time: '10:00 - 10:50', days: 'WE')],
        ),
      ]),
    );

    expect(calendar.occurrences.where((occurrence) => occurrence.date == DateTime.utc(2026, 10, 7)), hasLength(1));
    expect(_dates(calendar).toSet(), hasLength(calendar.occurrences.length));
  });

  test('missing date is undated, malformed date is omitted, and valid date is dated', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          sections: [
            _section(sectionCode: '10001', date: null, time: '10:00 - 10:50', days: null),
            _section(sectionCode: '10002', date: 'not-a-date', time: '10:00 - 10:50', days: 'MO WE FR'),
            _section(sectionCode: '10003', date: '2026-10-7', time: '10:00 - 10:50', days: ''),
          ],
        ),
      ]),
    );

    expect(calendar.undated, hasLength(1));
    expect(calendar.undated.single.section.sectionCode, '10001');
    expect(calendar.omissions, hasLength(1));
    expect(calendar.omissions.single.trim(), isNotEmpty);
    expect(calendar.occurrences, hasLength(1));
    expect(calendar.occurrences.single.date, DateTime.utc(2026, 10, 7));
  });

  test('reliable-date TBA and reversed or unusable times are dated all-day events', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          sections: [
            _section(sectionCode: '10001', date: '2026-10-7', time: null, days: 'WE'),
            _section(sectionCode: '10002', date: '2026-10-7', time: 'TBA', days: 'WE'),
            _section(sectionCode: '10003', date: '2026-10-7', time: '11:00 - 10:00', days: 'WE'),
            _section(sectionCode: '10004', date: '2026-10-7', time: 'not-a-time', days: 'WE'),
          ],
        ),
      ]),
    );

    expect(calendar.occurrences, hasLength(4));
    expect(_dates(calendar), everyElement(DateTime.utc(2026, 10, 7)));
    expect(calendar.occurrences.map((occurrence) => occurrence.isAllDay), everyElement(isTrue));
    expect(calendar.occurrences.map((occurrence) => occurrence.start), everyElement(isNull));
    expect(calendar.occurrences.map((occurrence) => occurrence.end), everyElement(isNull));
    expect(calendar.undated, isEmpty);
  });

  test('meetingsOn compares campus-local date components and returns dated events only', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          sections: [
            _section(sectionCode: '10001', date: '2026-10-7', time: '10:00 - 10:50', days: 'WE'),
            _section(sectionCode: '10002', date: null, time: '10:00 - 10:50', days: null),
          ],
        ),
      ]),
    );

    expect(calendar.meetingsOn(DateTime(2026, 10, 7, 8)), hasLength(1));
    expect(calendar.meetingsOn(DateTime(2026, 10, 7, 23, 59)), hasLength(1));
    expect(calendar.meetingsOn(DateTime.utc(2026, 10, 7)), hasLength(1));
    expect(calendar.meetingsOn(DateTime.utc(2026, 10, 8)), isEmpty);
  });

  test('both campus DST offsets map a 10am meeting to 17 and 18 UTC', () {
    final fall = buildClassCalendar(
      _schedule([
        _course(
          sections: [_section(date: '2026-10-26', time: '10:00 - 10:50', days: 'MO')],
        ),
        _course(
          sections: [_section(date: '2026-11-9', time: '10:00 - 10:50', days: 'MO')],
        ),
      ]),
    );
    final october = fall.occurrences.singleWhere((occurrence) => occurrence.date == DateTime.utc(2026, 10, 26));
    final november = fall.occurrences.singleWhere((occurrence) => occurrence.date == DateTime.utc(2026, 11, 9));

    expect(october.start, DateTime.utc(2026, 10, 26, 17));
    expect(october.end, DateTime.utc(2026, 10, 26, 17, 50));
    expect(november.start, DateTime.utc(2026, 11, 9, 18));
    expect(november.end, DateTime.utc(2026, 11, 9, 18, 50));

    final springForward = buildClassCalendar(
      _schedule([
        _course(
          termCode: 'WI27',
          sections: [_section(date: '2027-3-8', time: '10:00 - 10:50', days: 'MO')],
        ),
      ]),
    );
    expect(springForward.occurrences.single.start, DateTime.utc(2027, 3, 8, 18));
  });

  test('building the calendar does not mutate canonical input', () {
    final schedule = _schedule([
      _course(
        sections: [_section(time: '10:00 - 10:50', days: 'MO WE FR')],
      ),
    ]);
    final before = jsonEncode(schedule.toJson());

    final calendar = buildClassCalendar(schedule);
    calendar.meetingsOn(DateTime(2026, 9, 25));
    expect(jsonEncode(schedule.toJson()), before);
  });

  test('occurrence identity is stable, unique, and sourced without student identifiers', () {
    final schedule = _schedule([
      _course(
        sections: [_section(sectionCode: '10001', time: '10:00 - 10:50', days: 'MO WE FR')],
      ),
    ]);

    final first = buildClassCalendar(schedule);
    final second = buildClassCalendar(schedule);
    expect(
      first.occurrences.map((occurrence) => occurrence.uid),
      second.occurrences.map((occurrence) => occurrence.uid),
    );
    expect(
      first.occurrences.map((occurrence) => occurrence.courseKey),
      second.occurrences.map((occurrence) => occurrence.courseKey),
    );
    expect(first.occurrences.map((occurrence) => occurrence.uid).toSet(), hasLength(first.occurrences.length));
    expect(first.occurrences.map((occurrence) => occurrence.courseKey), everyElement(isNotEmpty));

    // Canonical source records have no student identifier; source identity is course/section based.
    expect(jsonEncode(schedule.toJson()), isNot(contains('student')));
  });

  test('ICS exports the whole quarter with required wrapper, properties, and UTC dates', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          sections: [_section(time: '10:00 - 10:50', days: 'MO WE FR')],
        ),
      ]),
    );
    final ics = createClassesCalendarIcs(calendar, generatedAt: generatedAt);

    expect(ics, isNotNull);
    expect(ics!.startsWith('BEGIN:VCALENDAR\r\n'), isTrue);
    expect(ics, contains('VERSION:2.0'));
    expect(ics, contains('PRODID:'));
    expect('BEGIN:VEVENT\r\n'.allMatches(ics), hasLength(29));
    expect(ics, contains('END:VCALENDAR\r\n'));

    final lines = _unfolded(ics).split('\r\n');
    final starts = lines.where((line) => line.startsWith('DTSTART:')).toList();
    final ends = lines.where((line) => line.startsWith('DTEND:')).toList();
    final stamps = lines.where((line) => line.startsWith('DTSTAMP:')).toList();
    expect(starts, hasLength(29));
    expect(ends, hasLength(29));
    expect(starts, everyElement(endsWith('Z')));
    expect(ends, everyElement(endsWith('Z')));
    expect(stamps, hasLength(29));
    expect(stamps, everyElement('DTSTAMP:20261113T100000Z'));
  });

  test('ICS all-day events use the date and an exclusive next date', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          sections: [_section(date: '2026-10-7', time: null, days: 'WE')],
        ),
      ]),
    );
    final ics = createClassesCalendarIcs(calendar, generatedAt: generatedAt)!;

    expect(ics, contains('DTSTART;VALUE=DATE:20261007'));
    expect(ics, contains('DTEND;VALUE=DATE:20261008'));
    expect(ics, isNot(contains('DTSTART;VALUE=DATE:20261007T')));
  });

  test('ICS escapes text and contains injected property names', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          courseTitle: 'Comma, Semicolon; Backslash \\\nUID:hack\r\nSTATUS:CONFIRMED',
          sections: [_section(date: '2026-10-7', time: '10:00 - 10:50', days: 'WE')],
        ),
      ]),
    );
    final ics = createClassesCalendarIcs(calendar, generatedAt: generatedAt)!;
    final unfolded = _unfolded(ics);

    expect(unfolded, contains(r'\,'));
    expect(unfolded, contains(r'\;'));
    expect(unfolded, contains(r'\n'));
    expect(unfolded.split('\r\n'), isNot(contains('UID:hack')));
    expect(unfolded.split('\r\n'), isNot(contains('STATUS:CONFIRMED')));
  });

  test('ICS lines fold within 75 UTF-8 octets and end with CRLF', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          courseTitle:
              'A very long synthetic title with Unicode: \u{1F600}\u{1F601}\u{1F602}\u{1F603}\u{1F604}\u{1F605}\u{1F606}',
          sections: [_section(date: '2026-10-7', time: '10:00 - 10:50', days: 'WE')],
        ),
      ]),
    );
    final ics = createClassesCalendarIcs(calendar, generatedAt: generatedAt)!;
    final lines = ics.split('\r\n');

    expect(lines.map((line) => utf8.encode(line).length), everyElement(lessThanOrEqualTo(75)));
    expect(ics.endsWith('\r\n'), isTrue);
    expect(ics.replaceAll('\r\n', '').contains('\r'), isFalse);
    expect(ics.replaceAll('\r\n', '').contains('\n'), isFalse);
  });

  test('ICS does not include exams or zero-event files', () {
    final withExams = buildClassCalendar(
      _schedule([
        _course(
          sections: [
            _section(date: '2026-9-25', time: '10:00 - 10:50', days: 'FR'),
            _section(meetingType: 'Final', date: '2026-12-8', time: '10:00 - 12:50', days: 'TU', specialMtgCode: 'FI'),
          ],
        ),
      ]),
    );
    final ics = createClassesCalendarIcs(withExams, generatedAt: generatedAt)!;
    final summaries = _unfolded(ics).split('\r\n').where((line) => line.startsWith('SUMMARY:')).toList();

    expect('BEGIN:VEVENT\r\n'.allMatches(ics), hasLength(1));
    expect(summaries, everyElement(isNot(contains('Final'))));
    expect(summaries, everyElement(isNot(contains('FI'))));

    final empty = buildClassCalendar(ClassScheduleModel());
    expect(createClassesCalendarIcs(empty, generatedAt: generatedAt), isNull);
  });

  test('all seven weekdays recur on their eligible teaching dates', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          sections: [
            _section(sectionCode: '10001', time: '10:00 - 10:50', days: 'MO'),
            _section(sectionCode: '10002', time: '10:00 - 10:50', days: 'TU'),
            _section(sectionCode: '10003', time: '10:00 - 10:50', days: 'WE'),
            _section(sectionCode: '10004', time: '10:00 - 10:50', days: 'TH'),
            _section(sectionCode: '10005', time: '10:00 - 10:50', days: 'FR'),
            _section(sectionCode: '10006', time: '10:00 - 10:50', days: 'SA'),
            _section(sectionCode: '10007', time: '10:00 - 10:50', days: 'SU'),
          ],
        ),
      ]),
    );

    // FA26 teaching dates: MO 10, TU 10, WE 9 (Nov 11 holiday), TH 10
    // (Nov 26 holiday), FR 10 (Nov 27 holiday), SA 10, SU 10.
    expect(calendar.occurrences, hasLength(69));
    expect(calendar.omissions, isEmpty);
    expect(calendar.undated, isEmpty);
  });

  test('same-day meetings sort all-day first with distinct section identities', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          sections: [
            _section(sectionCode: '10001', date: '2026-10-7', time: '09:00 - 09:50', days: 'WE'),
            _section(sectionCode: '10002', date: '2026-10-7', time: 'TBA', days: 'WE'),
            _section(sectionCode: '10003', date: '2026-10-7', time: '11:00 - 11:50', days: 'WE'),
          ],
        ),
      ]),
    );
    final meetings = calendar.meetingsOn(DateTime.utc(2026, 10, 7));

    expect(meetings, hasLength(3));
    expect(meetings.first.isAllDay, isTrue);
    expect(meetings.skip(1).map((occurrence) => occurrence.isAllDay), everyElement(isFalse));
    expect(meetings[1].start, DateTime.utc(2026, 10, 7, 16));
    expect(meetings[2].start, DateTime.utc(2026, 10, 7, 18));
    expect(meetings.map((occurrence) => occurrence.uid).toSet(), hasLength(3));
  });

  test('out-of-bounds or equal time endpoints become all-day meetings', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          sections: [
            _section(sectionCode: '10001', date: '2026-10-7', time: '24:00 - 25:00', days: 'WE'),
            _section(sectionCode: '10002', date: '2026-10-7', time: '10:60 - 11:00', days: 'WE'),
            _section(sectionCode: '10003', date: '2026-10-7', time: '10:00:59 - 10:00:59', days: 'WE'),
          ],
        ),
      ]),
    );

    expect(calendar.occurrences, hasLength(3));
    expect(calendar.occurrences.map((occurrence) => occurrence.isAllDay), everyElement(isTrue));
    expect(calendar.undated, isEmpty);
    expect(classMeetingTimeRange('9:30 - 10:20'), (startSeconds: 34200, endSeconds: 37200));
    expect(classMeetingTimeRange('10:00-10:50'), (startSeconds: 36000, endSeconds: 39000));
    expect(classMeetingTimeRange('2:30:15 - 3:45:30'), (startSeconds: 9015, endSeconds: 13530));
    expect(classMeetingTimeRange('25:00 - 26:00'), isNull);
    expect(classMeetingTimeRange('10:00 - 10:00'), isNull);
    expect(classMeetingTimeRange('garbage'), isNull);
    expect(classMeetingTimeRange(null), isNull);
  });

  test('Spring 2027 timed meetings keep campus time across the March DST change', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          termCode: 'SP27',
          sections: [_section(date: '2027-3-29', time: '10:00 - 10:50', days: 'MO')],
        ),
      ]),
    );

    expect(calendar.occurrences.single.start, DateTime.utc(2027, 3, 29, 17));
    expect(calendar.occurrences.single.end, DateTime.utc(2027, 3, 29, 17, 50));
  });

  test('dated records outside the quarter or impossible are omissions without occurrences', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          sections: [
            _section(sectionCode: '10001', date: '2026-12-20', time: '10:00 - 10:50', days: 'SU'),
            _section(sectionCode: '10002', date: '2026-2-30', time: '10:00 - 10:50', days: 'MO'),
            _section(sectionCode: '10003', date: '2026-09-25', time: '10:00 - 10:50', days: 'FR'),
          ],
        ),
      ]),
    );

    expect(calendar.quarter?.termCode, 'FA26');
    expect(calendar.occurrences, hasLength(1));
    expect(calendar.occurrences.single.date, DateTime.utc(2026, 9, 25));
    expect(calendar.undated, isEmpty);
    expect(calendar.omissions, hasLength(2));
    expect(calendar.omissions, everyElement(isNotEmpty));
  });

  test('malformed weekday strings never invent occurrences', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          sections: [
            _section(sectionCode: '10001', time: '10:00 - 10:50', days: 'SUPER'),
            _section(sectionCode: '10002', time: '10:00 - 10:50', days: 'MONTHLY'),
            _section(sectionCode: '10003', time: '10:00 - 10:50', days: 'MO X'),
          ],
        ),
      ]),
    );

    expect(calendar.occurrences, isEmpty);
    expect(calendar.undated, hasLength(3));
    expect(calendar.omissions, isEmpty);
  });

  test('concatenated weekday tokens are recognized', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          sections: [_section(time: '10:00 - 10:50', days: 'MOTU')],
        ),
      ]),
    );

    // MO 10 eligible Mondays + TU 10 eligible Tuesdays in FA26.
    expect(calendar.occurrences, hasLength(20));
  });

  test('explicitly dated meetings on published holidays are excluded like exams', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          sections: [
            _section(sectionCode: '10001', date: '2026-11-26', time: '10:00 - 10:50', days: 'TH'),
            _section(sectionCode: '10002', date: '2026-11-27', time: '10:00 - 10:50', days: 'FR'),
          ],
        ),
      ]),
    );

    expect(calendar.occurrences, isEmpty);
    expect(calendar.undated, isEmpty);
    expect(calendar.omissions, isEmpty);
  });

  test('duplicate scheduling records differing only in display metadata deduplicate', () {
    final calendar = buildClassCalendar(
      _schedule([
        _course(
          sections: [_section(time: '10:00 - 10:50', days: 'MO', building: 'Hall A', instructorName: 'Dr. One')],
        ),
        _course(
          sections: [_section(time: '10:00 - 10:50', days: 'MO', building: 'Hall B', instructorName: 'Dr. Two')],
        ),
      ]),
    );

    expect(calendar.occurrences, hasLength(10));
    expect(calendar.occurrences.map((occurrence) => occurrence.uid).toSet(), hasLength(10));
  });
}
