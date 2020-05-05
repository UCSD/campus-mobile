import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/services/barcode_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class BarcodeDataProvider extends ChangeNotifier {
  BarcodeDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _barcodeService = BarcodeService();
    _cameraState = Plugins.FrontCamera;
    _submitState = ButtonText.SubmitButtonActive;
    _qrText = "";
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;
  String _qrText;

  int _timeScanned;
  String _cameraState;
  String _submitState;

  ///MODELS
  UserDataProvider _userDataProvider;
  QRViewController _controller;

  ///SERVICES
  BarcodeService _barcodeService;

  void onQRViewCreated(QRViewController controller) {
    this._controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (_qrText != scanData) {
        _qrText = scanData;
        _timeScanned = DateTime.now().millisecondsSinceEpoch;
        _submitState = ButtonText.SubmitButtonActive;
        notifyListeners();
      }
    });
  }

  Future<Map<String, dynamic>> createUserData() async {
    final pattern = RegExp('[BGJMU]');
    var pid = "";
    if (_userDataProvider.authenticationModel.ucsdaffiliation
        .contains(pattern)) {
      pid = _userDataProvider.authenticationModel.pid;
    }
    return {
      'barcode': _qrText,
      'uscdaffiliation': _userDataProvider.authenticationModel.ucsdaffiliation
    };
  }

  void submitBarcode() async {
    if (_submitState != ButtonText.SubmitButtonInactive) {
      _isLoading = true;
      _submitState = ButtonText.SubmitButtonInactive;
      notifyListeners();
      var userData = await createUserData();
      var headers = {
        "Content-Type": "application/json",
        'Authorization':
            'Bearer ${_userDataProvider.authenticationModel.accessToken}'
      };
      var results = await _barcodeService.uploadResults(headers, userData);
      if (results) {
        _submitState = ButtonText.SubmitButtonReceived;
      } else {
        await _userDataProvider.refreshToken();
        _submitState = ButtonText.SubmitButtonTryAgain;
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  void disposeController() {
    _controller.dispose();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  String get qrText => _qrText;
  String get cameraState => _cameraState;
  String get submitState => _submitState;

  ///Setters
  set userDataProvider(UserDataProvider value) {
    _userDataProvider = value;
  }
}
