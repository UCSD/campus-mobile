import 'classes.dart';

class ScheduledClass {
  final ClassData course;
  final SectionData section;

  const ScheduledClass({required this.course, required this.section});

  String? get subjectCode => course.subjectCode;
  String? get courseCode => course.courseCode;
  String? get courseTitle => course.courseTitle;

  String get displayDays {
    final days = section.days?.trim();
    if (days == null) return 'TBA';
    if (days.isEmpty) return 'TBA';

    const dayLabels = {'MO': 'Mon', 'TU': 'Tue', 'WE': 'Wed', 'TH': 'Thu', 'FR': 'Fri', 'SA': 'Sat', 'SU': 'Sun'};
    final dayCodes = RegExp(
      r'MO|TU|WE|TH|FR|SA|SU',
    ).allMatches(days).map((match) => dayLabels[match.group(0)!]!).toList();
    return dayCodes.isEmpty ? days : dayCodes.join(', ');
  }

  String? get gradeOption {
    final raw = course.gradeOption?.trim();
    if (raw == null || raw.isEmpty) return null;
    switch (raw.toLowerCase()) {
      case 'l':
      case 'letter grade':
        return 'Letter Grade';
      case 'p':
      case 'pn':
      case 'pnp':
      case 'pass/no pass':
      case 'pass/not pass':
        return 'Pass/No Pass';
      case 's':
      case 'su':
      case 's/u':
      case 'sat/unsat':
      case 'satisfactory/unsatisfactory':
        return 'Sat/Unsat';
      default:
        // Surface the raw value instead of a misleading "Other" when the
        // TSS API adds new grade-option codes.
        return raw;
    }
  }

  bool get isWaitlisted {
    final rawStatus = course.enrollmentStatus?.toLowerCase() ?? '';
    final sectionStatus = section.enrollStatus?.toLowerCase() ?? '';
    final waitlistStatus = course.waitlistStatus?.toLowerCase() ?? '';
    return rawStatus.contains('waitlist') ||
        sectionStatus.contains('waitlist') ||
        waitlistStatus.contains('waitlist') ||
        course.waitlistPosition != null;
  }

  int? get waitlistPosition {
    final explicitPosition = course.waitlistPosition;
    if (explicitPosition != null) return explicitPosition;

    final fromEnrollmentStatus = _extractWaitlistPosition(course.enrollmentStatus);
    if (fromEnrollmentStatus != null) return fromEnrollmentStatus;

    final fromWaitlistStatus = _extractWaitlistPosition(course.waitlistStatus);
    if (fromWaitlistStatus != null) return fromWaitlistStatus;

    return _extractWaitlistPosition(section.enrollStatus);
  }

  String get waitlistDisplay {
    final position = waitlistPosition;
    return position == null ? 'Waitlisted' : 'Waitlist #$position';
  }

  static int? _extractWaitlistPosition(String? value) {
    if (value == null || value.isEmpty) return null;
    final match = RegExp(r'(\d+)').firstMatch(value);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }
}
