import 'dart:convert';

import 'package:campus_mobile_experimental/core/models/authentication.dart';
import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/term.dart';
import 'package:campus_mobile_experimental/core/services/tss_exam_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// MA-470 tss-finals-midterm START - direct TSS exam QA service
/// Local QA proof only
/// Flutter bundles dotenv including TSS secret
/// Never distribute or use in production
class TssExamScheduleClient {
  TssExamScheduleClient({Dio? dio})
    : _dio =
          dio ??
          Dio(BaseOptions(connectTimeout: const Duration(seconds: 12), receiveTimeout: const Duration(seconds: 30)));

  final Dio _dio;
  String? _cachedToken;
  DateTime? _tokenExpiresAt;

  bool get enabled => _env('TSS_EXAMS_DIRECT_QA_ENABLED').toLowerCase() == 'true';

  bool get anonymousQaPreviewEnabled =>
      enabled &&
      _env('TSS_EXAMS_ANONYMOUS_PREVIEW').toLowerCase() == 'true' &&
      _isTsn(_env('TSS_EXAMS_STUDENT_NUMBER_OVERRIDE'));

  bool get hasStudentOverride => enabled && _isTsn(_env('TSS_EXAMS_STUDENT_NUMBER_OVERRIDE'));

  AcademicTermModel? get overrideTerm {
    final termCode = _env('TSS_EXAMS_TERM_CODE_OVERRIDE');
    if (!enabled || termCode.isEmpty) return null;
    final term = _tssTerm(termCode);
    return AcademicTermModel(termName: '${term.name} ${term.calendarYear}', termCode: termCode);
  }

  String? qaStudentNumber(AuthenticationModel authentication) {
    final override = _env('TSS_EXAMS_STUDENT_NUMBER_OVERRIDE');
    if (override.isNotEmpty) return _isTsn(override) ? override : null;
    final currentQaValue = authentication.pid?.trim() ?? '';
    return _isTsn(currentQaValue) ? currentQaValue : null;
  }

  AcademicTermModel selectedTerm(AcademicTermModel currentTerm) {
    final override = _env('TSS_EXAMS_TERM_CODE_OVERRIDE');
    if (override.isEmpty) return currentTerm;
    final term = _tssTerm(override);
    return AcademicTermModel(termName: '${term.name} ${term.calendarYear}', termCode: override);
  }

  Future<ClassScheduleModel> examsForStudent(String studentNumber, String termCode) async {
    if (!enabled) throw StateError('Direct TSS exam QA mode is disabled');
    if (!_isTsn(studentNumber)) throw const FormatException('A valid TSN is required for TSS exams');

    final term = _tssTerm(termCode);
    final token = await _serviceToken();
    final bookingEndpoint = _httpsEndpoint('TSS_ACADEMIC_HISTORY_BOOKING_ENDPOINT');
    final eventsEndpoint = _httpsEndpoint('TSS_SCHEDULE_OF_CLASSES_EVENTS_ENDPOINT');
    if (kDebugMode) {
      debugPrint('[MA470 Exams QA] fetch start; term=$termCode; studentOverride=$hasStudentOverride');
    }

    final bookingFilter =
        "studentNumber eq '$studentNumber' and academicYear eq '${term.academicYear}' and sessionCode eq '${term.sessionCode}' and bookingStatusCode eq '1'";
    final bookings = await _pagedRows(
      bookingEndpoint.replace(
        queryParameters: {
          r'$filter': bookingFilter,
          r'$select':
              'studentNumber,moduleId,moduleCode,moduleName,academicYear,sessionCode,programTypeCode,bookingStatusCode',
          r'$expand': 'events',
          r'$top': '100',
        },
      ),
      bookingEndpoint,
      token,
      'Booking',
    );

    final modules = <String>{
      for (final row in bookings)
        if (row is Map && _string(row['moduleCode']).isNotEmpty) _string(row['moduleCode']),
    };
    final catalogEvents = <dynamic>[];
    for (final moduleCode in modules) {
      final eventsFilter =
          "moduleCode eq '$moduleCode' and academicYear eq '${term.academicYear}' and sessionCode eq '${term.sessionCode}'";
      catalogEvents.addAll(
        await _pagedRows(
          eventsEndpoint.replace(
            queryParameters: {
              r'$filter': eventsFilter,
              r'$select': 'eventId,moduleCode,moduleName,academicYear,sessionCode,eventCode,eventName',
              r'$expand': 'meetingSchedule,instructors',
              r'$top': '100',
            },
          ),
          eventsEndpoint,
          token,
          'Events $moduleCode',
        ),
      );
    }

    final result = classScheduleModelFromTssExams(
      bookingResponse: {'value': bookings},
      eventsResponse: {'value': catalogEvents},
      termCode: termCode,
    );
    if (kDebugMode) {
      final examCount = result.data?.fold<int>(0, (count, course) => count + (course.sectionData?.length ?? 0)) ?? 0;
      debugPrint('[MA470 Exams QA] exact booked exams=$examCount; booked modules=${modules.length}');
    }
    return result;
  }

