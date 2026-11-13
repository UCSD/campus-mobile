import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/scheduled_class.dart';
import 'package:campus_mobile_experimental/core/providers/classes.dart';
import 'package:campus_mobile_experimental/ui/classes/classes_calendar.dart';
import 'package:campus_mobile_experimental/ui/classes/classes_calendar_export.dart';
import 'package:campus_mobile_experimental/ui/classes/classes_list.dart';
import 'package:campus_mobile_experimental/ui/navigator/top.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final SectionData _lectureSection = SectionData(
  section: 'A00',
  sectionCode: '90001',
  meetingType: 'Lecture',
  days: 'MO',
  time: '10:00-10:50',
  building: 'CENTER',
  room: '101',
  instructorName: 'Jones',
);

final ClassData _lectureCourse = ClassData(
  termCode: 'FA26',
  subjectCode: 'CSE',
  courseCode: '100',
  courseTitle: 'Advanced Data Structures',
  enrollmentStatus: 'Booked',
  gradeOption: 'L',
  sectionData: [_lectureSection],
);

final SectionData _midtermSection = SectionData(
  section: 'A00',
  sectionCode: '90002',
  meetingType: 'Midterm',
  specialMtgCode: 'MI',
  days: 'TH',
  date: '2026-12-10',
  building: 'CENTER',
  room: '101',
  instructorName: 'Jones',
);

final ClassData _midtermCourse = ClassData(
  termCode: 'FA26',
  subjectCode: 'CSE',
  courseCode: '101',
  courseTitle: 'Systems Programming',
  enrollmentStatus: 'Booked',
  gradeOption: 'L',
  sectionData: [_midtermSection],
);

final SectionData _undatedSection = SectionData(
  section: 'D00',
  sectionCode: '90003',
  meetingType: 'Lab',
  instructorName: 'Park',
);

final ClassData _undatedCourse = ClassData(
  termCode: 'FA26',
  subjectCode: 'CHEM',
  courseCode: '6',
  courseTitle: 'General Chemistry Lab',
  enrollmentStatus: 'Booked',
  gradeOption: 'P',
  sectionData: [_undatedSection],
);

final SectionData _badDateSection = SectionData(
  section: 'H00',
  sectionCode: '90004',
  meetingType: 'Lecture',
  date: 'not-a-date',
  building: 'CENTER',
  room: '105',
  instructorName: 'Nguyen',
);

final ClassData _badDateCourse = ClassData(
  termCode: 'FA26',
  subjectCode: 'PHYS',
  courseCode: '2',
  courseTitle: 'Classical Mechanics',
  enrollmentStatus: 'Booked',
  gradeOption: 'L',
  sectionData: [_badDateSection],
);

final RegExp _agendaHeadingPattern = RegExp(
  r'^(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday), \S+ \d{1,2}, \d{4}$',
);

