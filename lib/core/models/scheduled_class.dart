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
}
