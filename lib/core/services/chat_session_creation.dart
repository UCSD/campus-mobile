import 'dart:async';
import 'dart:convert';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/chat_session.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

/// Service responsible for creating a chat session with TritonGPT backend via WSO2
class ChatSessionService {
  /// STATES
  final UserDataProvider _userDataProvider;
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  bool _hasRetried = false;

  /// Default headers for POST requests
  final Map<String, String> headers = {
    "accept": "application/json",
    "content-type": "application/json",
  };

  ChatSessionService(this._userDataProvider);

  /// Creates a new chat session by sending a POST request to WSO2
  Future<CreateChatSessionID?> createChatSession() async {
    _error = null;
    _isLoading = true;

    try {
      // headers['Authorization'] =
      //     'Bearer eyJ4NXQiOiJNR1UzWVRkbU1XUmpZemxpTTJZNFpqY3hORGM1TkRNMlkyWTVNMlF5TlRZek9EZGhaV1kyTWciLCJraWQiOiJZVFZtT1RCbU1tTXpOemRtWVRBeU5UWmpNbVk1WlRReU56VXdaamN5TnpZME4yUTVPR1U1TURJNFlXWmpaamcxTnpnNE5UazVNMlF3TUdRd1ltSTNPQV9SUzI1NiIsInR5cCI6ImF0K2p3dCIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiJhbncwNzUiLCJhdXQiOiJBUFBMSUNBVElPTiIsImF1ZCI6IkdtVEE4ZmhCR0o4V3hxVGNBemdMdlRYbEY1b2EiLCJuYmYiOjE3Njg1MjAzMTcsImF6cCI6IkdtVEE4ZmhCR0o4V3hxVGNBemdMdlRYbEY1b2EiLCJzY29wZSI6ImRlZmF1bHQiLCJpc3MiOiJodHRwczpcL1wvYXBpLXFhLnVjc2QuZWR1XC9vYXV0aDJcL3Rva2VuIiwicmVhbG0iOnsic2lnbmluZ190ZW5hbnQiOiJjYXJib24uc3VwZXIifSwiZXhwIjoxNzY4NTIzOTE3LCJpYXQiOjE3Njg1MjAzMTcsImp0aSI6IjM0ZTZiN2IyLTQ2MWMtNDk5OS1hMmUzLTk2ZTQ5NzQ1Y2RhZCJ9.JXgyX1Pm8H5_dkDIoySzypVB_nStfNQhzaIajSowVUXdfGwngWUdFIj71cNjgWmrUbNttAUEPC6fFXbjavhuhTgBDIUBPnqJq8V5YYFFYkxvuVVL-4b6XCnleP6zKGIiaZorvfgoFI0GAtbNzu-7bL-vqTW48VQcP6_VG_5T89XM3a_NM6hVFOUP-16D1W1PLn8gkIPTnmlPJ4lB46soOBbx8iaH_-ZoRiO6wwKuD29jsnXOz40pfhsdNMto9OSVyNLC9zrRE4wQW3OZMjvBO-Fa6YUM7XecGITDkzRc05aTjeZu5ZckE4UokRsMVy1DVYSphch-HGnM0fElvpoDBw';
      headers['Authorization'] = 'Bearer ${_userDataProvider.authenticationModel.accessToken}';
      print('headers $headers');

      // String createChatSessionEndpoint = dotenv.get('CHAT_CREATE_SESSION_ENDPOINT');
      const String createChatSessionEndpoint =
          "https://api-qa.ucsd.edu:8243/tgpt-mobileproxy/1.0.0/chat/create-chat-session";

      print('createChatSessionEndpoint $createChatSessionEndpoint');

      /// Build request payload
      final ChatSessionCreationRequest request = ChatSessionCreationRequest(personaId: 1);

      final String requestBody = json.encode(request.toJson());
      print("requestBody $requestBody");

      /// Send POST
      final _response = await NetworkHelper.authorizedPost(
        createChatSessionEndpoint,
        headers,
        requestBody,
      );

      print("_response $_response");

      final CreateChatSessionID chatSessionId = CreateChatSessionID.fromJson(_response);

      return chatSessionId;
    } catch (e) {
      print('string 1 $e');

      // Print DioException details
      if (e is DioException) {
        print('status: ${e.response?.statusCode}');
        print('data: ${e.response?.data}');
      }

      if (!_hasRetried && e.toString().contains("401")) {
        _hasRetried = true;

        final bool refreshed = await NetworkHelper.getNewToken(headers);

        if (refreshed) {
          _lastUpdated = DateTime.now();
          return await createChatSession(); // retry once
        } else {
          _hasRetried = false;
          return null;
        }
      }

      _error = e.toString();
      _hasRetried = false; // reset for next top-level call
      return null;
    } finally {
      _isLoading = false;
    }
  }

  /// GETTERS
  String? get error => _error;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
