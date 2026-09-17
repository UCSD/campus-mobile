import 'package:campus_mobile_experimental/core/models/classes.dart';

// MA-470 tss-finals-midterm START - map exact booked events to exam meetings
ClassScheduleModel classScheduleModelFromTssExams({
  required Map<String, dynamic> bookingResponse,
  required Map<String, dynamic> eventsResponse,
  required String termCode,
}) {
  final rawBookings = bookingResponse['value'];
  final rawEvents = eventsResponse['value'];
  if (rawBookings is! List) {
    throw const FormatException('TSS Booking response has no value array');
  }
  if (rawEvents is! List) {
    throw const FormatException('TSS Events response has no value array');
  }

  final catalogEvents = <String, Map<String, dynamic>>{};
  for (final rawEvent in rawEvents) {
    if (rawEvent is! Map) continue;
    final event = Map<String, dynamic>.from(rawEvent);
    final eventId = _string(event['eventId']);
    if (eventId.isNotEmpty) catalogEvents[eventId] = event;
  }

  final courses = <String, ClassData>{};
  final mappedMeetings = <String>{};

  for (final rawBooking in rawBookings) {
    if (rawBooking is! Map) continue;
    final booking = Map<String, dynamic>.from(rawBooking);
    if (_string(booking['bookingStatusCode']) != '1') continue;

    final moduleCode = _string(booking['moduleCode']);
    if (moduleCode.isEmpty) continue;
    final codeParts = moduleCode.split('-');
    final subjectCode = codeParts.first;
    final courseCode = codeParts.length > 1 ? codeParts.skip(1).join('-') : moduleCode;
    final course = courses.putIfAbsent(
      moduleCode,
      () => ClassData(
        termCode: termCode,
        subjectCode: subjectCode,
        courseCode: courseCode,
        courseLevel: _string(booking['programTypeCode']),
        gradeOption: '',
        courseTitle: _string(booking['moduleName']),
        enrollmentStatus: 'EN',
        sectionData: <SectionData>[],
      ),
    );

    final rawBookedEvents = booking['events'];
    if (rawBookedEvents is! List) continue;
    for (final rawBookedEvent in rawBookedEvents) {
      if (rawBookedEvent is! Map) continue;
      final bookedEventId = _string(rawBookedEvent['eventId']);
      final event = catalogEvents[bookedEventId];
      if (event == null) continue;
      if (_string(event['moduleCode']) != moduleCode) continue;

      final rawMeetingSchedule = event['meetingSchedule'];
      if (rawMeetingSchedule is! List) continue;
      for (final rawMeeting in rawMeetingSchedule) {
        if (rawMeeting is! Map) continue;
        final meeting = Map<String, dynamic>.from(rawMeeting);
        final meetingType = _string(meeting['instructionType']).toUpperCase();
        if (meetingType != 'FI' && meetingType != 'MI') continue;

        final start = _clockTime(meeting['startTime']);
        final end = _clockTime(meeting['endTime']);
        final date = _date(meeting['meetingDate']);
        if (start == null || end == null || date == null) continue;

        final uniqueKey = '$moduleCode|$bookedEventId|$meetingType|$date|$start|$end';
        if (!mappedMeetings.add(uniqueKey)) continue;
        course.sectionData!.add(
          SectionData(
            section: _string(event['eventCode']),
            meetingType: meetingType == 'FI' ? 'Final' : 'Midterm',
            time: '$start - $end',
            days: _meetingDay(meeting, date),
            date: date,
            building: _firstNonempty(meeting['buildingName'], meeting['buildingCode']),
            room: _firstNonempty(meeting['roomName'], meeting['roomCode']),
            instructorName: _instructorName(event['instructors']),
            specialMtgCode: meetingType,
            enrollStatus: 'EN',
          ),
        );
      }
    }
  }

  final examCourses = courses.values.where((course) => course.sectionData!.isNotEmpty).toList();
  return ClassScheduleModel(metadata: Metadata(), data: examCourses);
}

String _string(Object? value) => value == null ? '' : value.toString().trim();

String _firstNonempty(Object? first, Object? second) {
  final firstValue = _string(first);
  return firstValue.isNotEmpty ? firstValue : _string(second);
}

String? _clockTime(Object? value) {
  final match = RegExp(r'^(\d{2}):(\d{2})(?::\d{2})?$').firstMatch(_string(value));
  if (match == null) return null;
  final hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  if (hour > 23 || minute > 59) return null;
  return '${match.group(1)}:${match.group(2)}';
}

String? _date(Object? value) {
  final raw = _string(value);
  final match = RegExp(r'^(\d{4}-\d{2}-\d{2})').firstMatch(raw);
  if (match == null || DateTime.tryParse(match.group(1)!) == null) return null;
  return match.group(1);
}

String _meetingDay(Map<String, dynamic> meeting, String date) {
  const fields = {
    'monday': 'MO',
    'tuesday': 'TU',
    'wednesday': 'WE',
    'thursday': 'TH',
    'friday': 'FR',
    'saturday': 'SA',
    'sunday': 'SU',
  };
  for (final entry in fields.entries) {
    if (meeting[entry.key] == true) return entry.value;
  }
  const weekdays = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
  final parsed = DateTime.tryParse(date);
  return parsed == null ? 'OTHER' : weekdays[parsed.weekday - 1];
}

String _instructorName(Object? rawInstructors) {
  if (rawInstructors is! List) return 'TBA';
  for (final rawInstructor in rawInstructors) {
    if (rawInstructor is! Map) continue;
    final instructor = Map<String, dynamic>.from(rawInstructor);
    final name = _firstNonempty(instructor['instructorName'], instructor['name']);
    if (name.isNotEmpty) return name;
  }
  return 'TBA';
}

// MA-470 tss-finals-midterm END - map exact booked events to exam meetings
