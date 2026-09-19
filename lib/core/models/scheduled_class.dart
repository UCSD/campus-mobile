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
    if (days == null || days.isEmpty) return 'TBA';

    final dayCodes = RegExp(r'MO|TU|WE|TH|FR|SA|SU').allMatches(days).map((match) => match.group(0)!).toList();
    return dayCodes.isEmpty ? days : dayCodes.join(', ');
  }

  String get gradeOption {
    switch (course.gradeOption) {
      case 'L':
        return 'Letter Grade';
      case 'P':
        return 'Pass/No Pass';
      case 'S':
        return 'Sat/Unsat';
      default:
        return 'Other';
    }
  }
}
