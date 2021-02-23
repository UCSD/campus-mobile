import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/scanner_message.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/barcode.dart';
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
      licenseKey = "AWZPNIuBH8uOAj5WPTefVbAXwJZoCGikFkOOoRJADibsLbKyxEmxtKtde2Vbcn+tt3dhyaxjwO05RsNOJG6qEFFnsNTWRCpbJBStZctoZG6UYhICzXWawCx0EmmULQQy5xwn1rwN7KPROh5hj/QFyQyskdZs7ltbOAfSMfvTe63o5nARzGe2nPgz3C6KGgJraGyK9BB3vs0Gg2JDpJk1MmFAAs8XE59UTxGmCHfOTnY8GEOjtGrcy52HnjsqDa++XGbJHqHxQ350NZDqbi3X+zd7OQNGZ6UjarkdsXODx7mNOzfgDtVzvyF7TOJsyWvyauP2QSXutnShkZP0+BqJiK3KAfrhRSK3BTN/9CHNAcWBRvxFzkqAc3zvkXJazRxRBDIBxV+gYESCbK9/mv9eB93M79uVTlDrTGXFj3iJbZ8fuqEhXQivQy8yGnqoxaVcaBQsltn2uOa+lzsCGuprBjrn8MlBTItcStidxAEd5rhDQ6h37/+ZeYLBc8Mz/Qvd+LHfY2tJricL+x7UuwBq/wh2/f6mwIKvjeVNR6ij1ugJPchKapCG7PXxosByKW9Iz/NF8+ItrIxlTHQwSj0N3xtlA26BKosHyl7r4Se5N2RB9WQWL7Ql5IDR2kzVg7dmKG1NWimZbCSA9P6XwWDJ2iSLMSsiEofQPM9upIzkW0xlwe1JqvtXJtXkkaEmFsNAN/9nrMSzmiiEWUHF23IFtLUMX0uXaw/5voG6wmzUzKza/pwpWzt6BWwKE9OOiVK59nNMMlOLPLHe8MOeBVdn7CSUugVcx9X2b53mQX/NE//dQmFG/377G1iK";
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      licenseKey = "AcSv56yBOHYQPJDNviC89nU41XcdNK3kmEqQvPtTx6usVyIvbmkbs8d0dz2ecugTsnaqBdwvK17sZghABykr/JpQ1IP8VKA+cAoZCrxwpo70HKTDJydnIrw17B9zCb1kO2qm1jlfCCq+HMRcEIB/ZrHDu/hNCilVw7aOo6+lqzOqSjVaek8rKUZZnsQ6SQnDYi4+XG2n5r9RVp5DZogkduBMGr2U2ZG73Uj/8I6ZgvQAwiMOkP0rDP7oME7KwSrzjZVQbOgb7JC3PvrHPsxq0CmaXCsOBHpQ2Ri0JRUgvSt78JBbObmqhj7pHSlrCvkzIkxDSGi+s1x0hNktVuaUXcqcEIu3GpcDmEER++QUX56zjn3BF0nM5ecjx+03DyRjEJ79xmIvUn/9kdOTWCVfQOr2Vu9ElJ02uaGr0l29NZW39T5ZkYjSqzwt+qnV3AT+GIk+r7jH62pcJK/GXfSeQNYVNwdUVr/iJSbwWVFGvhrpgQds/hoB7dNlQ/YpUSffE5aogL/Idlp6nH3t364p2enRAh7B3uJx+e/DXck72J8BycSJrl4N4J8F0AFaXI3opppIRc9/fXaLOunUrJcMULDRhkkzXRFoKszPJjqtRNPe/1+VFgwbS0LXB/zFt9FM4E04RC/ZHPA3HwT/PbpnoPdPoarCD1M4IfwnEsXVGzVSj6Q+TZHubazSkQszQX/qIhpxwW0oGJRYSwSXygwhqfrqvi4fYOmRSox1mnngyOfLtJMZU29i/mcpO1Ib7Tcyer90V0GvnkyQ0wq9hFUOhS6nVRIJXcX68mYIQDDo";
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
    ScannerMessageDataProvider _scannerMessageDataProvider = ScannerMessageDataProvider();
    _scannerMessageDataProvider.fetchData();
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
