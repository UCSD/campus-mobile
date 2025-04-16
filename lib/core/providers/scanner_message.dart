import 'package:campus_mobile_experimental/core/models/scanner_message.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/scanner_message.dart';
import 'package:flutter/material.dart';

class ScannerMessageDataProvider extends ChangeNotifier {
  /// STATES
  bool _isLoading = false;
  String? _error;

  /// MODELS
  ScannerMessageModel _scannerMessageModel = ScannerMessageModel();

  /// PROVIDERS
  late UserDataProvider _userDataProvider;

  /// SERVICES
  var _scannerMessageService = ScannerMessageService();

  void fetchData() async {
    // forcing fetchData() to be executed async
    await Future.delayed(Duration.zero);
    _isLoading = true; _error = null;
    notifyListeners();

    /// Verify that user is logged in
    if (_userDataProvider.isLoggedIn) {
      /// Initialize header
      final Map<String, String> header = {
        'Authorization':
            'Bearer ${_userDataProvider.authenticationModel.accessToken}'
      };
      await _scannerMessageService.fetchData(header);
      _scannerMessageModel = _scannerMessageService.scannerMessageModel;
    } else {
      /// Error Handling
      _error = _scannerMessageService.error.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// SIMPLE SETTERS
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;

  /// SIMPLE GETTERS
  get isLoading => _isLoading;
  get error => _error;
  ScannerMessageModel get scannerMessageModel => _scannerMessageModel;
  ScannerMessageService get scannerMessageService => _scannerMessageService;
}
