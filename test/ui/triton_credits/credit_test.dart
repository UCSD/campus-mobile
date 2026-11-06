import 'package:campus_mobile_experimental/ui/triton_credits/credit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('credit generates one sentence with the feature, suggester, developer, and date', () {
    final entry = credit(
      feature: 'Triton Credits',
      ideaOwner: 'Kristhian Ortiz',
      devName: 'Prisha Jain',
      date: DateTime(2026, 10, 2),
    );

    expect(
      entry.description,
      'Triton Credits was suggested by Kristhian Ortiz and implemented by Prisha Jain on October 2, 2026.',
    );
  });

  test('credit preserves the supplied calendar date for UTC values', () {
    final entry = credit(feature: 'Feature X', ideaOwner: 'Y', devName: 'Z', date: DateTime.utc(2026, 1, 1));

    expect(entry.description, 'Feature X was suggested by Y and implemented by Z on January 1, 2026.');
  });

  test('credit formats leap-day dates', () {
    final entry = credit(feature: 'Feature X', ideaOwner: 'Y', devName: 'Z', date: DateTime(2024, 2, 29));

    expect(entry.description, 'Feature X was suggested by Y and implemented by Z on February 29, 2024.');
  });
}
