import 'dart:convert';

import 'package:campus_mobile_experimental/core/models/authentication.dart';
import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/term.dart';
import 'package:campus_mobile_experimental/core/services/tss_booking_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// MA-470 tss-classes START - QA OAuth and student-filtered Booking client
/// Local QA proof only
/// Flutter bundles dotenv including TSS secret
/// Never distribute or use in production
class TssAcademicHistoryClient {
  TssAcademicHistoryClient({Dio? dio})
    : _dio =
          dio ??
          Dio(BaseOptions(connectTimeout: const Duration(seconds: 12), receiveTimeout: const Duration(seconds: 20)));

  final Dio _dio;
  String? _cachedToken;
  DateTime? _tokenExpiresAt;

  bool get enabled => _env('TSS_DIRECT_QA_ENABLED').toLowerCase() == 'true';

  /// Anonymous preview requires local student override
  /// Never reads unauthenticated account ID
  bool get anonymousQaPreviewEnabled =>
      enabled &&
      _env('TSS_DIRECT_QA_ANONYMOUS_PREVIEW').toLowerCase() == 'true' &&
      _isTsn(_env('TSS_STUDENT_NUMBER_OVERRIDE'));

  bool get hasStudentOverride => enabled && _isTsn(_env('TSS_STUDENT_NUMBER_OVERRIDE'));

  AcademicTermModel? get overrideTerm {
    if (!enabled || _env('TSS_TERM_CODE_OVERRIDE').isEmpty) return null;
    final termCode = _env('TSS_TERM_CODE_OVERRIDE');
    final term = _tssTerm(termCode);
    return AcademicTermModel(termName: '${term.name} ${term.calendarYear}', termCode: termCode);
  }

  /// QA MobileAuthentication currently returns TSN in numeric `pid`
  /// Keep compatibility read isolated and never send A-number to TSS
  String? qaStudentNumber(AuthenticationModel authentication) {
    final override = _env('TSS_STUDENT_NUMBER_OVERRIDE');
    if (override.isNotEmpty) return _isTsn(override) ? override : null;
    final currentQaValue = authentication.pid?.trim() ?? '';
    return _isTsn(currentQaValue) ? currentQaValue : null;
  }

  AcademicTermModel selectedTerm(AcademicTermModel currentTerm) {
    final override = _env('TSS_TERM_CODE_OVERRIDE');
    if (override.isEmpty) return currentTerm;
    final term = _tssTerm(override);
    return AcademicTermModel(termName: '${term.name} ${term.calendarYear}', termCode: override);
  }

  Future<ClassScheduleModel> classesForStudent(String studentNumber, String termCode) async {
    if (!enabled) throw StateError('Direct TSS QA mode is disabled.');
    if (!_isTsn(studentNumber)) {
      throw const FormatException('A valid TSN is required for TSS classes.');
    }
    final term = _tssTerm(termCode);
    if (kDebugMode)
      debugPrint('[MA470 TSS QA] booking fetch start; term=$termCode; studentOverride=$hasStudentOverride');
    final token = await _serviceToken();
    final endpoint = _env('TSS_ACADEMIC_HISTORY_BOOKING_ENDPOINT');
    final baseUri = Uri.tryParse(endpoint);
    if (baseUri == null || baseUri.scheme != 'https' || baseUri.host.isEmpty) {
      throw const FormatException('TSS Booking endpoint must be HTTPS.');
    }

    final filter =
        "studentNumber eq '$studentNumber' and academicYear eq '${term.academicYear}' and sessionCode eq '${term.sessionCode}' and bookingStatusCode eq '1'";
    final query = {
      r'$filter': filter,
      r'$select':
          'studentNumber,moduleCode,moduleName,academicYear,sessionCode,programTypeCode,academicLevel,bookingStatusCode,creditsAttempted,appraisalTemplateName',
      r'$expand': r'grade,events($expand=instructors,meetings,meetingExceptions)',
      r'$top': '100',
    };
    var pageUri = baseUri.replace(queryParameters: query);
    final bookings = <dynamic>[];

    for (var page = 0; page < 5; page++) {
      final response = await _getBookingPage(pageUri, token);
      final rows = response['value'];
      if (rows is! List) {
        throw const FormatException('TSS Booking response has no value array.');
      }
      bookings.addAll(rows);
      if (kDebugMode) debugPrint('[MA470 TSS QA] booking page ${page + 1}: HTTP 200; rows=${rows.length}');
      final nextLink = response['@odata.nextLink'];
      if (nextLink == null || nextLink.toString().isEmpty) {
        return classScheduleModelFromTssBooking({'value': bookings}, termCode);
      }
      final nextUri = pageUri.resolve(nextLink.toString());
      if (nextUri.scheme != baseUri.scheme ||
          nextUri.host != baseUri.host ||
          nextUri.port != baseUri.port ||
          !nextUri.path.startsWith(baseUri.path)) {
        throw const FormatException('TSS Booking pagination target is invalid.');
      }
      pageUri = nextUri;
    }
    throw const FormatException('TSS Booking pagination exceeded the QA limit.');
  }

