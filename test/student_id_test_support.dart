import 'dart:async';
import 'dart:ui' as ui;
import 'package:campus_mobile_experimental/core/models/authentication.dart';
import 'package:campus_mobile_experimental/core/models/student_id_name.dart';
import 'package:campus_mobile_experimental/core/models/student_id_photo.dart';
import 'package:campus_mobile_experimental/core/models/student_id_profile.dart';
import 'package:campus_mobile_experimental/core/providers/student_id.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/student_id.dart';

class StudentIdTestUser extends UserDataProvider {
  bool loggedIn = true;
  AuthenticationModel auth = AuthenticationModel(pid: 'student-one', accessToken: 'token-one');

  @override
  bool get isLoggedIn => loggedIn;

  @override
  AuthenticationModel get authenticationModel => auth;

  void changeSession({String? pid, String? token, bool signOut = false}) {
    loggedIn = !signOut;
    auth = AuthenticationModel(pid: pid, accessToken: token);
    notifyListeners();
  }
}

class StudentIdTestService extends StudentIdService {
  final names = <Completer<StudentIdNameModel>>[];
  final profiles = <Completer<StudentIdProfileModel>>[];
  final photos = <Completer<StudentIdPhotoModel>>[];
  final images = <Completer<ui.Image>>[];
  final imageUrls = <String>[];
  final authorizations = <String>[];

  @override
  Future<StudentIdNameModel> fetchStudentIdName(Map<String, String> headers) {
    authorizations.add(headers['Authorization']!);
    final request = Completer<StudentIdNameModel>();
    names.add(request);
    return request.future;
  }

  @override
  Future<StudentIdProfileModel> fetchStudentIdProfile(Map<String, String> headers) {
    authorizations.add(headers['Authorization']!);
    final request = Completer<StudentIdProfileModel>();
    profiles.add(request);
    return request.future;
  }

  @override
  Future<StudentIdPhotoModel> fetchStudentIdPhoto(Map<String, String> headers) {
    authorizations.add(headers['Authorization']!);
    final request = Completer<StudentIdPhotoModel>();
    photos.add(request);
    return request.future;
  }

  @override
  Future<ui.Image> fetchStudentIdImage(String url) {
    imageUrls.add(url);
    final request = Completer<ui.Image>();
    images.add(request);
    return request.future;
  }
}

class StudentIdTestFixture {
  final user = StudentIdTestUser();
  final service = StudentIdTestService();
  late final provider = StudentIdDataProvider(service: service)..userDataProvider = user;

  void start() => provider;

  void dispose() {
    provider.dispose();
    user.dispose();
  }
}

StudentIdNameModel testName([String name = 'Student One']) => studentIdNameModelFromJson('{"firstName":"$name"}');
StudentIdProfileModel testProfile([String barcode = '1234567890']) =>
    studentIdProfileModelFromJson('{"Barcode":"$barcode"}');
StudentIdPhotoModel testPhoto([String url = 'https://example.edu/photo']) =>
    studentIdPhotoModelFromJson('{"photoUrl":"$url"}');

ui.Image testStudentPhoto() {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawColor(const ui.Color(0xff123456), ui.BlendMode.src);
  final picture = recorder.endRecording();
  final image = picture.toImageSync(2, 2);
  picture.dispose();
  return image;
}
