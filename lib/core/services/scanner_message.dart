import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/scanner_message.dart';

class ScannerMessageService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  final NetworkHelper _networkHelper = NetworkHelper();
  final String endpoint =
      'https://api-qa.ucsd.edu:8243/scandata/2.0.0/scanData/myrecentscan';

  ScannerMessageModel _scannerMessageModel = ScannerMessageModel();

  Future<bool> fetchData(Map<String, String> headers) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await _networkHelper.authorizedFetch(endpoint, headers);

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
