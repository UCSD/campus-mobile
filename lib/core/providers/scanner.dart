import 'dart:io' show Platform;

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scandit_plugin/flutter_scandit_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerDataProvider extends ChangeNotifier {
  ScannerDataProvider() {
    ///DEFAULT STATES
    isLoading = false;

    ///INITIALIZE SERVICES
    _barcodeService = BarcodeService();
  }

  bool? _hasScanned;
  bool? hasSubmitted;
  bool? _didError;
  String? message = '';

  String? _licenseKey;
  late BarcodeService _barcodeService;
  late UserDataProvider _userDataProvider;

  String? _barcode;
  late bool isLoading;
  bool? _isDuplicate;
  bool? _successfulSubmission;
  bool? _isValidBarcode;
  late String errorText;
  PermissionStatus? cameraPermissionsStatus;
  ScanditController? _controller;
  List<String?> scannedCodes = [];

  void initState() {
    if (Platform.isIOS) {
      _licenseKey = 'SCANDIT_NATIVE_LICENSE_IOS_PH';
    } else if (Platform.isAndroid) {
      _licenseKey = 'SCANDIT_NATIVE_LICENSE_ANDROID_PH';
    }

    errorText = "Something went wrong, please try again.";
  }

  void setDefaultStates() {
    _hasScanned = false;
    hasSubmitted = false;
    _didError = false;
    _successfulSubmission = false;
    isLoading = false;
    _isDuplicate = false;
    _isValidBarcode = true;
    scannedCodes = [];
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
      'ucsdaffiliation': _userDataProvider.authenticationModel!.ucsdaffiliation
    };
  }

  void verifyBarcodeScanning(BarcodeResult result) {
    isLoading = true;
    notifyListeners();
    scannedCodes.add(result.data);
    // currently scanning 3 consecutive times
    if (scannedCodes.length < 3) {
      _controller!.resumeBarcodeScanning();
    } else {
      String? firstScan = scannedCodes.first;
      // if all scans are not the same, need to go into error state
      // otherwise, continue to handle normally
      if (scannedCodes.every((element) => element == firstScan)) {
        // ACCEPT STATE
        handleBarcodeResult(result);
      } else {
        // REJECT STATE
        _hasScanned = true;
        _didError = true;
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> handleBarcodeResult(BarcodeResult result) async {
    _hasScanned = true;
    _barcode = result.data;
    isLoading = true;

    try {
      int accessTokenExpiration =
          _userDataProvider.authenticationModel?.expiration! as int;
      var nowTime = (DateTime.now().millisecondsSinceEpoch / 1000).round();
      var timeDiff = accessTokenExpiration - nowTime;
      var tokenExpired = timeDiff <= 0 ? true : false;
      var isLoggedIn = _userDataProvider.isLoggedIn;
      var validToken = false;

      if (isLoggedIn) {
        if (tokenExpired) {
          if (await _userDataProvider.silentLogin()) {
            validToken = true;
          }
        } else {
          validToken = true;
        }

        if (validToken) {
          var results = await _barcodeService.uploadResults({
            "Content-Type": "application/json",
            'Authorization':
                'Bearer ${_userDataProvider.authenticationModel?.accessToken}'
          }, {
            'barcode': _barcode
          });

          if (results) {
            _successfulSubmission = true;
            _didError = false;
            isLoading = false;
          } else {
            _successfulSubmission = false;
            _didError = true;
            isLoading = false;

            if (_barcodeService.error!.contains(ErrorConstants.notAcceptable)) {
              errorText = ScannerConstants.notAcceptable;
              _isValidBarcode = false;
            } else if (_barcodeService.error!
                .contains(ErrorConstants.duplicateRecord)) {
              RegExp bloodScreenTest = RegExp(r'^ZAP');
              bool isBloodScreen = bloodScreenTest.hasMatch(_barcode!);

              errorText = isBloodScreen
                  ? ScannerConstants.duplicateRecordBloodScreen
                  : ScannerConstants.duplicateRecord;
              _isDuplicate = true;
            } else if (_barcodeService.error!
                .contains(ErrorConstants.invalidMedia)) {
              errorText = ScannerConstants.invalidMedia;
              _isValidBarcode = false;
            } else {
              errorText = ScannerConstants.barcodeError;
            }
          }
        } else {
          _successfulSubmission = false;
          _didError = true;
          isLoading = false;
          errorText = ScannerConstants.invalidToken;
        }
      } else {
        _successfulSubmission = false;
        _didError = true;
        isLoading = false;
        errorText = ScannerConstants.loggedOut;
      }
    } catch (e) {
      _successfulSubmission = false;
      _didError = true;
      isLoading = false;
      errorText = ScannerConstants.unknownError;
    }
    notifyListeners();
  }

  /// Simple setters and getters
  set controller(ScanditController? value) {
    _controller = value;
  }

  set userDataProvider(UserDataProvider value) => _userDataProvider = value;

  String? get barcode => _barcode;
  bool? get didError => _didError;
  bool? get hasScanned => _hasScanned;
  String? get licenseKey => _licenseKey;
  bool? get isDuplicate => _isDuplicate;
  bool? get isValidBarcode => _isValidBarcode;
  bool? get successfulSubmission => _successfulSubmission;
}
