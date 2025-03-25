import 'dart:io' show Platform;
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_scandit_plugin/flutter_scandit_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerDataProvider extends ChangeNotifier {
  ScannerDataProvider()  { initState(); notifyListeners(); }

  /// STATES
  bool isLoading = false;
  bool _didError = false;
  bool _hasScanned = false;
  bool hasSubmitted = false;
  bool _isDuplicate = false;
  bool _successfulSubmission = false;
  bool _isValidBarcode = true;
  String message = '';
  String? _barcode;
  List<String?> scannedCodes = [];
  late String _licenseKey;
  late String errorText;
  PermissionStatus? cameraPermissionsStatus;

  /// PROVIDERS
  late UserDataProvider _userDataProvider;

  /// SERVICES
  var _barcodeService = BarcodeService();
  late ScanditController _controller;

  void initState() {
    if (Platform.isIOS) {
      _licenseKey = dotenv.get('SCANDIT_NATIVE_LICENSE_IOS');
    } else if (Platform.isAndroid) {
      _licenseKey = dotenv.get('SCANDIT_NATIVE_LICENSE_ANDROID');
    }

    errorText = "Something went wrong, please try again.";
  }

  void resetDefaultStates() {
    _hasScanned = hasSubmitted = _didError = false;
    _successfulSubmission = isLoading = _isDuplicate = false;
    _isValidBarcode = true;
    scannedCodes.clear();
    notifyListeners();
  }

  Future requestCameraPermissions() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      notifyListeners();
    }

    if (cameraPermissionsStatus != status) {
      cameraPermissionsStatus = status;
      notifyListeners();
    }
  }

  Map<String, dynamic> createUserData() {
    return {
      'barcode': _barcode,
      'ucsdaffiliation': _userDataProvider.authenticationModel.ucsdaffiliation
    };
  }

  void verifyBarcodeScanning(BarcodeResult result) {
    isLoading = true;
    notifyListeners();
    scannedCodes.add(result.data);
    // currently scanning 3 consecutive times
    if (scannedCodes.length < 3) {
      _controller.resumeBarcodeScanning();
    } else {
      String? firstScan = scannedCodes.first;
      // if all scans are not the same, need to go into error state
      // otherwise, continue to handle normally
      if (scannedCodes.every((element) => element == firstScan)) {
        // ACCEPT STATE
        handleBarcodeResult(result);
      } else {
        // REJECT STATE
        _hasScanned = _didError = true;
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> handleBarcodeResult(BarcodeResult result) async {
    isLoading = _hasScanned = true;
    _barcode = result.data;

    try {
      final accessTokenExpiration = _userDataProvider.authenticationModel.expiration!;
      final nowTime = (DateTime.now().millisecondsSinceEpoch / 1000).round();
      final timeDiff = accessTokenExpiration - nowTime;
      final tokenExpired = timeDiff <= 0 ? true : false;
      final isLoggedIn = _userDataProvider.isLoggedIn;

      if (!isLoggedIn)
        throw ScannerError.loggedOut;

      // verify token is valid
      if (tokenExpired && !(await _userDataProvider.silentLogin()))
        throw ScannerError.invalidToken;

      final results = await _barcodeService.uploadResults({
        "Content-Type": "application/json",
        'Authorization':
            'Bearer ${_userDataProvider.authenticationModel.accessToken}'
      }, {
        'barcode': _barcode
      });

      if (results) {
        _successfulSubmission = true;
        _didError = false;
      }
      else if (_barcodeService.error!.contains(ErrorConstants.notAcceptable))
        throw ScannerError.notAcceptable;
      else if (_isDuplicate = _barcodeService.error!.contains(ErrorConstants.duplicateRecord))
        // test if blood screen
        throw RegExp(r'^ZAP').hasMatch(_barcode!)
          ? ScannerError.duplicateRecordBloodScreen
          : ScannerError.duplicateRecord;
      else if (_barcodeService.error!.contains(ErrorConstants.invalidMedia)) {
        _isValidBarcode = false;
        throw ScannerError.invalidMedia;
      }
      else
        throw ScannerError.barcodeError;
    }
    on ScannerError catch (e) {
      _successfulSubmission = false;
      _didError = true;
      errorText = e.msg;
    } catch (e) {
      // for errors not our own
      _successfulSubmission = false;
      _didError = true;
      errorText = ScannerError.unknownError.msg;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// SIMPLE SETTERS
  set controller(ScanditController value) => _controller = value;
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;

  /// SIMPLE GETTERS
  get didError => _didError;
  get hasScanned => _hasScanned;
  get isDuplicate => _isDuplicate;
  get isValidBarcode => _isValidBarcode;
  get successfulSubmission => _successfulSubmission;
  get barcode => _barcode;
  get licenseKey => _licenseKey;
}
