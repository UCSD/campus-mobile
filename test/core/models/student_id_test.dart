import 'package:barcode_widget/barcode_widget.dart';
import 'package:campus_mobile_experimental/core/models/student_id_name.dart';
import 'package:campus_mobile_experimental/core/models/student_id_photo.dart';
import 'package:campus_mobile_experimental/core/models/student_id_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('name accepts either displayed part and ignores malformed unused fields', () {
    final name = studentIdNameModelFromJson(
      '{"firstName":"  Alex ","lastName":7,"middleName":{},"internalId":[],"studentId":false}',
    );
    expect(name.displayName, 'Alex');
    expect(studentIdNameModelFromJson('{"lastName":"  Smith  "}').displayName, 'Smith');
    expect(studentIdNameModelFromJson('{"firstName":null,"lastName":"  "}').displayName, isEmpty);
  });

  test('profile validates each displayed field separately', () {
    final profile = studentIdProfileModelFromJson(
      '{"Barcode":"1234-56","Classification_Type":false,"College_Current":"  Revelle  ",'
      '"Graduate_Primary_Major_Current":[],"UG_Primary_Major_Current":"  Biology  ",'
      '"Athlete_Current_Count":"wrong","Issue_Number":{},"Student_PID":null}',
    );
    expect(profile.barcode, '1234-56');
    expect(profile.classificationType, isEmpty);
    expect(profile.collegeCurrent, 'Revelle');
    expect(profile.major, 'Biology');
    expect(studentIdProfileModelFromJson('{"Graduate_Primary_Major_Current":" Math "}').major, 'Math');
  });

  test('barcode availability matches Codabar and never substitutes other IDs', () {
    for (final barcode in ['', 'ABCD', '123 45', ' 1234 ', '*', '123456', '12-34', '12:34', '12/34', '12+34']) {
      final parsed = StudentIdProfileModel.fromJson({'Barcode': barcode, 'Student_PID': '987', 'Card_Number': '654'});
      expect(parsed.barcode, Barcode.codabar().isValid(barcode) && barcode.isNotEmpty ? barcode : '');
    }
    expect(StudentIdProfileModel.fromJson({'Barcode': 1234, 'Card_Number': '654'}).barcode, isEmpty);
  });

  test('missing replacement fields retain successful displayed siblings', () {
    final retained = studentIdProfileModelFromJson(
      '{"Barcode":"1234","College_Current":"Revelle","Classification_Type":"Undergraduate",'
      '"UG_Primary_Major_Current":"Biology"}',
    );
    final merged = retained.mergeValid(studentIdProfileModelFromJson('{"Barcode":"bad","College_Current":null}'));
    expect(merged.barcode, '1234');
    expect(merged.collegeCurrent, 'Revelle');
    expect(merged.classificationType, 'Undergraduate');
    expect(merged.major, 'Biology');
    expect(
      studentIdNameModelFromJson(
        '{"firstName":"Alex","lastName":"Smith"}',
      ).mergeValid(studentIdNameModelFromJson('{"firstName":"Sam","lastName":null}')).displayName,
      'Sam Smith',
    );
  });

  test('photo URLs require an HTTP host and a valid string', () {
    for (final value in [
      null,
      123,
      '',
      '  ',
      'photo.png',
      'file:///photo.png',
      'https://',
      'https://user:pass@example.edu/photo',
      'https://example.edu/a b',
    ]) {
      expect(StudentIdPhotoModel.fromJson({'photoUrl': value}).photoUrl, isEmpty);
    }
    expect(
      StudentIdPhotoModel.fromJson({'photoUrl': ' https://example.edu/photo?a=b '}).photoUrl,
      'https://example.edu/photo?a=b',
    );
  });

  test('empty objects are partial responses; malformed JSON/structures fail endpoints', () {
    final parsers = [studentIdNameModelFromJson, studentIdPhotoModelFromJson, studentIdProfileModelFromJson];
    for (final parser in parsers) {
      expect(() => parser('{}'), returnsNormally);
      for (final source in ['', 'invalid', '[]', 'null', '"string"', '200']) {
        expect(() => parser(source), throwsFormatException);
      }
    }
  });
}
