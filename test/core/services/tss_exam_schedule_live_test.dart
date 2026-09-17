import 'dart:io';

import 'package:campus_mobile_experimental/core/services/tss_exam_schedule.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

// MA-470 tss-finals-midterm START - opt-in subscribed QA verification
void main() {
  final runLive = Platform.environment['TSS_EXAMS_LIVE_QA_TESTS'] == 'true';

  test(
    'joins preferred QA fixture to exact VIS 001 Final',
    () async {
      await dotenv.load(fileName: '.env');
      final result = await TssExamScheduleClient().examsForStudent('200008248', 'FA26');
      final exams = result.data!.expand((course) => course.sectionData ?? []).toList();

      expect(result.data!.map((course) => '${course.subjectCode}-${course.courseCode}'), contains('VIS-001'));
      expect(exams, hasLength(1));
      expect(exams.single.specialMtgCode, 'FI');
      expect(exams.single.date, '2026-12-07');
      expect(exams.single.time, '11:00 - 13:00');
    },
    skip: runLive ? false : 'Set TSS_EXAMS_LIVE_QA_TESTS=true for subscribed QA verification',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

// MA-470 tss-finals-midterm END - opt-in subscribed QA verification
