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
    switch (raw.toUpperCase()) {
      case 'L':
      case 'GR':
      case 'GRD':
      case 'LETTER':
        return 'Letter Grade';
      case 'P':
      case 'PN':
      case 'PNP':
      case 'PASS':
        return 'Pass/No Pass';
      case 'S':
      case 'SU':
      case 'S/U':
        return 'Sat/Unsat';
      default:
        // Surface the raw value instead of a misleading "Other" when the
        // TSS API adds new grade-option codes.
        return raw;
    }
  }
}