  Future<List<dynamic>> _pagedRows(Uri pageUri, Uri baseUri, String token, String label) async {
    final rows = <dynamic>[];
    for (var page = 0; page < 10; page++) {
      final body = await _get(pageUri, token, label);
      final pageRows = body['value'];
      if (pageRows is! List) throw FormatException('TSS $label response has no value array');
      rows.addAll(pageRows);
      if (kDebugMode) debugPrint('[MA470 Exams QA] $label page ${page + 1}: rows=${pageRows.length}');
      final nextLink = _string(body['@odata.nextLink']);
      if (nextLink.isEmpty) return rows;
      final nextUri = pageUri.resolve(nextLink);
      if (nextUri.scheme != baseUri.scheme ||
          nextUri.host != baseUri.host ||
          nextUri.port != baseUri.port ||
          !nextUri.path.startsWith(baseUri.path)) {
        throw FormatException('TSS $label pagination target is invalid');
      }
      pageUri = nextUri;
    }
    throw FormatException('TSS $label pagination exceeded local QA limit');
  }

  Future<Map<String, dynamic>> _get(Uri uri, String token, String label) async {
    try {
      final response = await _dio.getUri<dynamic>(
        uri,
        options: Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'}),
      );
      return _jsonObject(response.data);
    } on DioException catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[MA470 Exams QA] $label failed: type=${error.type}; status=${error.response?.statusCode ?? 'none'}',
        );
      }
      throw StateError('TSS $label request failed (HTTP ${error.response?.statusCode ?? 'network error'})');
    }
  }

  Future<String> _serviceToken() async {
    final now = DateTime.now();
    if (_cachedToken != null && _tokenExpiresAt != null && now.isBefore(_tokenExpiresAt!)) {
      return _cachedToken!;
    }

    final clientId = _env('TSS_CLIENT_ID');
    final clientSecret = _env('TSS_CLIENT_SECRET');
    final tokenEndpoint = Uri.tryParse(_env('TSS_OAUTH_TOKEN_ENDPOINT'));
    if (clientId.isEmpty ||
        clientSecret.isEmpty ||
        tokenEndpoint == null ||
        tokenEndpoint.scheme != 'https' ||
        tokenEndpoint.host.isEmpty) {
      throw StateError('Direct TSS exam OAuth configuration is incomplete');
    }

    final basic = base64Encode(utf8.encode('$clientId:$clientSecret'));
    try {
      final response = await _dio.postUri<dynamic>(
        tokenEndpoint,
        data: 'grant_type=client_credentials',
        options: Options(headers: {'Authorization': 'Basic $basic'}, contentType: Headers.formUrlEncodedContentType),
      );
      final body = _jsonObject(response.data);
      final token = _string(body['access_token']);
      if (token.isEmpty) throw const FormatException('TSS OAuth response has no access token');
      final expiresIn = int.tryParse(_string(body['expires_in'])) ?? 300;
      final safeLifetime = expiresIn > 90 ? expiresIn - 60 : expiresIn ~/ 2;
      _cachedToken = token;
      _tokenExpiresAt = now.add(Duration(seconds: safeLifetime));
      if (kDebugMode) debugPrint('[MA470 Exams QA] OAuth HTTP ${response.statusCode}; tokenPresent=true');
      return token;
    } on DioException catch (error) {
      throw StateError('TSS OAuth request failed (HTTP ${error.response?.statusCode ?? 'network error'})');
    }
  }

  static Uri _httpsEndpoint(String key) {
    final uri = Uri.tryParse(_env(key));
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw FormatException('$key must be HTTPS');
    }
    return uri;
  }

  static Map<String, dynamic> _jsonObject(Object? raw) {
    final value = raw is String ? jsonDecode(raw) : raw;
    if (value is! Map) throw const FormatException('Expected a JSON object');
    return Map<String, dynamic>.from(value);
  }

  static bool _isTsn(String value) => RegExp(r'^\d{9}$').hasMatch(value);

  static String _string(Object? value) => value == null ? '' : value.toString().trim();

  static String _env(String key) => dotenv.env[key]?.trim() ?? '';

  static _TssTerm _tssTerm(String termCode) {
    final match = RegExp(r'^(FA|WI|SP|S1|S2)(\d{2})$').firstMatch(termCode);
    if (match == null) throw const FormatException('Unsupported TSS term code');
    final session = match.group(1)!;
    final calendarYear = 2000 + int.parse(match.group(2)!);
    final academicYear = session == 'FA' ? calendarYear : calendarYear - 1;
    const names = {'FA': 'Fall', 'WI': 'Winter', 'SP': 'Spring', 'S1': 'Summer Session I', 'S2': 'Summer Session II'};
    return _TssTerm(
      calendarYear: calendarYear,
      academicYear: academicYear,
      sessionCode: session,
      name: names[session]!,
    );
  }
}

class _TssTerm {
  const _TssTerm({
    required this.calendarYear,
    required this.academicYear,
    required this.sessionCode,
    required this.name,
  });

  final int calendarYear;
  final int academicYear;
  final String sessionCode;
  final String name;
}

// MA-470 tss-finals-midterm END - direct TSS exam QA service
