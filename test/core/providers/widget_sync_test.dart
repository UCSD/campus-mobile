import 'dart:async';

import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/term.dart';
import 'package:campus_mobile_experimental/core/models/student_id_name.dart';
import 'package:campus_mobile_experimental/core/models/student_id_profile.dart';
import 'package:campus_mobile_experimental/core/models/student_id_photo.dart';
import 'package:campus_mobile_experimental/core/models/authentication.dart';
import 'package:campus_mobile_experimental/core/providers/classes.dart';
import 'package:campus_mobile_experimental/core/providers/student_id.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/classes.dart';
import 'package:campus_mobile_experimental/core/services/home_widget.dart';
import 'package:campus_mobile_experimental/core/services/student_id.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final saved = <String, Object?>{};

  setUp(() {
    saved.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('home_widget'),
      (call) async {
        final args = call.arguments as Map;
        if (call.method == 'saveWidgetData') saved[args['id']] = args['data'];
        return true;
      },
    );
  });

  test('classes fetch does not publish after an account switch', () async {
    final user = _FakeUser(pid: 'A', token: 'token-a');
    final service = _FakeClassScheduleService();
    final provider = ClassScheduleDataProvider(service: service)..userDataProvider = user;
    provider.fetchData();
    await service.completeTerm();

    // Account A's response can finish after account B has authenticated.
    user.pid = 'B';
    user.token = 'token-b';
    await service.completeCourses();
    await _settle();

    expect(saved['classes_MO'], isNull);
    provider.dispose();
  });

  test('classes fetch publishes for the unchanged session', () async {
    final user = _FakeUser(pid: 'A', token: 'token-a');
    final service = _FakeClassScheduleService();
    final provider = ClassScheduleDataProvider(service: service)..userDataProvider = user;
    provider.fetchData();
    await service.completeTerm();
    await service.completeCourses();
    await _settle();

    expect(saved['classes_MO'], 'CSE 141L  10:00');
    provider.dispose();
  });

  test('Student ID waits for profile and does not resync for photo', () async {
    final profile = Completer<StudentIdProfileModel>();
    final photo = Completer<StudentIdPhotoModel>();
    final service = _FakeStudentIdService(profile: profile.future, photo: photo.future, nameResult: _name());
    final provider = StudentIdDataProvider(service: service)..userDataProvider = _FakeUser(pid: 'A', token: 'token-a');
    await _settle();

    expect(saved, isEmpty);
    profile.complete(_profile());
    await _settle();
    await HomeWidgetService.syncClasses({}); // Wait for the queued Student ID write.
    expect(saved['student_name'], 'Jane Doe');

    saved.clear();
    photo.complete(StudentIdPhotoModel());
    await _settle();
    await HomeWidgetService.syncClasses({});
    expect(saved, isNot(contains('student_name')));
    provider.dispose();
  });

  test('first-fetch name failure does not publish a partial Student ID', () async {
    final service = _FakeStudentIdService(
      profile: Future.value(_profile()),
      photo: Completer<StudentIdPhotoModel>().future,
    );
    final provider = StudentIdDataProvider(service: service)..userDataProvider = _FakeUser(pid: 'A', token: 'token-a');
    await _settle();

    expect(provider.profileError, isNull);
    expect(provider.hasBarcode, isTrue);
    expect(provider.nameError, isNotNull);
    expect(saved, isEmpty);
    provider.dispose();
  });

  test('same-user retained Student ID content survives a failed token refresh', () async {
    final user = _FakeUser(pid: 'A', token: 'token-a');
    final service = _FakeStudentIdService(
      profile: Future.value(_profile()),
      photo: Completer<StudentIdPhotoModel>().future,
      photoError: StateError('photo unavailable'),
      nameResult: _name(),
    );
    final provider = StudentIdDataProvider(service: service)..userDataProvider = user;
    await _settle();
    final firstSync = saved['student_name'];

    // Same PID but a new token starts a refresh without clearing same-user data.
    user.token = 'token-b';
    service.nameError = StateError('name unavailable');
    service.profileError = StateError('profile unavailable');
    provider.userDataProvider = user;
    await _settle();

    expect(firstSync, 'Jane Doe');
    expect(saved['student_name'], 'Jane Doe');
    provider.dispose();
  });
}

class _FakeUser extends UserDataProvider {
  _FakeUser({this.pid, this.token});

  String? pid;
  String? token;

  @override
  bool get isLoggedIn => true;

  @override
  AuthenticationModel get authenticationModel => AuthenticationModel(pid: pid, accessToken: token, expiration: 3600);
}

class _FakeClassScheduleService extends ClassScheduleService {
  final _term = Completer<bool>();
  final _gr = Completer<bool>();
  final _un = Completer<bool>();

  Future<void> completeTerm() async {
    _term.complete(true);
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> completeCourses() async {
    _gr.complete(true);
    _un.complete(true);
    await Future<void>.delayed(Duration.zero);
  }

  @override
  Future<bool> fetchAcademicTerm() => _term.future;

  @override
  Future<bool> fetchGRCourses(Map<String, String> headers, String term) => _gr.future;

  @override
  Future<bool> fetchUNCourses(Map<String, String> headers, String term) => _un.future;

  @override
  AcademicTermModel? get academicTermModel => AcademicTermModel(termName: 'Fall', termCode: 'FA26');

  @override
  ClassScheduleModel get grData => ClassScheduleModel(data: []);

  @override
  ClassScheduleModel get unData => ClassScheduleModel(
    data: [
      ClassData(
        subjectCode: 'CSE',
        courseCode: '141L',
        enrollmentStatus: 'Booked',
        sectionData: [SectionData(time: '10:00-10:50', days: 'MO')],
      ),
    ],
  );
}

class _FakeStudentIdService extends StudentIdService {
  _FakeStudentIdService({required this.profile, required this.photo, this.nameResult, this.photoError});

  StudentIdNameModel? nameResult;
  Object? nameError;
  Object? photoError;
  Object? profileError;
  Future<StudentIdProfileModel> profile;
  Future<StudentIdPhotoModel> photo;

  @override
  Future<StudentIdNameModel> fetchStudentIdName(Map<String, String> headers) async {
    if (nameError != null) throw nameError!;
    return nameResult ?? StudentIdNameModel();
  }

  @override
  Future<StudentIdProfileModel> fetchStudentIdProfile(Map<String, String> headers) async {
    if (profileError != null) throw profileError!;
    return profile;
  }

  @override
  Future<StudentIdPhotoModel> fetchStudentIdPhoto(Map<String, String> headers) async {
    if (photoError != null) throw photoError!;
    return photo;
  }
}

StudentIdNameModel _name() => StudentIdNameModel(firstName: 'Jane', lastName: 'Doe');

StudentIdProfileModel _profile() => StudentIdProfileModel(ugPrimaryMajorCurrent: 'Computer Science', barcode: 'C1234C');

Future<void> _settle() async {
  for (var i = 0; i < 8; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
