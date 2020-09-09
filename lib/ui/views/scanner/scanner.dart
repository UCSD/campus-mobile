import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/services/barcode_service.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Scanner extends StatefulWidget {
  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  ScanResult scanResult;
  BarcodeService _barcodeService;
  UserDataProvider _userDataProvider;
  final _flashOnController = TextEditingController(text: "Flash on");
  final _flashOffController = TextEditingController(text: "Flash off");
  final _cancelController = TextEditingController(text: "Cancel");

  var _aspectTolerance = 0.00;
  var _numberOfCameras = 0;
  var _selectedCamera = -1;
  var _useAutoFocus = true;
  var _autoEnableFlash = false;
  bool _hasScanned = false;
  String _barcode = "";
  bool _successfulSubmission = false;
  BuildContext scaffoldContext;
  var ucsdAffiliation = "";
  var accessToken = "";
  bool _isLoading = false;
  bool _successfulResponse = false;
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;
  //all types of barcodes this library supports
  //will only support the required format when released, supports all for testing purposes
  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  List<BarcodeFormat> selectedFormats = [..._possibleFormats];

  @override
  // ignore: type_annotate_public_apis
  initState() {
    _barcodeService= BarcodeService();
    super.initState();
    _barcodeService = BarcodeService();
    Future.delayed(Duration.zero, () async {
      _numberOfCameras = await BarcodeScanner.numberOfCameras;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Scanner"),
          backgroundColor: Color(0xFF182B49),
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          elevation: 0.0,
        ),
        body: Container(
          color: ColorPrimary,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                !_isLoading? (!_hasScanned ? buildStartScan() : buildSubmitScan()): CircularProgressIndicator()
              ],
            ),
          ),
        ));
  }

  Widget buildStartScan() {
    return (Center(
      child: OutlineButton(
        borderSide: BorderSide(color: Colors.white),
        onPressed: scan,
        child: Text("Start scan", style: TextStyle(color: Colors.white)),
      ),
    ));
  }

  Widget buildSubmitScan() {
    _userDataProvider = Provider.of<UserDataProvider>(context);
    this.setState(() {
      ucsdAffiliation = _userDataProvider.authenticationModel.ucsdaffiliation;
      accessToken = _userDataProvider.authenticationModel.accessToken;
    });
    return (Column(
      children: [
        buildScannedText(),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: buildCorrespondingButton(),
        )
      ],
    ));
  }

  Widget buildCorrespondingButton() {
    // 'Cancel' pressed case
    return (_barcode == null || _barcode.isEmpty)? OutlineButton(
      borderSide: BorderSide(color: Colors.white),
      onPressed: scan,
      child: Text("Start scan", style: TextStyle(color: Colors.white)),
    ):
    // Successful submission case
    (_successfulSubmission? FlatButton(
      color: Colors.grey,
      onPressed: null,
      disabledColor: Colors.grey,
      child: Text("Received", style: TextStyle(color: Colors.white)),
    ):
    // Default submit
    OutlineButton(
      borderSide: BorderSide(color: Colors.white),
      onPressed: submit,
      disabledTextColor: Colors.white,
      child: Text("Submit Scan", style: TextStyle(color: Colors.white))));
  }

  Text buildScannedText() => (_barcode == null || _barcode.isEmpty)?Text('Nothing has been scanned yet.', style: TextStyle(color: Colors.white)) : submissionText();

  Text submissionText() => (!_successfulSubmission && _successfulResponse ?Text("Submission failed, please try again") :Text( (_successfulSubmission && _successfulResponse?"Submission successful \u2713":"Scan successful"), style: TextStyle(color: Colors.white)));

  Map<String, dynamic> createUserData() {
    print("affiliation: " + ucsdAffiliation.toString());
    return {'barcode': _barcode, 'ucsdaffiliation': ucsdAffiliation};
  }

  Future<void> submit() async {
    print("in submit");
    var headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${accessToken}'
    };
    var data = createUserData();
    setState(() {
      _isLoading = true;
    });
    var results = await _barcodeService.uploadResults(headers, data);

    if (results) {
      _isLoading = false;
      _successfulSubmission = true;
    } else {
      _successfulSubmission = false;
      if (_barcodeService.error.contains(ErrorConstants.invalidBearerToken)) {
        await _userDataProvider.refreshToken();
      } else {

      }
      //_submitted = true;
    }
    setState(() {
      _successfulResponse = true;
    });
  }

  Future scan() async {
    print("HERE");
    try {
      var options = ScanOptions(
        strings: {
          "cancel": _cancelController.text,
          "flash_on": _flashOnController.text,
          "flash_off": _flashOffController.text,
        },
        restrictFormat: selectedFormats,
        useCamera: _selectedCamera,
        autoEnableFlash: _autoEnableFlash,
        android: AndroidOptions(
          aspectTolerance: _aspectTolerance,
          useAutoFocus: _useAutoFocus,
        ),
      );
      var result = await BarcodeScanner.scan(options: options);
   
      setState(() {
        scanResult = result;
        _barcode = result.rawContent;
        _hasScanned = true;
      }); //}
     
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'The user did not grant the camera permission!';
        });
      } else {
        result.rawContent = 'Unknown error: $e';
      }
      setState(() {
        scanResult = result;
      });
    }
  }
}
