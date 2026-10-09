import 'dart:io';
import 'package:campus_mobile_experimental/core/services/student_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('photo service downloads and decodes, repeats GETs, and rejects HTTP/decoding failures', () async {
    // Use a local HTTP fixture to exercise the real downloader and codec without
    // authentication or live Student ID data.
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final photoBytes = await File('assets/images/staff_id_placeholder.png').readAsBytes();
    var photoRequests = 0;
    final subscription = server.listen((request) async {
      if (request.uri.path == '/photo') {
        photoRequests++;
        request.response.headers.contentType = ContentType('image', 'png');
        request.response.add(photoBytes);
      } else if (request.uri.path == '/invalid') {
        request.response.write('not an image');
      } else {
        request.response.statusCode = 404;
      }
      await request.response.close();
    });
    try {
      final service = StudentIdService();
      final url = 'http://127.0.0.1:${server.port}';
      final first = await service.fetchStudentIdImage('$url/photo');
      expect(first.width, greaterThan(0));
      expect(first.height, greaterThan(0));
      first.dispose();
      final second = await service.fetchStudentIdImage('$url/photo');
      second.dispose();
      expect(photoRequests, 2);
      await expectLater(service.fetchStudentIdImage('$url/invalid'), throwsA(anything));
      await expectLater(service.fetchStudentIdImage('$url/missing'), throwsA(anything));
    } finally {
      await subscription.cancel();
      await server.close(force: true);
    }
  });
}
