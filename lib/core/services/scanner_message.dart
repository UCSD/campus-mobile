import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/scanner_message.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ScannerMessageService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  final NetworkHelper _networkHelper = NetworkHelper();

  ScannerMessageModel _scannerMessageModel = ScannerMessageModel();

  Future<bool> fetchData(Map<String, String> headers) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await _networkHelper.authorizedFetch(dotenv.get('SCANNER_MESSAGE_ENDPOINT'), headers);

      /// parse data
      _scannerMessageModel = scannerMessageModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  String? get error => _error;
  ScannerMessageModel get scannerMessageModel => _scannerMessageModel;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
