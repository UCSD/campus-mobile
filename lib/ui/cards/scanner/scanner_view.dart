
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
      licenseKey = "AcUfBiaXOVIQCeCwChcl05QwFCPbKhuZ5DFFHEdC7zjHZYV/XnS2CZJ5D9dnJcBTDW+Jh6RMOSJmXnJ8KywJjb9AHZNUU+j3MAZZX6hHx9fzc4UT4CAHEPRw2uVAIDBuKD8ozkMfw3qfOIanzJAM4oHLaUyHj9Qvxbh6eWOr/llZDzdB+mTTkUGW4ibe4XAhafCl7Y/pmyyS3KhREOJVIiMp8j0UoIjidTqBGq73dF9Ai2yXJKpAARXu4FAarFfWUoHIL2810iaDkpXhauSEv9KhCzWclhXFc/wD7kE9rfUYbq4gl0Wf3w7YTtvvaY+WeHYVvO4X+lDWn6GEf/hgRAPtyPLo2qTfD0TKxI/x7WoYw7rBFsRl43RrTbFb+a2ILhkp2A851a/xgzgv2VFFwKxZMRgwKb53JhWbF71zV5ZCvg8wi3MX502RnC6s+ljo3+EcJj3LDQ/1jIv8AH/9II2RWJKDPIx1WK4dojZiBYGPAp3cdgfatl6gx/PBFtJB2h+8No2KlzQRCRoY803Ir18GCQ7vJEevFEeQ/3X27vCrbyv/02hzMdmdSy3Im6CrH3WrVvrp+HioMCh6Yhao6c+hWNIBDvKgXUsMwQmVxtVg5TebF3GdJoW1rUDgMzXfRIBG+ApPecihGw37yjkL7FPLFMLytePm3h2a2HZJmrGs/1yZRhgVCynFGfzUa2rcL5ClXz7l7L4RW3GwP72fxwXjcNCwxOKe8chhGWJlOrKKKYwSkiQIg0d+I5B9YY7ryBFNHFzF0hYsRag7doW/oWclfbW2n/LLmn+Ict0bQd6BMJzjOh7R3e7R";
    }
    else if(Theme.of(context).platform == TargetPlatform.android) {
      licenseKey = "AclfFCWXOrX/Dx8+gjAdWhARENDRBdFqYwEimBx1pFypQ/tp/Xw1/NF8nFvwSGY5HU6eGSJzr2q1VcyTiDhCX/F9edHkZ8goMRdY5Ml946UgJUAwiS2JwUAMEP4nNWZSBrv3PTwMHdnK7CYSJHMxvdHzf1bm6RTUOIDvgaVI5lZ4eeWXsnt9z6dZ6ZvUPRSOP5R+K2rjMubVQiupQ3ernL+X4f1rdXqLZ2ZEAcD5XzaoOyUqAnzGh0JPGsxAjFLeX/3BZmvYhGxdIyy2JdHFxBaiqfs4KiM2vTTy3/zhvOekk7uV17RSpSybWut/D5fRASYVlyuLOlOpAiQHqREmnFJIbRB9pPiav7rCdCIiIu/4lsz9Yjc1qumqf2WqyAuW3oY7nrgQRsrTi5QEIaaeeFDOmbubtLgHR5jf1HubVhtI17X4oHFa4rC7Zao7+uMGzSCdHezdWz9lTD01KAhX9J0oGqITjMgxzG+EY0bYvKZHxva0qJw2s/4p1RdcSgGCa1gNi7kRYrsqilM2HkSDMU5wQL2bbC7k0qlnKJUeBY58no9gV4lLQTKAg0nf2lp5zgxReQ+4e7WdndqOgZ8RFGTK0XiaL4/wKxju4IIW4VkirS7SeT60g+t6jRN9SF8ZqtVIev0ZhIAY+pe7phZRYIG8h/BAFcEW21TSNJVSUIfign1g6gnJj48eU5T8z7ynGmNsaIBb5CpeZehpHo98lxlFYXoDXaU3WVSufwb/tMSlq7yt67gE9Or4j/CTFIi3YBl8kNaTADU7nOuYGPZYOVNGRpLv9FdcnB2wCuG5";
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