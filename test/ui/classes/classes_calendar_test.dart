import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/scheduled_class.dart';
import 'package:campus_mobile_experimental/core/services/classes_calendar.dart';
import 'package:campus_mobile_experimental/ui/classes/classes_calendar.dart';
import 'package:campus_mobile_experimental/ui/classes/class_schedule_card.dart';
import 'package:campus_mobile_experimental/ui/common/time_range_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

// Synthetic test colors only. Production colors come from the linked Figma
// frame and are intentionally not invented here.
const List<Color> _courseColors = [
  Color(0xFF00629B),
  Color(0xFFFFCD00),
  Color(0xFF03A9F4),
  Color(0xFF182B49),
  Color(0xFFC69214),
];

final DateFormat _fullDate = DateFormat('EEEE, MMMM d, y');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Use the app's actual fonts so narrow-screen and large-text checks are
    // realistic.
    // Keep semantics enabled for the whole suite so bySemanticsLabel finders
    // work without leaking per-test handles.
    TestWidgetsFlutterBinding.instance.ensureSemantics();
    final bodyFonts = FontLoader('Brix Sans')
      ..addFont(rootBundle.load('assets/fonts/HVD Fonts - BrixSansMedium.otf'))
      ..addFont(rootBundle.load('assets/fonts/HVD Fonts - BrixSansBold.otf'))
      ..addFont(rootBundle.load('assets/fonts/HVD Fonts - BrixSansRegular.otf'));
    final headingFonts = FontLoader('Refrigerator Deluxe')
      ..addFont(rootBundle.load('assets/fonts/Refrigerator Deluxe Bold.otf'));
    await bodyFonts.load();
    await headingFonts.load();
  });

  testWidgets('builds calendar data from canonical class records', (tester) async {
    final calendar = await _pumpCalendar(tester, model: _baseSchedule());
    final quarter = calendar.quarter;

    expect(quarter, isNotNull);
    expect(quarter!.termCode, 'FA26');
    expect(quarter.label.toLowerCase(), contains('fall'));
    expect(quarter.label, contains('2026'));
    expect(_isSameDay(quarter.start, 2026, 9, 21), isTrue);
    expect(_isSameDay(quarter.end, 2026, 12, 12), isTrue);
    expect(_isSameDay(quarter.instructionStart, 2026, 9, 24), isTrue);
    expect(_isSameDay(quarter.instructionEnd, 2026, 12, 4), isTrue);

    final monday = calendar.meetingsOn(DateTime(2026, 11, 2));
    expect(monday, hasLength(3));
    final mondayCourseCodes = monday.map((occurrence) => occurrence.scheduledClass.courseCode).toList();
    expect(mondayCourseCodes.where((code) => code == '100'), hasLength(2));
    expect(mondayCourseCodes.where((code) => code == '20A'), hasLength(1));
    for (final occurrence in monday) {
      expect(occurrence.isAllDay, isFalse);
      expect(occurrence.start, isNotNull);
      expect(occurrence.end, isNotNull);
      expect(occurrence.uid, isNotEmpty);
      expect(occurrence.courseKey, isNotEmpty);
    }

    final datedTba = calendar.meetingsOn(DateTime(2026, 11, 5));
    expect(datedTba, hasLength(1));
    expect(datedTba.single.isAllDay, isTrue);
    expect(datedTba.single.start, isNull);
    expect(datedTba.single.end, isNull);
    expect(_isSameDay(datedTba.single.date, 2026, 11, 5), isTrue);

    expect(calendar.meetingsOn(DateTime(2026, 11, 14)), isEmpty);
    final uids = calendar.occurrences.map((occurrence) => occurrence.uid).toSet();
    expect(uids.length, calendar.occurrences.length);

    expect(calendar.undated, hasLength(1));
    expect(calendar.undated.single.course.subjectCode, 'CHEM');
    expect(calendar.undated.single.course.courseCode, '6');
    // Undated records are tracked separately; only invalid records are
    // reported as omissions, and this fixture has none.
    expect(calendar.omissions, isEmpty);
  });

  testWidgets('renders a Sunday-first, fixed six-row month grid', (tester) async {
    await _pumpCalendar(tester, model: _baseSchedule());

    // Six rows of seven columns: 30 November dates plus 12 trailing
    // December dates, with no October or late-December dates shown.
    for (var day = 1; day <= 30; day++) {
      expect(find.bySemanticsLabel(RegExp('November $day, 2026')), findsWidgets, reason: 'November $day');
    }
    for (var day = 1; day <= 12; day++) {
      expect(find.bySemanticsLabel(RegExp('December $day, 2026')), findsWidgets, reason: 'December $day');
    }
    expect(find.bySemanticsLabel(RegExp('October 25, 2026')), findsNothing);
    expect(find.bySemanticsLabel(RegExp('October 31, 2026')), findsNothing);
    expect(find.bySemanticsLabel(RegExp('December 13, 2026')), findsNothing);
    expect(find.bySemanticsLabel(RegExp('January 1, 2027')), findsNothing);

    // November 1, 2026 is a Sunday and starts the grid's first column.
    final first = tester.getRect(find.bySemanticsLabel(RegExp('November 1, 2026')));
    final second = tester.getRect(find.bySemanticsLabel(RegExp('November 2, 2026')));
    final lastOfWeek = tester.getRect(find.bySemanticsLabel(RegExp('November 7, 2026')));
    final nextSunday = tester.getRect(find.bySemanticsLabel(RegExp('November 8, 2026')));
    final lastSunday = tester.getRect(find.bySemanticsLabel(RegExp('November 29, 2026')));
    final sixthRowSaturday = tester.getRect(find.bySemanticsLabel(RegExp('December 12, 2026')));

    expect(first.top, closeTo(second.top, 0.5));
    expect(first.top, closeTo(lastOfWeek.top, 0.5));
    expect(first.left, lessThan(second.left));
    expect(first.left, closeTo(nextSunday.left, 0.5));
    expect(nextSunday.top, greaterThan(first.top));
    expect(lastSunday.top, lessThan(sixthRowSaturday.top));
    expect(sixthRowSaturday.left, greaterThan(lastSunday.left));
    expect(tester.takeException(), isNull);
  });

  testWidgets('selects today inside the quarter even on an empty day', (tester) async {
    final calendar = await _pumpCalendar(tester, model: _baseSchedule());

    expect(calendar.meetingsOn(DateTime(2026, 11, 14)), isEmpty);
    expect(find.text('Saturday, November 14, 2026'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Saturday, November 14, 2026')), findsWidgets);
    expect(
      find.bySemanticsLabel(RegExp('selected.*november 14, 2026|november 14, 2026.*selected', caseSensitive: false)),
      findsWidgets,
    );
    expect(
      find.bySemanticsLabel(RegExp('today.*november 14, 2026|november 14, 2026.*today', caseSensitive: false)),
      findsWidgets,
    );
    expect(
      find.bySemanticsLabel(
        RegExp('no meetings.*november 14, 2026|november 14, 2026.*no meetings', caseSensitive: false),
      ),
      findsWidgets,
    );
    expect(find.textContaining(RegExp('no meetings', caseSensitive: false)), findsWidgets);
    expect(find.text('CSE 100'), findsNothing);
    expect(find.text('MATH 20A'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('initially selects the first eligible meeting when today is outside the quarter', (tester) async {
    final calendar = await _pumpCalendar(tester, model: _baseSchedule(), now: DateTime.utc(2026, 12, 20, 20));
    final first = calendar.occurrences.first;

    expect(_isSameDay(first.date, 2026, 9, 25), isTrue);
    expect(find.text(_fullDate.format(first.date)), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('September 25, 2026')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('October 25, 2026')), findsNothing);
    expect(find.text(_fullDate.format(DateTime(2026, 12, 20))), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bounds month navigation to the loaded quarter and supports Today', (tester) async {
    await _pumpCalendar(tester, model: _baseSchedule());

    await tester.tap(_control('Next month').first);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('December 1, 2026')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('November 8, 2026')), findsNothing);

    await tester.tap(_control('Next month').first);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('December 31, 2026')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('January 10, 2027')), findsNothing);

    final next = _control('Next month');
    if (next.evaluate().isNotEmpty) {
      await tester.tap(next.first);
      await tester.pumpAndSettle();
    }
    expect(find.bySemanticsLabel(RegExp('December 31, 2026')), findsWidgets);

    await tester.tap(_control('Previous month').first);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('November 8, 2026')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('December 31, 2026')), findsNothing);

    await tester.tap(_control('Previous month').first);
    await tester.pumpAndSettle();
    await tester.tap(_control('Previous month').first);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('September 1, 2026')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('October 25, 2026')), findsNothing);

    final previous = _control('Previous month');
    if (previous.evaluate().isNotEmpty) {
      await tester.tap(previous.first);
      await tester.pumpAndSettle();
    }
    expect(find.bySemanticsLabel(RegExp('September 30, 2026')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('August 20, 2026')), findsNothing);

    await tester.tap(_control('Today').first);
    await tester.pumpAndSettle();
    expect(find.text('Saturday, November 14, 2026'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('November 8, 2026')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('December 31, 2026')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clamps the selected day when navigating to a shorter month', (tester) async {
    await _pumpCalendar(tester, model: _baseSchedule());

    await tester.tap(_control('Previous month').first);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel(RegExp('Saturday, October 31, 2026')));
    await tester.pumpAndSettle();
    expect(find.text('Saturday, October 31, 2026'), findsOneWidget);

    await tester.tap(_control('Next month').first);
    await tester.pumpAndSettle();
    expect(find.text('Monday, November 30, 2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clamps the selection to the quarter end when navigating forward', (tester) async {
    await _pumpCalendar(tester, model: _baseSchedule());

    await tester.tap(_control('Next month').first);
    await tester.pumpAndSettle();
    expect(find.text('Saturday, December 12, 2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('announces neighboring-month dates but does not allow selecting them', (tester) async {
    await _pumpCalendar(tester, model: _baseSchedule());

    expect(find.bySemanticsLabel(RegExp('December 8, 2026')), findsWidgets);
    await tester.ensureVisible(find.bySemanticsLabel(RegExp('December 8, 2026')));
    await tester.tap(find.bySemanticsLabel(RegExp('December 8, 2026')));
    await tester.pumpAndSettle();
    expect(find.text('Saturday, November 14, 2026'), findsOneWidget);

    await tester.tap(_control('Previous month').first);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('September 28, 2026')), findsWidgets);
    // Navigation may preserve the day number and move the selection to
    // October 14, so do not require a specific selected date here; the tap
    // must not select the neighboring September 28.
    expect(find.text('Monday, September 28, 2026'), findsNothing);
    await tester.tap(find.bySemanticsLabel(RegExp('September 28, 2026')));
    await tester.pumpAndSettle();
    expect(find.text('Monday, September 28, 2026'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows each section once on the same day with one marker per course', (tester) async {
    final calendar = await _pumpCalendar(tester, model: _baseSchedule());

    expect(calendar.meetingsOn(DateTime(2026, 11, 2)), hasLength(3));
    await tester.tap(find.bySemanticsLabel(RegExp('Monday, November 2, 2026')));
    await tester.pumpAndSettle();

    expect(find.text('Monday, November 2, 2026'), findsOneWidget);
    expect(find.text('CSE 100'), findsNWidgets(2));
    expect(find.text('MATH 20A'), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => _hasColor(widget, _courseColors[0])), findsWidgets);
    expect(find.byWidgetPredicate((widget) => _hasColor(widget, _courseColors[1])), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('3 meetings')), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows course overflow as +N on a crowded day', (tester) async {
    final calendar = await _pumpCalendar(tester, model: _busySchedule());

    expect(calendar.meetingsOn(DateTime(2026, 11, 12)), hasLength(5));
    expect(find.textContaining(RegExp(r'\+\d')), findsWidgets);
    expect(find.byWidgetPredicate((widget) => _hasColor(widget, _courseColors[0])), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps each course marker color stable across days with different subsets', (tester) async {
    await _pumpCalendar(tester, model: _colorStabilitySchedule());

    final monday = find.bySemanticsLabel(RegExp('Monday, November 2, 2026'));
    final tuesday = find.bySemanticsLabel(RegExp('Tuesday, November 3, 2026'));
    // Courses sort globally (ANTH < BIOL < CHEM), so each course keeps its
    // palette index no matter which subset of courses meets on a given day.
    expect(_dotsIn(monday, _courseColors[0]), findsWidgets);
    expect(_dotsIn(monday, _courseColors[1]), findsNothing);
    expect(_dotsIn(tuesday, _courseColors[0]), findsNothing);
    expect(_dotsIn(tuesday, _courseColors[1]), findsWidgets);
    expect(_dotsIn(tuesday, _courseColors[2]), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exposes selected, button, and enabled flags on date cells', (tester) async {
    await _pumpCalendar(tester, model: _baseSchedule());

    final selectedCell = _cellSemantics(tester, 'Saturday, November 14, 2026, Selected').properties;
    expect(selectedCell.selected, isTrue);
    expect(selectedCell.enabled, isTrue);

    final selectableCell = _cellSemantics(tester, 'Friday, November 13, 2026').properties;
    expect(selectableCell.button, isTrue);
    expect(selectableCell.enabled, isTrue);
    expect(find.bySemanticsLabel(RegExp('Friday, November 13, 2026')), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(RegExp('Friday, November 13, 2026')));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('Friday, November 13, 2026, Selected')), findsOneWidget);

    final neighborCell = _cellSemantics(tester, 'Tuesday, December 8, 2026').properties;
    expect(neighborCell.selected, isFalse);
    expect(neighborCell.enabled, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders full informational agenda cards without tap actions', (tester) async {
    await _pumpCalendar(tester, model: _baseSchedule());

    await tester.tap(find.bySemanticsLabel(RegExp('Monday, November 2, 2026')));
    await tester.pumpAndSettle();

    expect(find.text('CSE 100'), findsNWidgets(2));
    expect(find.text('Advanced Data Structures'), findsNWidgets(2));
    expect(find.textContaining('Jones'), findsWidgets);
    expect(find.textContaining('CENTER 101'), findsWidgets);
    expect(find.textContaining(RegExp('10:00')), findsWidgets);
    expect(find.text('Discussion'), findsOneWidget);

    await tester.tap(find.text('Advanced Data Structures').first);
    await tester.pumpAndSettle();
    expect(find.text('CSE 100'), findsNWidgets(2));
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('groups dated TBA meetings on their day and undated meetings once', (tester) async {
    await _pumpCalendar(tester, model: _baseSchedule());

    await tester.tap(find.bySemanticsLabel(RegExp('Thursday, November 5, 2026')));
    await tester.pumpAndSettle();
    expect(find.text('Thursday, November 5, 2026'), findsOneWidget);
    expect(find.text('PHIL 10'), findsWidgets);
    expect(find.text('All-day / TBA'), findsOneWidget);
    expect(find.textContaining(RegExp('all day|TBA', caseSensitive: false)), findsWidgets);

    expect(find.text('CHEM 6'), findsOneWidget);
    expect(find.textContaining(RegExp('undated|no date', caseSensitive: false)), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('1 meeting')), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders invalid time ranges as TBA', (tester) async {
    final invalidNumbers = ScheduledClass(
      course: _course(subject: 'CSE', code: '100', title: 'Advanced Data Structures', sections: []),
      section: _section(
        section: 'A00',
        sectionCode: '93001',
        time: '99:99-99:99',
        building: 'CENTER',
        room: '101',
        instructor: 'Jones',
      ),
    );
    final reversedRange = ScheduledClass(
      course: _course(subject: 'MATH', code: '20A', title: 'Calculus I', sections: []),
      section: _section(
        section: 'B00',
        sectionCode: '93002',
        time: '14:00-10:00',
        building: 'AP&M',
        room: '2401',
        instructor: 'Lee',
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ClassSectionCard(scheduledClass: invalidNumbers),
              ClassSectionCard(scheduledClass: reversedRange),
            ],
          ),
        ),
      ),
    );
    expect(find.text('TBA'), findsNWidgets(2));
    expect(find.byType(TimeRangeWidget), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('excludes exam sections from the calendar', (tester) async {
    final calendar = await _pumpCalendar(tester, model: _finalExamSchedule());

    expect(calendar.meetingsOn(DateTime(2026, 12, 10)), isEmpty);
    expect(find.textContaining(RegExp('final', caseSensitive: false)), findsNothing);
    expect(find.bySemanticsLabel(RegExp('December 10, 2026')), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('explains an unsupported term', (tester) async {
    await _pumpCalendar(tester, model: _baseSchedule(termCode: 'SU26'));

    expect(find.textContaining(RegExp('unavailable', caseSensitive: false)), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('November 14, 2026')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selects today and shows the empty state for a quarter with no eligible meetings', (tester) async {
    await _pumpCalendar(tester, model: _emptyQuarterSchedule());

    expect(find.text('Saturday, November 14, 2026'), findsOneWidget);
    expect(find.textContaining(RegExp('no meetings', caseSensitive: false)), findsWidgets);
    expect(find.textContaining(RegExp('Fall', caseSensitive: false)), findsWidgets);
    expect(find.text('CSE 100'), findsNothing);
    expect(find.bySemanticsLabel(RegExp('November 14, 2026')), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('handles a missing schedule without crashing', (tester) async {
    final calendar = buildClassCalendar(null);
    expect(calendar.quarter, isNull);
    expect(calendar.occurrences, isEmpty);
    expect(calendar.undated, isEmpty);

    await _pumpCalendar(tester, model: null);
    expect(find.textContaining(RegExp('unavailable|no meetings', caseSensitive: false)), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('calendar fits a 360px screen in ${brightness.name} mode at ${scale}x text', (tester) async {
        await _pumpCalendar(tester, model: _baseSchedule(), brightness: brightness, textScale: scale);
        expect(find.text('Saturday, November 14, 2026'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

Future<ClassCalendarData> _pumpCalendar(
  WidgetTester tester, {
  ClassScheduleModel? model,
  DateTime? now,
  Brightness brightness = Brightness.light,
  double textScale = 1.0,
  Size size = const Size(360, 900),
}) async {
  final calendar = buildClassCalendar(model);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: false, brightness: brightness, fontFamily: 'Brix Sans'),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: ClassesCalendar(
            calendar: calendar,
            courseColors: _courseColors,
            now: now ?? DateTime.utc(2026, 11, 14, 20),
          ),
        ),
      ),
    ),
  );
  return calendar;
}

Finder _control(String label) => find.byWidgetPredicate(
  (widget) => (widget is Tooltip && widget.message == label) || (widget is Text && widget.data == label),
);

bool _hasColor(Widget widget, Color color) {
  if (widget is Container) {
    if (widget.color == color) return true;
    final decoration = widget.decoration;
    return decoration is BoxDecoration && decoration.color == color;
  }
  if (widget is DecoratedBox) {
    final decoration = widget.decoration;
    return decoration is BoxDecoration && decoration.color == color;
  }
  return false;
}

bool _isSameDay(DateTime actual, int year, int month, int day) =>
    actual.year == year && actual.month == month && actual.day == day;

Finder _dotsIn(Finder cell, Color color) =>
    find.descendant(of: cell, matching: find.byWidgetPredicate((widget) => _hasColor(widget, color)));

Semantics _cellSemantics(WidgetTester tester, String labelPart) => tester
    .widgetList<Semantics>(find.byType(Semantics))
    .where((semantics) => (semantics.properties.label ?? '').contains(labelPart))
    .single;

ClassScheduleModel _baseSchedule({String termCode = 'FA26'}) => ClassScheduleModel(
  data: [
    _course(
      termCode: termCode,
      subject: 'CSE',
      code: '100',
      title: 'Advanced Data Structures',
      sections: [
        _section(
          section: 'A00',
          sectionCode: '90001',
          meetingType: 'Lecture',
          days: 'MO WE FR',
          time: '10:00-10:50',
          building: 'CENTER',
          room: '101',
          instructor: 'Jones',
        ),
        _section(
          section: 'A01',
          sectionCode: '90002',
          meetingType: 'Discussion',
          days: 'MO',
          time: '14:00-14:50',
          building: 'CENTER',
          room: '220',
          instructor: 'Garcia',
        ),
      ],
    ),
    _course(
      termCode: termCode,
      subject: 'MATH',
      code: '20A',
      title: 'Calculus I',
      sections: [
        _section(
          section: 'B00',
          sectionCode: '90003',
          days: 'MO',
          time: '08:00-08:50',
          building: 'AP&M',
          room: '2401',
          instructor: 'Lee',
        ),
      ],
    ),
    _course(
      termCode: termCode,
      subject: 'PHIL',
      code: '10',
      title: 'Introduction to Ethics',
      gradeOption: 'P',
      sections: [
        _section(
          section: 'C00',
          sectionCode: '90004',
          meetingType: 'Seminar',
          date: '2026-11-05',
          building: 'HSS',
          room: '1100',
          instructor: 'Kim',
        ),
      ],
    ),
    _course(
      termCode: termCode,
      subject: 'CHEM',
      code: '6',
      title: 'General Chemistry Lab',
      gradeOption: 'P',
      sections: [_section(section: 'D00', sectionCode: '90005', meetingType: 'Lab', instructor: 'Park')],
    ),
  ],
);

ClassScheduleModel _busySchedule() => ClassScheduleModel(
  data: [
    for (final entry in [
      ('BIOL', '1', 'Introductory Biology I'),
      ('CHEM', '4', 'General Chemistry I'),
      ('ECE', '5', 'Introduction to ECE'),
      ('HUM', '2', 'Humanities'),
      ('MUS', '3', 'Music Appreciation'),
    ])
      _course(
        subject: entry.$1,
        code: entry.$2,
        title: entry.$3,
        sections: [
          _section(
            sectionCode: '9100${entry.$2}',
            days: 'TH',
            time: '09:00-09:50',
            building: 'WLH',
            room: '2001',
            instructor: 'Diaz',
          ),
        ],
      ),
  ],
);

ClassScheduleModel _colorStabilitySchedule() => ClassScheduleModel(
  data: [
    _course(
      subject: 'ANTH',
      code: '1',
      title: 'Introduction to Anthropology',
      sections: [
        _section(
          section: 'E00',
          sectionCode: '92001',
          days: 'MO',
          time: '09:00-09:50',
          building: 'SSB',
          room: '101',
          instructor: 'Adams',
        ),
      ],
    ),
    _course(
      subject: 'BIOL',
      code: '2',
      title: 'Introductory Biology',
      sections: [
        _section(
          section: 'F00',
          sectionCode: '92002',
          days: 'TU',
          time: '10:00-10:50',
          building: 'York',
          room: '201',
          instructor: 'Baker',
        ),
      ],
    ),
    _course(
      subject: 'CHEM',
      code: '3',
      title: 'General Chemistry',
      sections: [
        _section(
          section: 'G00',
          sectionCode: '92003',
          days: 'TU',
          time: '14:00-14:50',
          building: 'York',
          room: '301',
          instructor: 'Clark',
        ),
      ],
    ),
  ],
);

ClassScheduleModel _finalExamSchedule() => ClassScheduleModel(
  data: [
    _course(
      subject: 'CSE',
      code: '100',
      title: 'Advanced Data Structures',
      sections: [
        _section(
          section: 'A00',
          sectionCode: '90001',
          days: 'MO WE FR',
          time: '10:00-10:50',
          building: 'CENTER',
          room: '101',
          instructor: 'Jones',
        ),
        _section(
          section: 'A00',
          sectionCode: '90001',
          meetingType: 'Final Exam',
          specialMtgCode: 'FI',
          date: '2026-12-10',
          building: 'CENTER',
          room: '101',
          instructor: 'Jones',
        ),
      ],
    ),
  ],
);

ClassScheduleModel _emptyQuarterSchedule() => ClassScheduleModel(
  data: [
    _course(
      subject: 'CSE',
      code: '100',
      title: 'Advanced Data Structures',
      sections: [
        _section(
          section: 'A00',
          sectionCode: '90001',
          meetingType: 'Final Exam',
          specialMtgCode: 'FI',
          date: '2026-12-10',
          building: 'CENTER',
          room: '101',
          instructor: 'Jones',
        ),
      ],
    ),
  ],
);

ClassData _course({
  required String subject,
  required String code,
  required String title,
  required List<SectionData> sections,
  String gradeOption = 'L',
  String termCode = 'FA26',
}) => ClassData(
  termCode: termCode,
  subjectCode: subject,
  courseCode: code,
  courseTitle: title,
  enrollmentStatus: 'Booked',
  gradeOption: gradeOption,
  sectionData: sections,
);

SectionData _section({
  required String sectionCode,
  String? section,
  String meetingType = 'Lecture',
  String? days,
  String? time,
  String? date,
  String building = '',
  String room = '',
  String instructor = '',
  String? specialMtgCode,
}) => SectionData(
  section: section,
  sectionCode: sectionCode,
  meetingType: meetingType,
  days: days,
  time: time,
  date: date,
  building: building,
  room: room,
  instructorName: instructor,
  specialMtgCode: specialMtgCode,
);
