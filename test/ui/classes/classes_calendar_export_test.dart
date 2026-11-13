import 'dart:async';
import 'dart:convert';
import 'dart:io' show Directory;

import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/scheduled_class.dart';
import 'package:campus_mobile_experimental/core/services/classes_calendar.dart';
import 'package:campus_mobile_experimental/ui/classes/classes_calendar_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Real plugin channels, mocked at the platform boundary:
// - flutter_file_dialog saveFile: {data, fileName, mimeTypesFilter} -> path or null
// - share_plus 11.1.0 share: {paths, mimeTypes} -> non-empty result string
const MethodChannel _saveChannel = MethodChannel('flutter_file_dialog');
const MethodChannel _shareChannel = MethodChannel('dev.fluttercommunity.plus/share');
const MethodChannel _pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final saveCalls = <MethodCall>[];
  final shareCalls = <MethodCall>[];

  void stubChannel(MethodChannel channel, Future<Object?>? Function(MethodCall call)? handler) =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, handler);

  setUp(() {
    saveCalls.clear();
    shareCalls.clear();
    stubChannel(_saveChannel, (call) async {
      saveCalls.add(call);
      return '/storage/emulated/0/Download/classes.ics';
    });
    stubChannel(_shareChannel, (call) async {
      shareCalls.add(call);
      return 'dev.fluttercommunity.plus/share/result/1';
    });
  });

  tearDown(() {
    stubChannel(_saveChannel, null);
    stubChannel(_shareChannel, null);
  });

  Future<void> pumpActions(WidgetTester tester, ClassCalendarData calendar) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: ClassCalendarExportActions(calendar: calendar)),
        ),
      ),
    );
  }

  testWidgets('blocks export and never opens a channel when there are no eligible meetings', (tester) async {
    final calendar = buildClassCalendar(null);
    expect(calendar.occurrences, isEmpty);

    await pumpActions(tester, calendar);
    expect(find.textContaining('No meetings'), findsOneWidget);

    await tester.tap(find.text('Save .ics'));
    await tester.tap(find.text('Share .ics'));
    await tester.pump();

    expect(saveCalls, isEmpty);
    expect(shareCalls, isEmpty);
  });

  testWidgets('save sends the .ics file name, calendar MIME type, and ICS bytes, then confirms the saved file', (
    tester,
  ) async {
    await pumpActions(tester, _populatedCalendar());

    await tester.tap(find.text('Save .ics'));
    await tester.pump();

    expect(saveCalls, hasLength(1));
    final args = saveCalls.single.arguments! as Map<Object?, Object?>;
    expect(args['fileName'], isA<String>());
    expect(args['fileName']! as String, endsWith('.ics'));
    expect((args['mimeTypesFilter']! as List).join(' '), contains('text/calendar'));

    final contents = utf8.decode(args['data']! as Uint8List);
    expect(contents, startsWith('BEGIN:VCALENDAR'));
    expect(contents, contains('BEGIN:VEVENT'));
    expect(contents, contains('CSE-100-A00'));
    expect(contents, contains('END:VCALENDAR'));

    expect(args['fileName'], 'classes-fall-2026.ics');
    expect(find.textContaining('Saved classes-fall-2026.ics'), findsOneWidget);
    expect(find.textContaining('classes-fall-2026.ics'), findsOneWidget);
    expect(find.textContaining('Unable to save'), findsNothing);
  });

  testWidgets('a cancelled save shows neither a success nor an error message', (tester) async {
    stubChannel(_saveChannel, (call) async {
      saveCalls.add(call);
      return null;
    });
    await pumpActions(tester, _populatedCalendar());

    await tester.tap(find.text('Save .ics'));
    await tester.pump();

    expect(saveCalls, hasLength(1));
    expect(find.textContaining('Saved '), findsNothing);
    expect(find.textContaining('Unable to save'), findsNothing);
  });

  testWidgets('a failed save shows an error and no saved confirmation', (tester) async {
    stubChannel(_saveChannel, (call) async {
      saveCalls.add(call);
      throw PlatformException(code: 'activity_not_found');
    });
    await pumpActions(tester, _populatedCalendar());

    await tester.tap(find.text('Save .ics'));
    await tester.pump();

    expect(find.textContaining('Unable to save'), findsOneWidget);
    expect(find.textContaining('Saved '), findsNothing);
  });

  testWidgets('share hands the .ics file to the OS, anchors the sheet, and never claims an import', (tester) async {
    Directory? shareTempDir;
    stubChannel(_pathProviderChannel, (call) async {
      if (call.method == 'getTemporaryDirectory') return shareTempDir!.path;
      return null;
    });
    await tester.runAsync(() async {
      shareTempDir = await Directory.systemTemp.createTemp('classes_ics_share');
    });
    addTearDown(
      () => tester.runAsync(() async {
        if (shareTempDir != null && await shareTempDir!.exists()) {
          await shareTempDir!.delete(recursive: true);
        }
      }),
    );
    await pumpActions(tester, _populatedCalendar());

    await tester.runAsync(() async {
      await tester.tap(find.text('Share .ics'));
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (shareCalls.isEmpty && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    await tester.pump();

    expect(shareCalls, hasLength(1));
    expect(shareCalls.single.method, 'share');
    final args = shareCalls.single.arguments! as Map<Object?, Object?>;
    expect((args['paths']! as List).first, endsWith('.ics'));
    expect((args['mimeTypes']! as List).first, 'text/calendar');
    expect(args['originWidth'], isA<num>());
    expect((args['originWidth']! as num) > 0, isTrue);
    expect(args['originHeight'], isA<num>());
    expect((args['originHeight']! as num) > 0, isTrue);

    expect(find.textContaining('Imported'), findsNothing);
    expect(find.textContaining('imported'), findsNothing);
    expect(saveCalls, isEmpty);
  });

  testWidgets('ignores extra taps while a save is still pending', (tester) async {
    final pending = Completer<Object?>();
    stubChannel(_saveChannel, (call) async {
      saveCalls.add(call);
      return pending.future;
    });
    await pumpActions(tester, _populatedCalendar());

    await tester.tap(find.text('Save .ics'));
    await tester.pump();
    await tester.tap(find.text('Save .ics'));
    await tester.pump();
    expect(saveCalls, hasLength(1));

    pending.complete('/storage/emulated/0/Download/classes.ics');
    await tester.pump();
    expect(find.textContaining('Saved classes-fall-2026.ics'), findsOneWidget);
  });

  testWidgets('warns about partially omitted meetings and names them', (tester) async {
    await pumpActions(tester, _populatedCalendar(omissions: ['CSE 100 lecture (no reliable date)']));

    expect(find.textContaining('could not be exported'), findsOneWidget);
    expect(find.textContaining('CSE 100 lecture'), findsOneWidget);
  });

  testWidgets('lists undated meetings in the warning while dated meetings stay exportable', (tester) async {
    await pumpActions(tester, _populatedCalendar(undated: [_undatedMeeting()]));

    expect(find.textContaining('could not be exported'), findsOneWidget);
    expect(find.textContaining('CSE 100 LE'), findsOneWidget);
    expect(find.text('Save .ics'), findsOneWidget);
    expect(tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Save .ics')).onPressed, isNotNull);
  });

  testWidgets('import instructions cover Google web, Apple Mac, Outlook web, and the snapshot warning', (tester) async {
    await pumpActions(tester, _populatedCalendar());

    await tester.tap(find.text('Import instructions'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Google Calendar'), findsOneWidget);
    expect(find.textContaining('calendar.google.com'), findsOneWidget);
    expect(find.textContaining('Apple Calendar'), findsOneWidget);
    expect(find.textContaining('Outlook'), findsOneWidget);
    expect(find.textContaining('outlook.live.com'), findsOneWidget);
    expect(find.textContaining('snapshot'), findsOneWidget);
    expect(find.textContaining('re-export'), findsOneWidget);
    expect(find.textContaining('duplicate'), findsOneWidget);
  });
}

ClassCalendarData _populatedCalendar({List<String> omissions = const [], List<ScheduledClass> undated = const []}) {
  final course = ClassData(
    termCode: 'FA26',
    subjectCode: 'CSE',
    courseCode: '100',
    courseTitle: 'Advanced Data Structures',
  );
  final section = SectionData(
    section: 'A00',
    sectionCode: '80000',
    meetingType: 'LE',
    days: 'TU',
    time: '08:00-09:20',
    building: 'CSE',
    room: '1202',
  );
  return ClassCalendarData(
    quarter: ClassCalendarQuarter(
      termCode: 'FA26',
      label: 'Fall 2026',
      start: DateTime.utc(2026, 9, 21),
      end: DateTime.utc(2026, 12, 12),
      instructionStart: DateTime.utc(2026, 9, 24),
      instructionEnd: DateTime.utc(2026, 12, 4),
    ),
    occurrences: [
      ClassOccurrence(
        scheduledClass: ScheduledClass(course: course, section: section),
        date: DateTime.utc(2026, 9, 29),
        start: DateTime.utc(2026, 9, 29, 15),
        end: DateTime.utc(2026, 9, 29, 16, 20),
        isAllDay: false,
        courseKey: 'CSE 100',
        uid: 'CSE-100-A00-2026-09-29@campus-mobile',
      ),
    ],
    undated: undated,
    omissions: omissions,
  );
}

ScheduledClass _undatedMeeting() => ScheduledClass(
  course: ClassData(termCode: 'FA26', subjectCode: 'CSE', courseCode: '100', courseTitle: 'Advanced Data Structures'),
  section: SectionData(section: 'B00', sectionCode: '90001', meetingType: 'LE', days: 'TH'),
);