void main() {
  // Keep semantics enabled for the whole suite; per-test handles leak past
  // the end-of-test verification in this Flutter version.
  TestWidgetsFlutterBinding.ensureInitialized();
  TestWidgetsFlutterBinding.instance.ensureSemantics();

  testWidgets('defaults to the list view on each visit', (tester) async {
    await _pump(tester, _fakeProvider());
    expect(find.text('CSE 100'), findsWidgets);
    expect(find.byType(ClassesCalendar), findsNothing);

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.byType(ClassesCalendar), findsOneWidget);

    // A fresh visit mounts with the list selected again.
    await _pump(tester, _fakeProvider());
    expect(find.text('CSE 100'), findsWidgets);
    expect(find.byType(ClassesCalendar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the selected date and month when toggling between views', (tester) async {
    await _pump(tester, _fakeProvider());
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    final headingBefore = _agendaHeading(tester);

    // Move back one month when the control is enabled so the check also
    // covers the displayed month, not just the selected date.
    final previousTooltip = find.byTooltip('Previous month');
    if (previousTooltip.evaluate().isNotEmpty) {
      final button = tester.widget<IconButton>(
        find.ancestor(of: previousTooltip, matching: find.byType(IconButton)).first,
      );
      if (button.onPressed != null) {
        await tester.tap(previousTooltip);
        await tester.pumpAndSettle();
        final selectedDate = DateFormat('EEEE, MMMM d, y').parseStrict(headingBefore);
        final previousMonth = DateTime(selectedDate.year, selectedDate.month - 1, 1);
        expect(
          find.bySemanticsLabel(RegExp('${DateFormat('MMMM').format(previousMonth)} 1, ${previousMonth.year}')),
          findsWidgets,
        );
      }
    }

    final headingAfterNavigation = _agendaHeading(tester);
    await tester.tap(find.text('List'));
    await tester.pumpAndSettle();
    expect(find.text(headingAfterNavigation), findsNothing);

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.text(headingAfterNavigation), findsOneWidget);
    expect(_agendaHeading(tester), headingAfterNavigation);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not modify provider weekday maps when rendering the list', (tester) async {
    final provider = _fakeProvider();
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pump(tester, provider);

    expect(provider.enrolledClasses['MI'], isNull);
    expect(provider.enrolledClasses['MO'], hasLength(1));
    expect(provider.enrolledClasses['OTHER'], hasLength(1));
    expect(provider.midterms['MI'], hasLength(1));
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('Midterms'), findsOneWidget);
    expect(find.text('CHEM 6'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the export header from consuming the screen at large text', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = _FakeClassScheduleDataProvider(
      ClassScheduleModel(data: [_lectureCourse, _badDateCourse]),
      {
        'MO': [ScheduledClass(course: _lectureCourse, section: _lectureSection)],
        'OTHER': [ScheduledClass(course: _undatedCourse, section: _undatedSection)],
      },
      {
        'MI': [ScheduledClass(course: _midtermCourse, section: _midtermSection)],
        'OTHER': <ScheduledClass>[],
      },
    );
    await _pump(tester, provider, textScale: 2.0);
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('could not be exported'), findsWidgets);
    expect(find.text('Share .ics'), findsOneWidget);
    expect(find.textContaining(RegExp('Fall', caseSensitive: false)), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows calendar export actions from both list and calendar views', (tester) async {
    await _pump(tester, _fakeProvider());
    expect(find.byType(ClassCalendarExportActions), findsOneWidget);

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.byType(ClassCalendarExportActions), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('handles a missing schedule without crashing', (tester) async {
    await _pump(tester, _emptyProvider());
    expect(find.text('CSE 100'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.textContaining(RegExp('unavailable', caseSensitive: false)), findsWidgets);

    // List stays available when academic dates are unavailable.
    await tester.tap(find.text('List'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pump(WidgetTester tester, _FakeClassScheduleDataProvider provider, {double textScale = 1.0}) async {
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    provider.dispose();
  });
  // Replace the whole tree so repeated pumps in one test always mount a
  // fresh ClassList instead of reusing the previous element state.
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ClassScheduleDataProvider>.value(value: provider),
        ChangeNotifierProvider<CustomAppBar>.value(value: CustomAppBar()),
      ],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: ClassList(),
      ),
    ),
  );
}

String _agendaHeading(WidgetTester tester) {
  final headings = tester
      .widgetList<Text>(find.byType(Text))
      .map((text) => text.data)
      .whereType<String>()
      .where(_agendaHeadingPattern.hasMatch)
      .toList();
  return headings.single;
}

class _FakeClassScheduleDataProvider extends ClassScheduleDataProvider {
  _FakeClassScheduleDataProvider(this._schedule, this._enrolled, this._midtermBuckets);

  final ClassScheduleModel? _schedule;
  final Map<String, List<ScheduledClass>> _enrolled;
  final Map<String, List<ScheduledClass>> _midtermBuckets;

  @override
  ClassScheduleModel? get calendarSchedule => _schedule;

  @override
  Map<String, List<ScheduledClass>> get enrolledClasses => _enrolled;

  @override
  Map<String, List<ScheduledClass>> get midterms => _midtermBuckets;
}

_FakeClassScheduleDataProvider _fakeProvider() {
  final lecture = ScheduledClass(course: _lectureCourse, section: _lectureSection);
  final midterm = ScheduledClass(course: _midtermCourse, section: _midtermSection);
  final undated = ScheduledClass(course: _undatedCourse, section: _undatedSection);
  return _FakeClassScheduleDataProvider(
    ClassScheduleModel(data: [_lectureCourse]),
    {
      'MO': [lecture],
      'OTHER': [undated],
    },
    {
      'MI': [midterm],
      'OTHER': [],
    },
  );
}

_FakeClassScheduleDataProvider _emptyProvider() =>
    _FakeClassScheduleDataProvider(null, {'MO': <ScheduledClass>[]}, {'MI': <ScheduledClass>[]});
