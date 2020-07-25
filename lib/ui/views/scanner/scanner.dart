import 'dart:async';
import 'dart:io' show Platform;

import 'package:barcode_scan/barcode_scan.dart';
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/core/services/barcode_service.dart';


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
  bool _submitted = false;
  BuildContext scaffoldContext;
  var ucsdAffiliation = "";
  var accessToken = "";

  set userDataProvider(UserDataProvider value) => _userDataProvider = value;
  //all types of barcodes this library supports
  //will only support the required format when released, supports all for testing purposes
  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  List<BarcodeFormat> selectedFormats = [..._possibleFormats];

  @override
  // ignore: type_annotate_public_apis
  initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      _numberOfCameras = await BarcodeScanner.numberOfCameras;
      setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text("Test Kit Scanner"),
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
              !_hasScanned
              ? buildStartScan()
              : buildSubmitScan()
            ],
          ),
        ),
      )
   );
  }

  Widget buildStartScan() {
    return(
        Center(
          child: OutlineButton(
            borderSide: BorderSide(color: Colors.white),
            onPressed: scan,
            child: Text("Start scan", style: TextStyle(color: Colors.white)),
          ),
        )
    );
  }

  Widget buildSubmitScan() {
    _userDataProvider = Provider.of<UserDataProvider>(context);
    this.setState(() {
      ucsdAffiliation = _userDataProvider.authenticationModel.ucsdaffiliation;
      accessToken = _userDataProvider.authenticationModel.accessToken;
    });
    return(
        Column(
          children: [
            Text(_barcode, style: TextStyle(color: Colors.white)),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: OutlineButton(
                borderSide: BorderSide(color: Colors.white),
                onPressed: submit,
                child: Text("Submit", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        )

        );
  }

    Map<String,dynamic> createUserData() {
    print("affiliation: " + ucsdAffiliation.toString());
    return{
      'barcode': _barcode,
      'ucsdaffiliation': ucsdAffiliation
    };
  }

  Future<void> submit() async {
    print("in submit");
    var headers = {
      "Content-Type": "application/json",
      'Authorization':
      'Bearer ${accessToken}'
    };
    var data = createUserData();
    print(headers.toString());
    print(data.toString());
//    var results = await _barcodeService.uploadResults(headers, data);
//    if (results) {
//      _submitted = true;
//    } else {
//      if (_barcodeService.error.contains(ErrorConstants.invalidBearerToken)) {
//        await _userDataProvider.refreshToken();
//      } else {
//      }
//      _submitted = true;
//    }
//    setState(() {});
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
      print("here");
      var result = await BarcodeScanner.scan(options: options);
      print("after result");
      print(result.rawContent);
      //if(result.rawContent != null && result.rawContent.isNotEmpty) {
      setState(() {
        scanResult = result;
        _barcode = result.rawContent;
        _hasScanned = true;
      }); //}
      print("barcode: " + _barcode);
      print("has scanned " + _hasScanned.toString());
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