import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/scanner_message.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ScannerMessageService {
  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  /// MODELS
  ScannerMessageModel _scannerMessageModel = ScannerMessageModel();

  /// SERVICES
  final _networkHelper = NetworkHelper();

  Future<bool> fetchData(Map<String, String> headers) async {
    _error = null; _isLoading = true;
    try {
      /// fetch data
      String _response =
          await _networkHelper.authorizedFetch(dotenv.get('SCANNER_MESSAGE_ENDPOINT'), headers);

      /// parse data
      _scannerMessageModel = scannerMessageModelFromJson(_response);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// SIMPLE GETTERS
  get error => _error;
  get isLoading => _isLoading;
  get lastUpdated => _lastUpdated;
  ScannerMessageModel get scannerMessageModel => _scannerMessageModel;
}
