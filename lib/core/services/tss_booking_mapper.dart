import 'package:campus_mobile_experimental/core/models/classes.dart';

// MA-470 tss-classes START - map TSS bookings to Classes
/// Maps student-filtered Booking OData to existing Classes model
/// Maps standard class meetings only
ClassScheduleModel classScheduleModelFromTssBooking(Map<String, dynamic> response, String termCode) {
  final rawBookings = response['value'];
  if (rawBookings is! List) {
    throw const FormatException('TSS Booking response has no value array.');
  }

  final courses = <ClassData>[];
  for (final rawBooking in rawBookings) {
    if (rawBooking is! Map) continue;
    final booking = Map<String, dynamic>.from(rawBooking);
    if (_string(booking['bookingStatusCode']) != '1') continue;

    final moduleCode = _string(booking['moduleCode']);
    if (moduleCode.isEmpty) continue;
    final codeParts = moduleCode.split('-');
    final subjectCode = codeParts.first;
    final courseCode = codeParts.length > 1 ? codeParts.skip(1).join('-') : moduleCode;
    final credits = booking['creditsAttempted'];
    final grade = booking['grade'];
    final sections = <SectionData>[];

    final events = booking['events'];
    if (events is List) {
      for (final rawEvent in events) {
        if (rawEvent is! Map) continue;
        final event = Map<String, dynamic>.from(rawEvent);
        final eventCode = _string(event['eventCode']);
        final section = eventCode.isEmpty ? '' : eventCode.split('-').first;
        final meetingType = _string(event['instructionType']);
        final instructor = _instructorName(event['instructors']);
        final meetings = event['meetings'];
        if (meetings is! List) continue;

        for (final rawMeeting in meetings) {
          if (rawMeeting is! Map) continue;
          final meeting = Map<String, dynamic>.from(rawMeeting);
          final start = _clockTime(meeting['startTime']);
          final end = _clockTime(meeting['endTime']);
          if (start == null || end == null) continue;
          final days = _meetingDays(meeting);
          for (final day in days.isEmpty ? const ['OTHER'] : days) {
            sections.add(
              SectionData(
                section: section,
                meetingType: meetingType.isEmpty ? 'Class' : meetingType,
                // TimeRangeWidget expects spaces around dash
                time: '$start - $end',
                days: day,
                date: _string(meeting['startDate']),
                building: _firstNonempty(meeting['buildingName'], meeting['buildingCode']),
                room: _firstNonempty(meeting['roomName'], meeting['roomCode']),
                instructorName: instructor.isEmpty ? 'TBA' : instructor,
              ),
            );
          }
        }
      }
    }

    courses.add(
      ClassData(
        termCode: termCode,
        subjectCode: subjectCode,
        courseCode: courseCode,
        units: credits is num ? credits.toDouble() : double.tryParse(_string(credits)),
        courseLevel: _string(booking['programTypeCode']),
        gradeOption: _gradeOption(booking['appraisalTemplateName']),
        grade: grade is Map ? _string(grade['finalGrade']) : '',
        courseTitle: _string(booking['moduleName']),
        enrollmentStatus: 'EN',
        sectionData: sections,
      ),
    );
  }

  return ClassScheduleModel(metadata: Metadata(), data: courses);
}

String _string(Object? value) => value == null ? '' : value.toString().trim();

String _firstNonempty(Object? first, Object? second) {
  final firstValue = _string(first);
  return firstValue.isNotEmpty ? firstValue : _string(second);
}

String _gradeOption(Object? name) {
  final value = _string(name).toLowerCase();
  if (value.contains('pass') && value.contains('no pass')) return 'P';
  if (value.contains('satisfactory') || value.contains('sat/unsat')) return 'S';
  if (value.contains('letter')) return 'L';
  return '';
}

String? _clockTime(Object? value) {
  final match = RegExp(r'^(\d{2}):(\d{2})(?::\d{2})?$').firstMatch(_string(value));
  if (match == null) return null;
  final hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  if (hour > 23 || minute > 59) return null;
  return '${match.group(1)}:${match.group(2)}';
}

List<String> _meetingDays(Map<String, dynamic> meeting) {
  const dayFields = {
    'monday': 'MO',
    'tuesday': 'TU',
    'wednesday': 'WE',
    'thursday': 'TH',
    'friday': 'FR',
    'saturday': 'SA',
    'sunday': 'SU',
  };
  return [
    for (final entry in dayFields.entries)
      if (meeting[entry.key] == true) entry.value,
  ];
}

String _instructorName(Object? rawInstructors) {
  if (rawInstructors is! List) return '';
  for (final rawInstructor in rawInstructors) {
    if (rawInstructor is! Map) continue;
    final instructor = Map<String, dynamic>.from(rawInstructor);
    final fullName = _firstNonempty(instructor['name'], instructor['instructorName']);
    if (fullName.isNotEmpty) return fullName;
    final first = _firstNonempty(instructor['firstName'], instructor['givenName']);
    final last = _firstNonempty(instructor['lastName'], instructor['familyName']);
    final joined = '$first $last'.trim();
    if (joined.isNotEmpty) return joined;
  }
  return '';
}

// MA-470 tss-classes END - map TSS bookings to Classes
