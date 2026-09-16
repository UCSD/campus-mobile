import 'dart:io';

import 'package:campus_mobile_experimental/core/services/classes.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/classes.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/tss_academic_history.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

/// Manual local QA smoke check
/// CI skips it and output excludes credentials and tokens
// MA-470 tss-classes START - opt-in live QA Classes checks
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('explicit local QA term bypasses AcademicTerm and selects Fall', () async {
    HttpOverrides.global = null;
    await dotenv.load(fileName: '.env');
    final classes = ClassScheduleService();
    final fetched = await classes.fetchAcademicTerm();
    expect(fetched, isTrue, reason: classes.error?.toString());
    expect(classes.academicTermModel?.termCode, 'FA26');
  }, skip: !const bool.fromEnvironment('RUN_TSS_LIVE_QA'));

  test(
    'subscribed OAuth client retrieves and maps the known Spring QA bookings',
    () async {
      // Flutter test binding uses mock HttpClient returning 400
      // Local opt-in test restores real client for QA
      HttpOverrides.global = null;
      await dotenv.load(fileName: '.env');
      final client = TssAcademicHistoryClient();
      expect(client.enabled, isTrue);

      final result = await client.classesForStudent('200000086', 'SP26');
      expect(result.data, isNotEmpty);
      final math = result.data!.firstWhere((course) => course.subjectCode == 'MATH' && course.courseCode == '010A');
      expect(math.enrollmentStatus, 'EN');
      expect(math.sectionData!.any((section) => section.days == 'TH'), isTrue);
    },
    skip: !const bool.fromEnvironment('RUN_TSS_LIVE_QA'),
  );

  test(
    'checks another authorized QA TSN and term without logging its identifier',
    () async {
      HttpOverrides.global = null;
      await dotenv.load(fileName: '.env');
      final studentNumber = const String.fromEnvironment('TSS_QA_STUDENT_NUMBER');
      final termCode = const String.fromEnvironment('TSS_QA_TERM_CODE', defaultValue: 'SP26');
      expect(studentNumber, matches(RegExp(r'^\d{9}$')));
      expect(termCode, matches(RegExp(r'^(FA|WI|SP|S1|S2)\d{2}$')));
      final result = await TssAcademicHistoryClient().classesForStudent(studentNumber, termCode);
      expect(result.data, isNotNull);
      if (const bool.fromEnvironment('TSS_QA_REQUIRE_ALL_MEETINGS')) {
        expect(result.data!.length, greaterThanOrEqualTo(3));
        for (final course in result.data!) {
          expect(course.sectionData, isNotEmpty, reason: '${course.subjectCode} ${course.courseCode} has no meeting');
          for (final section in course.sectionData!) {
            expect(section.time, isNotNull, reason: '${course.subjectCode} ${course.courseCode} has no meeting time');
          }
        }
      }
      // Only print counts and skip student identifiers or rows
      final scheduledMeetings = result.data!.fold<int>(0, (count, course) => count + (course.sectionData?.length ?? 0));
      // ignore: avoid_print
      print('$termCode direct TSS booking count: ${result.data!.length}; mapped meeting count: $scheduledMeetings');
      // ignore: avoid_print
      print(
        'Mapped course/meeting counts: ${result.data!.map((c) => '${c.subjectCode} ${c.courseCode}=${c.sectionData?.length ?? 0}').join(', ')}',
      );
      if (const bool.fromEnvironment('TSS_QA_PRINT_SCHEDULE')) {
        for (final course in result.data!) {
          final slots = course.sectionData!.map((section) => '${section.days} ${section.time}').toSet().toList()
            ..sort();
          // ignore: avoid_print
          print('${course.subjectCode} ${course.courseCode}: ${slots.join(', ')}');
        }
      }
    },
    skip:
        !const bool.fromEnvironment('RUN_TSS_LIVE_QA') || const String.fromEnvironment('TSS_QA_STUDENT_NUMBER').isEmpty,
  );

  test('anonymous synthetic QA preview reaches the Classes provider', () async {
    HttpOverrides.global = null;
    await dotenv.load(fileName: '.env');
    final user = UserDataProvider();
    expect(user.isLoggedIn, isFalse);
    final cards = CardsDataProvider();
    cards.showAnonymousQaClassesPreview();
    expect(cards.cardStates['schedule'], isTrue);
    final provider = ClassScheduleDataProvider()..userDataProvider = user;
    expect(provider.isAnonymousQaPreview, isTrue);
    provider.fetchData();
    for (var attempt = 0; attempt < 100 && provider.isLoading; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    expect(provider.isLoading, isFalse);
    expect(provider.error, isNull);
    expect(provider.classScheduleModel.data, isNotEmpty);
    expect(provider.upcomingCourses, isNotEmpty);
    expect(provider.bookedCourses.length, 5);
    expect(provider.unscheduledCourses, isEmpty);
    expect(provider.bookedCourses.every((course) => course.sectionData?.isNotEmpty ?? false), isTrue);
    final viewAllSections = provider.enrolledClasses.values.expand((sections) => sections).toList();
    expect(viewAllSections.length, 13);
    expect(viewAllSections.map((section) => '${section.subjectCode} ${section.courseCode}').toSet().length, 5);
  }, skip: !const bool.fromEnvironment('RUN_TSS_LIVE_QA'));
}

// MA-470 tss-classes END - opt-in live QA Classes checks
