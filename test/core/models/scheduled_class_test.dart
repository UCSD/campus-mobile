import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/scheduled_class.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses an explicit waitlist position', () {
    final scheduledClass = _scheduledClass(waitlistPosition: 3);

    expect(scheduledClass.isWaitlisted, isTrue);
    expect(scheduledClass.waitlistDisplay, '#3 on Waitlist');
  });

  test('parses a waitlist position from the enrollment status', () {
    final scheduledClass = _scheduledClass(enrollmentStatus: 'Waitlisted 4');

    expect(scheduledClass.isWaitlisted, isTrue);
    expect(scheduledClass.waitlistDisplay, '#4 on Waitlist');
  });

  test('falls back to a generic waitlist label when no position is present', () {
    final scheduledClass = _scheduledClass(enrollmentStatus: 'Waitlisted');

    expect(scheduledClass.isWaitlisted, isTrue);
    expect(scheduledClass.waitlistDisplay, 'Waitlisted');
  });
}

ScheduledClass _scheduledClass({String? enrollmentStatus, int? waitlistPosition}) {
  final course = ClassData(
    subjectCode: 'CSE',
    courseCode: '110',
    enrollmentStatus: enrollmentStatus,
    waitlistPosition: waitlistPosition,
    sectionData: [SectionData(enrollStatus: enrollmentStatus)],
  );

  return ScheduledClass(course: course, section: course.sectionData!.first);
}
