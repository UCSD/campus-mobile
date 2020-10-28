
import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/services/barcode_service.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scandit_plugin/flutter_scandit_plugin.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';


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
  var ucsdAffiliation = "";
  var accessToken = "";
  String _barcode;
  String _errorText;
  bool isLoading;
  bool successfulSubmission;

  @override
  void initState() {
    super.initState();
    hasScanned = false;
    hasSubmitted = false;
    didError = false;
    successfulSubmission = false;
    isLoading = false;
    _errorText = "Something went wrong, please try again.";
  }

  @override
  Widget build(BuildContext context) {
    _userDataProvider = Provider.of<UserDataProvider>(context);
    if(Theme.of(context).platform == TargetPlatform.iOS) {
      licenseKey = "AU2fEQe3GJryC3IjwChLJrwJnN3yHLIFtgs95dFTiM0/QxWwVlitsD53JQNTYQ+gji+F8/dS2dk8dCZi6GmepNI3rFEdX6Gh3jhnEQNeTOIhfCclYlwl76N9rRL8JTwHFgXWr/wA3HhLMGLvpAugC/iEmRuAbaDjIRBy26AqREVenSNFEvC2YeZd3vATn5ERnlv+Bo0Rnip3P3YIo9YoJ1Z2l1UcSfCb7rEDWaqxF6uRLISW30YQWhsuL3UYnYwV5NgOQO4u3E28r/0/Wmr4RAvmOb/ImZFa+bS5xaEyU9+WraHrs2ZpRA43ilDVIz/W6KGLvv/bMnLAuLo7R46yTmHRt/W5gm0O7YTRs4/fbJQX1+8ZL+2dOWsS8kDZpkWFyKHdxOmUiwd58Ped85D5RZ3Glkpq/zcdnsqixFFYjnZMRaFRhuvID1kV638LIUUf5fmqOBVgF+jU7RwqqJVfFkLT9p3mYupy2QJZg7fb0SeoAbPdCFK74bW2C8uFWJ7uez3QSTGGL0KK68frMNsGEnORj7+HOrjhoFNmPsD0RiW6wWd0zysdv1apaaqatJVyaQr1EeXHdTEETjw7KokTZt4XGgLkXt2l7AzbZPoqUHrHpQpYIEO0d3jM4TZt/nF5F/8/ogSfHusjPduCPBZSG1+vlPjQNOX2VKrMWKdMKZrSx+9ZPLevoa0vNz5BULwvIIq+Izp8B0T4tDmxAgHi3lhHHcrdy0ZMOB7pE7cYG39Tl47ls2Z0J0g/XCjv0KWcNvtqUGWlOPGcJJaCN2jqD2val62JlB9xpre8+vj6WWh8FJrHWPSqmLew";
    }
    else if(Theme.of(context).platform == TargetPlatform.android) {
      licenseKey = "AQjvDRq3BRpdD+3ebQZWMDo9qrUDIyNkjQaWW8BJaa1Udw4Edzacue5VRZcvbMrTBw//YrJg0aelZ/E6CHJcFjZsQiYBd71lKCQxx9NgyfEdLR0Db0J/KdsBi7JlC1dP+XDFxImQ4xkN6MsevRHYYF/cVeGeQQ/AZwnCB5s+vqKkJpHiI/6LuZ5u2FxEebASefRiNdUjoQL4fn/Rhk2SVaJOfr//74Em1j+IvsZpHYdlEd1RgtoXvx3SgC6j4Tk6+f+sMEx0G2wbmgWk9V+rce6JB25IjGhdtBsnAfneOLSpZ6vgynhZyMRhLZI0B5nbG9+dgYrCa5RvgZWnc8UN+dgFbtEVI0jQwBb5reFTgcKzPVbsXqSzwmogcTmYvdeGXnIxR708veQ6SbHQlxBOo8tY2Fp77QCEPMi1AeL3ZUXPy9CCK1SDOrkGLFBBlYS8pi0X4i12FU+2aPHVV0405a4bGAqiZB3Rq4uHlTnmwbEBmQNWe55/2NV3SNbAPleWO/EGrZppZYCGS39QSojTZ5/WCMqV95rkcQC6X3CWFYqiZ/Ua2H+ZOQU8Uk0G1mvUOdGIld+zSpujrQLbXYbv5NUSgWyPLxactX3pUbxF2yDZPDvtBYVeLHRsxXjL0n3YT17Mngwk6qs5prK6B3vBhf/BvYGhKgKG/torKe/crfjOXDJAXVsQDYjKfpBFi4EzVaegaGJ0mck44XtIPLXTfdriCTdFrGg+hPX4VglWr/qXsHnU1eyjdAQKL8hJWPeOBhbWZNeOG188F0HZb6DcKdW4P7zRObuSqsiUabN5";
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Barcode Scanner"),
      ),
      body:
       !hasScanned ?
          renderScanner()
        :
          renderSubmissionView()

      ,
      floatingActionButton: IconButton(
        onPressed: () {},
        icon: Container(),
      ),
    );
  }

  Widget renderScanner() {
    return(
        Stack(
          children: [
            Scandit(
                scanned: _handleBarcodeResult,
                onError: (e) => setState(() => _message = e.message),
                symbologies: [Symbology.CODE128, Symbology.DATA_MATRIX],
                onScanditCreated: (controller) => _controller = controller,
                licenseKey: licenseKey
            ),
            Center(
              child: Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white),
                  )),
            ),
            Center(child: Text(_message)),
          ],
        )
    );
  }

  Widget renderSubmissionView() {
    if(isLoading) {
      return (
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator()
                ),

              ),
              Padding(
                padding: const EdgeInsets.only(top:20.0),
                child: Text("Submitting...please wait", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ],
          )
      );
    }
    else if(successfulSubmission) {
      return(renderSuccessScreen(context));
    }
    else if(didError) {
      return(renderFailureScreen(context));
    }
    else {
      return(renderFailureScreen(context));
    }
  }

  Map<String, dynamic> createUserData() {
    this.setState(() {
      ucsdAffiliation = _userDataProvider.authenticationModel.ucsdaffiliation;
      accessToken = _userDataProvider.authenticationModel.accessToken;
    });
    return {'barcode': _barcode, 'ucsdaffiliation': ucsdAffiliation};
  }

  Widget renderFailureScreen(BuildContext context) {
    return(
        Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: (
                    Column(
                        children: <Widget>[
                          ClipOval(
                            child: Container(
                              color: Colors.red,
                              height: 75,
                              width: 75,
                              child: Icon(Icons.clear,
                                  color: Colors.white,
                                  size: 60),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text("Submission Failed!", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                                _errorText,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: FlatButton(
                              onPressed: () {
                                this.setState(() {
                                  hasScanned = false;
                                  hasSubmitted = false;
                                  didError = false;
                                  successfulSubmission = false;
                                  isLoading = false;
                                });
                              },
                              child: Text("Try again"),
                              color: lightButtonColor,
                              textColor: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                                "If this issue persists, please contact a healthcare professional.",
                                style: TextStyle(fontSize: 15)),
                          ),

                        ]
                    )
                ),
              ),
            ),
          ],
        ));
  }

  Widget renderSuccessScreen(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: (
                Column(
                    children: <Widget>[
                      Icon(Icons.check_circle,
                          color: Colors.green,
                          size: 60),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Scan Submitted", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      ),
                      Text("Scan sent at: " + DateTime.now().toString(), style: TextStyle(color: ColorPrimary)),
                    ]
                )
            ),
          ),
        ),
        Align(alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text("Next Steps:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
            )),

        ListView(
          shrinkWrap: true,
          children:<Widget>[
            ListTile(title: Text(String.fromCharCode(0x2022) + " Proceed to the next step in the testing process")),
            ListTile(title: Text(String.fromCharCode(0x2022) + " Results are usually available within 24-36 hours.")),
            ListTile(title: Text(String.fromCharCode(0x2022) + " You can view your results by logging in to MyStudentChart.")),
            ListTile(title: Text(String.fromCharCode(0x2022) + " If you are experiencing symptoms of COVID-19, stay in your residence and seek guidance from a healthcare provider.")),
            ListTile(title: Text(String.fromCharCode(0x2022) + " Help fight COVID-19. Add CA COVID Notify to your phone.",
                                style: TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline)),
              onTap: () {
                  openLink("https://en.ucsd.edu");
              }
            ,),
          ],
        ),
      ],
    );
  }


  Future<void> _handleBarcodeResult(BarcodeResult result) async {
    this.setState(() {
      hasScanned = true;
      _barcode = result.data;
    });
    var data = createUserData();
    var headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${accessToken}'
    };
    setState(() {
      isLoading = true;
    });
    var results = await _barcodeService.uploadResults(headers, data);

    if (results) {
      this.setState(() {
        isLoading = false;
        didError = false;
        successfulSubmission = true;
      });
    } else {
      this.setState(() {
        successfulSubmission = false;
        didError = true;
        isLoading = false;
      });
      if (_barcodeService.error.contains(ErrorConstants.invalidBearerToken)) {
        await _userDataProvider.refreshToken();
      } else if(_barcodeService.error.contains(ErrorConstants.duplicateRecord)){
        this.setState(() {
          _errorText = "Submission failed due to barcode already scanned. Please scan another barcode.";
        });
      }
      //_submitted = true;
    }


  }

  openLink(String url) async {
    try {
      launch(url, forceSafariVC: true);
    } catch (e) {
      // an error occurred, do nothing
    }
  }
}