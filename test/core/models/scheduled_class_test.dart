import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/scheduled_class.dart';
import 'package:flutter_test/flutter_test.dart';

ScheduledClass scheduledFromJson(Map<String, dynamic> courseJson) =>
    ScheduledClass(course: ClassData.fromJson(courseJson), section: SectionData());

void main() {
  group('ScheduledClass.gradeOption', () {
    test('maps the classic single-letter codes', () {
      expect(scheduledFromJson({'grade_option': 'L'}).gradeOption, 'Letter Grade');
      expect(scheduledFromJson({'grade_option': 'P'}).gradeOption, 'Pass/No Pass');
      expect(scheduledFromJson({'grade_option': 'S'}).gradeOption, 'Sat/Unsat');
    });

    test('maps known TSS vocabulary variants case-insensitively', () {
      expect(scheduledFromJson({'grade_option': 'GRD'}).gradeOption, 'Letter Grade');
      expect(scheduledFromJson({'grade_option': 'pnp'}).gradeOption, 'Pass/No Pass');
      expect(scheduledFromJson({'grade_option': 'S/U'}).gradeOption, 'Sat/Unsat');
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
      expect(ClassData.fromJson({'grade_option': 'L'}).gradeOption, 'L');
    });

    test('falls back to camelCase payloads', () {
      expect(ClassData.fromJson({'gradeOption': 'L'}).gradeOption, 'L');
    });
  });
}
