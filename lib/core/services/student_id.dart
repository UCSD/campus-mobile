import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/student_id_name.dart';
import 'package:campus_mobile_experimental/core/models/student_id_photo.dart';
import 'package:campus_mobile_experimental/core/models/student_id_profile.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Each call returns its own result; section state belongs to the provider.
class StudentIdService {
  Future<StudentIdNameModel> fetchStudentIdName(Map<String, String> headers) async => studentIdNameModelFromJson(
    await NetworkHelper.authorizedFetch('${dotenv.get('MY_STUDENT_CONTACT_API_ENDPOINT')}/display_name', headers),
  );

  Future<StudentIdPhotoModel> fetchStudentIdPhoto(Map<String, String> headers) async => studentIdPhotoModelFromJson(
    await NetworkHelper.authorizedFetch('${dotenv.get('MY_STUDENT_CONTACT_API_ENDPOINT')}/photo', headers),
  );

  Future<StudentIdProfileModel> fetchStudentIdProfile(Map<String, String> headers) async =>
      studentIdProfileModelFromJson(
        await NetworkHelper.authorizedFetch('${dotenv.get('MY_STUDENT_PROFILE_API_ENDPOINT')}/profile', headers),
      );

  /// Load even while CardContainer hides its body. Fresh GETs bypass image caches
  /// so retrying an unchanged URL starts a new download and decoding attempt.
  Future<ui.Image> fetchStudentIdImage(String url) async {
    final client = Dio(
      BaseOptions(connectTimeout: const Duration(seconds: 30), receiveTimeout: const Duration(seconds: 30)),
    );
    try {
      final response = await client.get<List<int>>(url, options: Options(responseType: ResponseType.bytes));
      if (response.statusCode != 200 || response.data == null) {
        throw const FormatException('Student ID photo download failed');
      }
      final codec = await ui.instantiateImageCodec(Uint8List.fromList(response.data!));
      try {
        return (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
    } finally {
      client.close(force: true);
    }
  }
}
