import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/utils/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scandit_plugin/flutter_scandit_plugin.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ScanditScanner extends StatefulWidget {
  @override
  _ScanditScannerState createState() => _ScanditScannerState();
}

class _ScanditScannerState extends State<ScanditScanner> {
  String _message = '';
  ScanditController _controller;
  bool hasScanned;
  bool hasSubmitted;
  bool didError;
  String licenseKey;
  BarcodeService _barcodeService = new BarcodeService();
  UserDataProvider _userDataProvider;
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;
  String _barcode;
  String _errorText;
  bool isLoading;
  bool isDuplicate;
  bool successfulSubmission;
  bool isValidBarcode;
  PermissionStatus _cameraPermissionsStatus = PermissionStatus.undetermined;
  List<String> scannedCodes = new List<String>();

  Future _requestCameraPermissions() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (_cameraPermissionsStatus != status) {
      setState(() {
        _cameraPermissionsStatus = status;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    hasScanned = false;
    hasSubmitted = false;
    didError = false;
    successfulSubmission = false;
    isLoading = false;
    isDuplicate = false;
    isValidBarcode = true;
    _errorText = "Something went wrong, please try again.";

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _requestCameraPermissions());
  }

  @override
  Widget build(BuildContext context) {
    _userDataProvider = Provider.of<UserDataProvider>(context);
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      licenseKey = "SCANDIT_NATIVE_LICENSE_IOS_PH";
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      licenseKey = "SCANDIT_NATIVE_LICENSE_ANDROID_PH";
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(42),
        child: AppBar(
          centerTitle: true,
          title: const Text("Scanner"),
        ),
      ),
      body: !hasScanned ? renderScanner(context) : renderSubmissionView(),
      floatingActionButton: IconButton(
        onPressed: () {},
        icon: Container(),
      ),
    );
  }

  Widget renderScanner(BuildContext context) {
    if (_cameraPermissionsStatus == PermissionStatus.granted) {
      return (Stack(
        children: [
          Scandit(
              scanned: _verifyBarcodeScanning,
              onError: (e) => setState(() => _message = e.message),
              symbologies: [Symbology.CODE128, Symbology.DATA_MATRIX],
              onScanditCreated: (controller) => _controller = controller,
              licenseKey: licenseKey),
          Center(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.white),
                )),
          ),
          Center(child: Text(_message)),
        ],
      ));
    } else {
      return (Center(
        child: Text("Please allow camera permissions to scan your test kit."),
      ));
    }
  }

  Widget renderSubmissionView() {
    if (isLoading) {
      return (Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: SizedBox(
                height: 40, width: 40, child: CircularProgressIndicator()),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text("Submitting...please wait",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ));
    } else if (successfulSubmission) {
      return (renderSuccessScreen(context));
    } else if (didError) {
      return (renderFailureScreen(context));
    } else {
      return (renderFailureScreen(context));
    }
  }

  Widget renderFailureScreen(BuildContext context) {
    return (Column(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: (Column(children: <Widget>[
              ClipOval(
                child: Container(
                  color: (!isValidBarcode || isDuplicate)
                      ? Colors.orange
                      : Colors.red,
                  height: 75,
                  width: 75,
                  child: Icon(Icons.clear, color: Colors.white, size: 60),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Submission Failed!",
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(_errorText,
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                    "If this issue persists, please contact a healthcare professional.",
                    style: TextStyle(fontSize: 15)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: FlatButton(
                  padding: EdgeInsets.only(left: 32.0, right: 32.0),
                  onPressed: () {
                    scannedCodes.clear();
                    this.setState(() {
                      hasScanned = false;
                      hasSubmitted = false;
                      didError = false;
                      successfulSubmission = false;
                      isLoading = false;
                    });
                  },
                  child: Text(
                    "Try again",
                    style: TextStyle(fontSize: 18.0),
                  ),
                  color: lightButtonColor,
                  textColor: Colors.white,
                ),
              ),
            ])),
          ),
        )
      ],
    ));
  }

  Widget renderSuccessScreen(BuildContext context) {
    final dateFormat = new DateFormat('dd-MM-yyyy hh:mm:ss a');
    final String scanTime = dateFormat.format(new DateTime.now());

    return Column(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: (Column(children: <Widget>[
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Scan Submitted",
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              ),
              Text("Scan sent at: " + scanTime,
                  style: TextStyle(color: Theme.of(context).iconTheme.color)),
              Text("Scanned value: " + _barcode,
                  style: TextStyle(color: Theme.of(context).iconTheme.color)),
            ])),
          ),
        ),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                "Next Steps:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            )),
        ListView(
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
                title: Text(String.fromCharCode(0x2022) +
                    " Proceed to the next step in the testing process")),
            ListTile(
                title: Text(String.fromCharCode(0x2022) +
                    " Results are usually available within 24-36 hours.")),
            ListTile(title: buildChartText(context)),
            ListTile(
                title: Text(String.fromCharCode(0x2022) +
                    " If you are experiencing symptoms of COVID-19, stay in your residence and seek guidance from a healthcare provider.")),
            ListTile(
              title: Text(
                  String.fromCharCode(0x2022) +
                      " Help fight COVID-19. Add CA COVID Notify to your phone.",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline)),
              onTap: () {
                openLink("https://en.ucsd.edu");
              },
            ),
          ],
        ),
      ],
    );
  }

  void _verifyBarcodeScanning(BarcodeResult result) {
    scannedCodes.add(result.data);
    // currently scanning 3 consecutive times
    if (scannedCodes.length < 3) {
      _controller.resumeBarcodeScanning();
    } else {
      String firstScan = scannedCodes.first;
      // if all scans are not the same, need to go into error state
      // otherwise, continue to handle normally
      if (scannedCodes.every((element) => element == firstScan)) {
        // ACCEPT STATE
        _handleBarcodeResult(result);
      } else {
        // REJECT STATE
        this.setState(() {
          hasScanned = true;
          didError = true;
          isLoading = false;
        });
      }
    }
  }

  Text buildChartText(BuildContext context) {
    if (_userDataProvider.userProfileModel.classifications?.student ?? false) {
      return Text(String.fromCharCode(0x2022) +
          " You can view your results by logging in to MyStudentChart.");
    } else if (_userDataProvider.userProfileModel.classifications?.staff ??
        false) {
      return Text(String.fromCharCode(0x2022) +
          " You can view your results by logging in to MyUCSDChart.");
    }
  }

  Future<void> _handleBarcodeResult(BarcodeResult result) async {
    this.setState(() {
      hasScanned = true;
      _barcode = result?.data;
      isLoading = true;
    });

    try {
      var accessTokenExpiration =
          _userDataProvider?.authenticationModel?.expiration;
      var nowTime = (DateTime.now().millisecondsSinceEpoch / 1000).round();
      var timeDiff = accessTokenExpiration - nowTime;
      var tokenExpired = timeDiff <= 0 ? true : false;
      var isLoggedIn =
          Provider.of<UserDataProvider>(context, listen: false).isLoggedIn;
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
                'Bearer ${_userDataProvider?.authenticationModel?.accessToken}'
          }, {
            'barcode': _barcode
          });

          if (results) {
            this.setState(() {
              successfulSubmission = true;
              didError = false;
              isLoading = false;
            });
          } else {
            this.setState(() {
              successfulSubmission = false;
              didError = true;
              isLoading = false;
            });

            if (_barcodeService.error
                .contains(ErrorConstants.duplicateRecord)) {
              this.setState(() {
                _errorText = ScannerConstants.duplicateRecord;
                isDuplicate = true;
              });
            } else if (_barcodeService.error
                .contains(ErrorConstants.invalidMedia)) {
              this.setState(() {
                _errorText = ScannerConstants.invalidMedia;
                isValidBarcode = false;
              });
            } else {
              this.setState(() {
                _errorText = ScannerConstants.barcodeError;
              });
            }
          }
        } else {
          this.setState(() {
            successfulSubmission = false;
            didError = true;
            isLoading = false;
            _errorText = ScannerConstants.invalidToken;
          });
        }
      } else {
        this.setState(() {
          successfulSubmission = false;
          didError = true;
          isLoading = false;
          _errorText = ScannerConstants.loggedOut;
        });
      }
    } catch (e) {
      this.setState(() {
        successfulSubmission = false;
        didError = true;
        isLoading = false;
        _errorText = ScannerConstants.unknownError;
      });
    }
  }
}
