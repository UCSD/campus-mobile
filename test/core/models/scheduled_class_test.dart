import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/scheduled_class.dart';
import 'package:flutter_test/flutter_test.dart';

ScheduledClass scheduledFromJson(Map<String, dynamic> courseJson) =>
    ScheduledClass(course: ClassData.fromJson(courseJson), section: SectionData());

void main() {
  group('ScheduledClass.gradeOption', () {
    test('maps the legacy single-letter codes', () {
      expect(scheduledFromJson({'grade_option': 'L'}).gradeOption, 'Letter Grade');
      expect(scheduledFromJson({'grade_option': 'P'}).gradeOption, 'Pass/No Pass');
      expect(scheduledFromJson({'grade_option': 'S'}).gradeOption, 'Sat/Unsat');
    });

    test('maps real MyAcademicHistory Title Case values', () {
      expect(scheduledFromJson({'grade_option': 'Letter Grade'}).gradeOption, 'Letter Grade');
      expect(scheduledFromJson({'grade_option': 'Pass/No Pass'}).gradeOption, 'Pass/No Pass');
      expect(scheduledFromJson({'grade_option': 'Sat/Unsat'}).gradeOption, 'Sat/Unsat');
      expect(scheduledFromJson({'grade_option': 'Satisfactory/Unsatisfactory'}).gradeOption, 'Sat/Unsat');
    });

    test('maps grade-option spellings case-insensitively', () {
      expect(scheduledFromJson({'grade_option': 'letter grade'}).gradeOption, 'Letter Grade');
      expect(scheduledFromJson({'grade_option': 'pass/not pass'}).gradeOption, 'Pass/No Pass');
      expect(scheduledFromJson({'grade_option': 's/u'}).gradeOption, 'Sat/Unsat');
    });

    test('passes unrecognized non-empty values through verbatim', () {
      expect(scheduledFromJson({'grade_option': 'Z'}).gradeOption, 'Z');
      expect(scheduledFromJson({'grade_option': 'credit'}).gradeOption, 'credit');
    });

    test('returns null when the value is missing, null, or blank', () {
      expect(scheduledFromJson({}).gradeOption, isNull);
      expect(scheduledFromJson({'grade_option': null}).gradeOption, isNull);
      expect(scheduledFromJson({'grade_option': '   '}).gradeOption, isNull);
    });
  });

  group('ClassData.fromJson grade_option parsing', () {
    test('reads snake_case payloads', () {
      expect(ClassData.fromJson({'grade_option': 'Letter Grade'}).gradeOption, 'Letter Grade');
    });

    test('falls back to camelCase payloads', () {
      expect(ClassData.fromJson({'gradeOption': 'Pass/No Pass'}).gradeOption, 'Pass/No Pass');
    });
  });
}
