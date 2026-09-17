import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/services/tss_exam_mapper.dart';
import 'package:campus_mobile_experimental/ui/finals/finals_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// MA-470 tss-finals-midterm START - exact booked exam join tests
void main() {
  test('maps FI and MI only when catalog event ID matches booked event ID', () {
    final result = classScheduleModelFromTssExams(
      bookingResponse: {
        'value': [
          {
            'moduleCode': 'VIS-001',
            'moduleName': 'Introduction to Art Making',
            'programTypeCode': 'UN',
            'bookingStatusCode': '1',
            'events': [
              {'eventId': 'E 00000239'},
            ],
          },
          {
            'moduleCode': 'COGS-001',
            'moduleName': 'Introduction to Cognitive Science',
            'programTypeCode': 'UN',
            'bookingStatusCode': '1',
            'events': [
              {'eventId': 'E 00000999'},
            ],
          },
        ],
      },
      eventsResponse: {
        'value': [
          {
            'eventId': 'E 00000114',
            'moduleCode': 'VIS-001',
            'eventCode': '001-000-LE',
            'meetingSchedule': [
              {'instructionType': 'FI', 'meetingDate': '2026-12-05', 'startTime': '08:00:00', 'endTime': '10:00:00'},
            ],
          },
          {
            'eventId': 'E 00000239',
            'moduleCode': 'VIS-001',
            'eventCode': '002-000-LE',
            'instructors': [
              {'instructorName': 'Test Instructor'},
            ],
            'meetingSchedule': [
              {
                'instructionType': 'FI',
                'meetingDate': '2026-12-07',
                'startTime': '11:00:00',
                'endTime': '13:00:00',
                'monday': true,
                'buildingName': 'Visual Arts Facility',
                'roomName': '100',
              },
            ],
          },
          {
            'eventId': 'E 00000999',
            'moduleCode': 'COGS-001',
            'eventCode': '001-000-LE',
            'meetingSchedule': [
              {'instructionType': 'MI', 'meetingDate': '2026-10-19', 'startTime': '09:30:00', 'endTime': '10:50:00'},
              {'instructionType': '', 'meetingDate': '2026-10-20', 'startTime': '09:30:00', 'endTime': '10:50:00'},
            ],
          },
        ],
      },
      termCode: 'FA26',
    );

    expect(result.data, hasLength(2));
    final finalExam = result.data!.first.sectionData!.single;
    expect(finalExam.specialMtgCode, 'FI');
    expect(finalExam.date, '2026-12-07');
    expect(finalExam.days, 'MO');
    expect(finalExam.time, '11:00 - 13:00');
    expect(finalExam.building, 'Visual Arts Facility');
    expect(finalExam.instructorName, 'Test Instructor');

    final midterm = result.data!.last.sectionData!.single;
    expect(midterm.specialMtgCode, 'MI');
    expect(midterm.date, '2026-10-19');
    expect(midterm.days, 'MO');
    expect(midterm.meetingType, 'Midterm');
  });

  test('deduplicates the same booked exam meeting', () {
    final response = {
      'value': [
        {
          'moduleCode': 'VIS-001',
          'moduleName': 'Introduction to Art Making',
          'bookingStatusCode': '1',
          'events': [
            {'eventId': 'E 00000239'},
          ],
        },
      ],
    };
    final event = {
      'eventId': 'E 00000239',
      'moduleCode': 'VIS-001',
      'meetingSchedule': [
        {'instructionType': 'FI', 'meetingDate': '2026-12-07', 'startTime': '11:00:00', 'endTime': '13:00:00'},
      ],
    };

    final result = classScheduleModelFromTssExams(
      bookingResponse: response,
      eventsResponse: {
        'value': [event, event],
      },
      termCode: 'FA26',
    );

    expect(result.data!.single.sectionData, hasLength(1));
  });

  test('rejects responses without OData value arrays', () {
    expect(
      () => classScheduleModelFromTssExams(bookingResponse: {}, eventsResponse: {'value': []}, termCode: 'FA26'),
      throwsFormatException,
    );
  });

  testWidgets('mapped Final renders in existing Finals content', (tester) async {
    final finalExam =
        SectionData(
            time: '11:00 - 13:00',
            days: 'MO',
            date: '2026-12-07',
            building: '',
            room: '',
            instructorName: 'TBA',
            specialMtgCode: 'FI',
          )
          ..subjectCode = 'VIS'
          ..courseCode = '001'
          ..courseTitle = 'Introduction to Art Making';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FinalsCard().buildFinalsCard(
              {
                'MO': [finalExam],
                'TU': <SectionData>[],
                'WE': <SectionData>[],
                'TH': <SectionData>[],
                'FR': <SectionData>[],
                'SA': <SectionData>[],
                'SU': <SectionData>[],
                'OTHER': <SectionData>[],
              },
              DateTime(2026, 9, 16),
              null,
              context,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('VIS 001'), findsOneWidget);
    expect(find.text('11:00 - 13:00'), findsOneWidget);
    expect(find.text('Introduction to Art Making'), findsOneWidget);
  });
}

// MA-470 tss-finals-midterm END - exact booked exam join tests