  Future<Map<String, dynamic>> _getBookingPage(Uri uri, String token) async {
    try {
      final response = await _dio.getUri<dynamic>(
        uri,
        options: Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'}),
      );
      return _jsonObject(response.data);
    } on DioException catch (error) {
      if (kDebugMode) {
        debugPrint('[MA470 TSS QA] booking failed: type=${error.type}; status=${error.response?.statusCode ?? 'none'}');
      }
      throw StateError('TSS Booking request failed (HTTP ${error.response?.statusCode ?? 'network error'}).');
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
      throw StateError('Direct TSS QA OAuth configuration is incomplete.');
    }
    final basic = base64Encode(utf8.encode('$clientId:$clientSecret'));
    try {
      if (kDebugMode) debugPrint('[MA470 TSS QA] OAuth token request start');
      final response = await _dio.postUri<dynamic>(
        tokenEndpoint,
        data: 'grant_type=client_credentials',
        options: Options(headers: {'Authorization': 'Basic $basic'}, contentType: Headers.formUrlEncodedContentType),
      );
      final body = _jsonObject(response.data);
      final token = body['access_token']?.toString() ?? '';
      if (token.isEmpty) {
        throw const FormatException('TSS OAuth response has no access token.');
      }
      final expiresIn = int.tryParse(body['expires_in']?.toString() ?? '') ?? 300;
      final safeLifetime = expiresIn > 90 ? expiresIn - 60 : expiresIn ~/ 2;
      _cachedToken = token;
      _tokenExpiresAt = now.add(Duration(seconds: safeLifetime));
      if (kDebugMode) debugPrint('[MA470 TSS QA] OAuth token response: HTTP ${response.statusCode}; tokenPresent=true');
      return token;
    } on DioException catch (error) {
      if (kDebugMode) {
        debugPrint('[MA470 TSS QA] OAuth failed: type=${error.type}; status=${error.response?.statusCode ?? 'none'}');
      }
      throw StateError('TSS OAuth request failed (HTTP ${error.response?.statusCode ?? 'network error'}).');
    }
  }

  static Map<String, dynamic> _jsonObject(Object? raw) {
    final value = raw is String ? jsonDecode(raw) : raw;
    if (value is! Map) throw const FormatException('Expected a JSON object.');
    return Map<String, dynamic>.from(value);
  }

  static bool _isTsn(String value) => RegExp(r'^\d{9}$').hasMatch(value);

  static String _env(String key) => dotenv.env[key]?.trim() ?? '';

  static _TssTerm _tssTerm(String termCode) {
    final match = RegExp(r'^(FA|WI|SP|S1|S2)(\d{2})$').firstMatch(termCode);
    if (match == null) throw const FormatException('Unsupported TSS term code.');
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

// MA-470 tss-classes END - QA OAuth and student-filtered Booking client
