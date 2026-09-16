import 'package:campus_mobile_experimental/core/services/tss_booking_mapper.dart';
import 'package:campus_mobile_experimental/ui/common/time_range_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// MA-470 tss-classes START - Booking to Classes mapping tests
void main() {
  test('maps booked undergraduate and graduate rows without career filtering', () {
    final result = classScheduleModelFromTssBooking({
      'value': [
        {
          'moduleCode': 'MATH-010A',
          'moduleName': 'Calculus I',
          'programTypeCode': 'UN',
          'bookingStatusCode': '1',
          'creditsAttempted': 4,
          'appraisalTemplateName': 'Letter Grade',
          'grade': {'finalGrade': ''},
          'events': [
            {
              'eventCode': '003-001-DI',
              'instructionType': 'DI',
              'instructors': [],
              'meetings': [
                {
                  'startTime': '14:00:00',
                  'endTime': '15:00:00',
                  'tuesday': true,
                  'thursday': true,
                  'buildingName': '',
                  'roomName': '',
                },
              ],
            },
          ],
        },
        {
          'moduleCode': 'VIS-199',
          'moduleName': 'Special Studies',
          'programTypeCode': 'GR',
          'bookingStatusCode': '1',
          'creditsAttempted': 2.0,
          'events': [],
        },
        {'moduleCode': 'CHEM-001', 'bookingStatusCode': '2', 'events': []},
      ],
    }, 'SP26');

    expect(result.data, hasLength(2));
    expect(result.data![0].subjectCode, 'MATH');
    expect(result.data![0].courseCode, '010A');
    expect(result.data![0].units, 4.0);
    expect(result.data![0].gradeOption, 'L');
    expect(result.data![0].enrollmentStatus, 'EN');
    expect(result.data![0].sectionData!.map((s) => s.days), ['TU', 'TH']);
    expect(result.data![0].sectionData!.first.time, '14:00 - 15:00');
    expect(result.data![0].sectionData!.first.instructorName, 'TBA');
    expect(result.data![0].sectionData!.first.specialMtgCode, isNull);
    expect(result.data![1].courseLevel, 'GR');
    expect(result.data![1].sectionData, isEmpty);
  });

  test('rejects a response without the OData value array', () {
    expect(() => classScheduleModelFromTssBooking({}, 'FA26'), throwsFormatException);
  });

  testWidgets('mapped time renders in the existing Classes time widget', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TimeRangeWidget(time: '14:00 - 15:00')),
      ),
    );
    expect(find.text('2:00 PM - 3:00 PM'), findsOneWidget);
  });
}

// MA-470 tss-classes END - Booking to Classes mapping tests
