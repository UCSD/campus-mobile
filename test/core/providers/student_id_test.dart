import 'package:campus_mobile_experimental/core/models/student_id_name.dart';
import 'package:campus_mobile_experimental/core/models/student_id_photo.dart';
import 'package:campus_mobile_experimental/core/models/student_id_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../student_id_test_support.dart';

void main() {
  testWidgets('parallel requests notify independently in every response order', (tester) async {
    for (final order in [
      [0, 1, 2],
      [0, 2, 1],
      [1, 0, 2],
      [1, 2, 0],
      [2, 0, 1],
      [2, 1, 0],
    ]) {
      final fixture = StudentIdTestFixture()..start();
      final provider = fixture.provider;
      expect(fixture.service.names, hasLength(1));
      expect(fixture.service.profiles, hasLength(1));
      expect(fixture.service.photos, hasLength(1));
      expect(provider.isLoading, isTrue);
      expect(provider.error, isNull);
      var notifications = 0;
      provider.addListener(() => notifications++);
      for (final section in order) {
        if (section == 0) fixture.service.names.single.complete(testName());
        if (section == 1) fixture.service.profiles.single.complete(testProfile());
        if (section == 2) fixture.service.photos.single.complete(testPhoto());
        await tester.pump();
        if (section == 0) expect(provider.hasName, isTrue);
        if (section == 1) expect(provider.hasBarcode, isTrue);
        if (section == 2) {
          expect(fixture.service.images, hasLength(1));
          expect(provider.hasPhoto, isFalse);
          expect(provider.isImageLoading, isTrue);
        }
        expect(notifications, greaterThan(0));
      }
      fixture.service.images.single.complete(testStudentPhoto());
      await tester.pump();
      expect(provider.hasPhoto, isTrue);
      expect(provider.hasPendingWork, isFalse);
      fixture.dispose();
    }
  });

  for (var failures = 0; failures < 8; failures++) {
    testWidgets('preserves usable verification for API failure combination $failures', (tester) async {
      final fixture = StudentIdTestFixture()..start();
      addTearDown(fixture.dispose);
      final service = fixture.service;
      if (failures & 1 != 0) {
        service.names.single.completeError(Exception('name'));
      } else {
        service.names.single.complete(testName());
      }
      if (failures & 2 != 0) {
        service.profiles.single.completeError(Exception('profile'));
      } else {
        service.profiles.single.complete(testProfile());
      }
      if (failures & 4 != 0) {
        service.photos.single.completeError(Exception('photo'));
      } else {
        service.photos.single.complete(testPhoto());
      }
      await tester.pump();
      if (service.images.isNotEmpty) {
        service.images.single.complete(testStudentPhoto());
        await tester.pump();
      }
      final provider = fixture.provider;
      expect(provider.hasName, failures & 1 == 0);
      expect(provider.hasBarcode, failures & 2 == 0);
      expect(provider.hasPhoto, failures & 4 == 0);
      expect(provider.hasUsableContent, failures != 7);
      expect(provider.hasPendingWork, isFalse);
      expect(provider.error, failures == 7 ? 'An error occurred, please try again.' : null);
    });
  }

  testWidgets('a photo URL and academics alone cannot retain a completed card', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    fixture.service.names.single.complete(StudentIdNameModel());
    fixture.service.profiles.single.complete(
      studentIdProfileModelFromJson(
        '{"Barcode":"invalid","College_Current":"Revelle","UG_Primary_Major_Current":"Biology"}',
      ),
    );
    fixture.service.photos.single.complete(testPhoto());
    await tester.pump();
    expect(fixture.provider.hasUsableContent, isFalse);
    expect(fixture.provider.isLoading, isTrue);
    expect(fixture.provider.error, isNull);
    fixture.service.images.single.completeError(Exception('decode failed'));
    await tester.pump();
    expect(fixture.provider.studentIdProfileModel.collegeCurrent, 'Revelle');
    expect(fixture.provider.error, 'An error occurred, please try again.');
  });

  testWidgets('empty 200 fields become unavailable and retry owning endpoints', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    fixture.service.names.single.complete(StudentIdNameModel());
    fixture.service.profiles.single.complete(StudentIdProfileModel());
    fixture.service.photos.single.complete(StudentIdPhotoModel());
    await tester.pump();
    expect(fixture.provider.hasPendingWork, isFalse);
    expect(fixture.provider.error, 'An error occurred, please try again.');
    fixture.provider.fetchData();
    fixture.provider.fetchData();
    expect(fixture.service.names, hasLength(2));
    expect(fixture.service.profiles, hasLength(2));
    expect(fixture.service.photos, hasLength(2));
    fixture.service.names.last.complete(testName());
    fixture.service.profiles.last.complete(testProfile());
    fixture.service.photos.last.complete(StudentIdPhotoModel());
    await tester.pump();
  });

  testWidgets('barcode retry keeps successful academics and skips loading sections', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    fixture.service.profiles.single.complete(
      studentIdProfileModelFromJson(
        '{"Barcode":"bad","College_Current":"Revelle","Classification_Type":"Undergraduate"}',
      ),
    );
    fixture.service.photos.single.complete(testPhoto());
    await tester.pump();
    fixture.provider.fetchData();
    fixture.provider.fetchData();
    expect(fixture.service.names, hasLength(1));
    expect(fixture.service.photos, hasLength(1));
    expect(fixture.service.images, hasLength(1));
    expect(fixture.service.profiles, hasLength(2));
    expect(fixture.provider.studentIdProfileModel.collegeCurrent, 'Revelle');
    fixture.service.names.single.complete(testName());
    fixture.service.images.single.complete(testStudentPhoto());
    fixture.service.profiles.last.complete(
      studentIdProfileModelFromJson('{"Barcode":null,"UG_Primary_Major_Current":"Biology","College_Current":false}'),
    );
    await tester.pump();
    expect(fixture.provider.studentIdProfileModel.collegeCurrent, 'Revelle');
    expect(fixture.provider.studentIdProfileModel.major, 'Biology');
    expect(fixture.provider.hasBarcode, isFalse);
    fixture.provider.fetchData();
    expect(fixture.service.names, hasLength(1));
    expect(fixture.service.photos, hasLength(1));
    expect(fixture.service.profiles, hasLength(3));
    fixture.service.profiles.last.complete(testProfile());
    await tester.pump();
    expect(fixture.provider.hasBarcode, isTrue);
    expect(fixture.provider.studentIdProfileModel.classificationType, 'Undergraduate');
  });

  testWidgets('image-only retry reuses URL and refetches metadata if URL still fails', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    fixture.service.names.single.complete(testName());
    fixture.service.profiles.single.complete(testProfile());
    fixture.service.photos.single.complete(testPhoto());
    await tester.pump();
    fixture.service.images.single.completeError(Exception('image failed'));
    await tester.pump();
    fixture.provider.fetchData();
    fixture.provider.fetchData();
    expect(fixture.service.names, hasLength(1));
    expect(fixture.service.profiles, hasLength(1));
    expect(fixture.service.photos, hasLength(1));
    expect(fixture.service.imageUrls, ['https://example.edu/photo', 'https://example.edu/photo']);
    fixture.service.images.last.completeError(Exception('expired URL'));
    await tester.pump();
    expect(fixture.service.photos, hasLength(2));
    expect(fixture.provider.hasPendingWork, isTrue);
    fixture.provider.fetchData();
    expect(fixture.service.photos, hasLength(2));
    fixture.service.photos.last.complete(testPhoto('https://example.edu/fresh'));
    await tester.pump();
    expect(fixture.service.imageUrls.last, 'https://example.edu/fresh');
    fixture.service.images.last.complete(testStudentPhoto());
    await tester.pump();
    expect(fixture.provider.hasPhoto, isTrue);
    expect(fixture.provider.imageError, isNull);
  });

  testWidgets('healthy Reload refreshes all APIs despite missing optional academics', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    fixture.service.names.single.complete(testName());
    fixture.service.profiles.single.complete(testProfile());
    fixture.service.photos.single.complete(testPhoto());
    await tester.pump();
    fixture.service.images.single.complete(testStudentPhoto());
    await tester.pump();
    final retainedPhoto = fixture.provider.studentPhoto;
    fixture.provider.fetchData();
    fixture.provider.fetchData();
    expect(fixture.service.names, hasLength(2));
    expect(fixture.service.profiles, hasLength(2));
    expect(fixture.service.photos, hasLength(2));
    expect(fixture.provider.hasUsableContent, isTrue);
    expect(fixture.provider.isLoading, isFalse);
    fixture.service.names.last.complete(StudentIdNameModel());
    fixture.service.profiles.last.complete(StudentIdProfileModel());
    fixture.service.photos.last.complete(testPhoto());
    await tester.pump();
    fixture.service.images.last.completeError(Exception('failed replacement'));
    await tester.pump();
    expect(fixture.provider.hasName, isTrue);
    expect(fixture.provider.hasBarcode, isTrue);
    expect(fixture.provider.studentPhoto, same(retainedPhoto));
    fixture.provider.fetchData();
    expect(fixture.service.names, hasLength(3));
    expect(fixture.service.profiles, hasLength(3));
    expect(fixture.service.images, hasLength(3));
    fixture.service.names.last.complete(testName('New Name'));
    fixture.service.profiles.last.complete(testProfile('9876543210'));
    fixture.service.images.last.complete(testStudentPhoto());
    await tester.pump();
  });

  testWidgets('API overall deadline ends pending and ignores superseded completions', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    await tester.pump(const Duration(seconds: 59));
    expect(fixture.provider.hasPendingWork, isTrue);
    await tester.pump(const Duration(seconds: 1));
    expect(fixture.provider.hasPendingWork, isFalse);
    expect(fixture.provider.error, 'An error occurred, please try again.');
    fixture.provider.fetchData();
    fixture.service.names.first.complete(testName('Expired Name'));
    fixture.service.profiles.first.complete(testProfile('111111'));
    fixture.service.photos.first.complete(testPhoto('https://example.edu/expired'));
    await tester.pump();
    expect(fixture.provider.hasUsableContent, isFalse);
    expect(fixture.service.images, isEmpty);
    expect(fixture.provider.hasPendingWork, isTrue);
    fixture.service.names.last.complete(testName('Current Name'));
    fixture.service.profiles.last.complete(testProfile('222222'));
    fixture.service.photos.last.complete(StudentIdPhotoModel());
    await tester.pump();
    expect(fixture.provider.studentIdNameModel.displayName, 'Current Name');
    expect(fixture.provider.studentIdProfileModel.barcode, '222222');
  });

  testWidgets('image deadline includes decode, permits retry and ignores late images', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    fixture.service.names.single.complete(StudentIdNameModel());
    fixture.service.profiles.single.complete(StudentIdProfileModel());
    fixture.service.photos.single.complete(testPhoto());
    await tester.pump();
    await tester.pump(const Duration(seconds: 29));
    expect(fixture.provider.isLoading, isTrue);
    await tester.pump(const Duration(seconds: 1));
    expect(fixture.provider.isImageLoading, isFalse);
    expect(fixture.provider.error, 'An error occurred, please try again.');
    fixture.provider.fetchData();
    fixture.service.images.first.complete(testStudentPhoto());
    await tester.pump();
    expect(fixture.provider.hasPhoto, isFalse);
    expect(fixture.provider.isImageLoading, isTrue);
    fixture.service.names.last.complete(StudentIdNameModel());
    fixture.service.profiles.last.complete(StudentIdProfileModel());
    fixture.service.images.last.complete(testStudentPhoto());
    await tester.pump();
    expect(fixture.provider.hasPhoto, isTrue);
    expect(fixture.provider.hasPendingWork, isFalse);
  });

  testWidgets('switching users and signing out clear content and reject prior-session results', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    fixture.service.names.single.complete(testName());
    fixture.service.photos.single.complete(testPhoto());
    await tester.pump();
    fixture.user.changeSession(pid: 'student-two', token: 'token-two');
    expect(fixture.provider.hasName, isFalse);
    expect(fixture.provider.hasPhoto, isFalse);
    expect(fixture.provider.hasPendingWork, isTrue);
    expect(fixture.service.authorizations.last, 'Bearer token-two');
    fixture.service.profiles.first.complete(testProfile('111111'));
    fixture.service.images.first.complete(testStudentPhoto());
    fixture.service.names.last.complete(testName('Student Two'));
    fixture.service.profiles.last.complete(testProfile('222222'));
    fixture.service.photos.last.complete(testPhoto('https://example.edu/two'));
    await tester.pump();
    expect(fixture.provider.studentIdNameModel.displayName, 'Student Two');
    expect(fixture.provider.studentIdProfileModel.barcode, '222222');
    expect(fixture.provider.hasPhoto, isFalse);
    fixture.user.changeSession(signOut: true);
    expect(fixture.provider.hasUsableContent, isFalse);
    expect(fixture.provider.hasPendingWork, isFalse);
    fixture.service.images.last.complete(testStudentPhoto());
    await tester.pump();
    expect(fixture.provider.hasUsableContent, isFalse);
    fixture.provider.fetchData();
    expect(fixture.service.names, hasLength(2));
  });

  testWidgets('token refresh retains same-user content and invalidates old requests', (tester) async {
    final fixture = StudentIdTestFixture()..start();
    addTearDown(fixture.dispose);
    fixture.service.names.single.complete(testName());
    await tester.pump();
    fixture.user.changeSession(pid: 'student-one', token: 'refreshed-token');
    expect(fixture.provider.hasName, isTrue);
    expect(fixture.service.authorizations.last, 'Bearer refreshed-token');
    fixture.service.profiles.first.complete(testProfile('111111'));
    fixture.service.photos.first.complete(testPhoto());
    await tester.pump();
    expect(fixture.provider.hasBarcode, isFalse);
    expect(fixture.service.images, isEmpty);
    fixture.service.names.last.complete(testName());
    fixture.service.profiles.last.complete(testProfile('222222'));
    fixture.service.photos.last.complete(StudentIdPhotoModel());
    await tester.pump();
    expect(fixture.provider.studentIdProfileModel.barcode, '222222');
  });
}
