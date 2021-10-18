import 'dart:async';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/speed_test.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';

class WiFiCard extends StatefulWidget {
  @override
  _WiFiCardState createState() => _WiFiCardState();
}

class _WiFiCardState extends State<WiFiCard> with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;

  String cardId = "speed_test";
  TestStatus? cardState;
  int? lastSpeed;
  late bool goodSpeed;
  bool timedOut = false;
  SpeedTestProvider _speedTestProvider = SpeedTestProvider();
  UserDataProvider? _userDataProvider;
  bool _buttonEnabled = true;
  Timer? buttonTimer;
  static const int SPEED_TEST_TIMEOUT_CONST = 30;

  @override
  void initState() {
    cardState = TestStatus.initial;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _speedTestProvider = Provider.of<SpeedTestProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates![cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () =>
          cardState != TestStatus.running ? Provider.of<SpeedTestProvider>(context, listen: false).init() : print("running test..."),
      isLoading: _speedTestProvider.isLoading,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: _speedTestProvider.error,
      child: () => buildCardContent(context),
    );
  }

  Widget buildTitle() {
    return Text(
      "Wifi Card",
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: ScalingUtility.horizontalSafeBlock * 2,
      ),
    );
  }

  Widget buildCardContent(BuildContext context) {
    if(!_speedTestProvider.isUCSDWiFi!) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: unavailableState(),
      );
    }

    if(timedOut) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: finishedState(),
      );
    }
    _speedTestProvider.addListener(() {
      //TODO: Add print statements to verify not reloading
      try {
        if (_speedTestProvider.onSimulator!) {
          cardState = TestStatus.simulated;
        } else if (!_speedTestProvider.isUCSDWiFi!) {
          setState(() {
            cardState = TestStatus.unavailable;
          });
        } else if (_speedTestProvider.timeElapsedDownload +
                _speedTestProvider.timeElapsedUpload >
            SPEED_TEST_TIMEOUT_CONST) {
          setState(() {
            goodSpeed = false;
            cardState = TestStatus.finished;
            timedOut = true;
          });
          _speedTestProvider.cancelDownload();
          _speedTestProvider.cancelUpload();
        } else if (_speedTestProvider.speedTestDone) {
          setState(() {
            goodSpeed = true;
            cardState = TestStatus.finished;
          });
        }
      } catch (e) {}
    });
    switch (cardState) {
      //TODO: Add check to verify not over-checking states
      case TestStatus.initial:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: initialState(context),
        );
      case TestStatus.running:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: speedTest(),
        );
      case TestStatus.finished:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: finishedState(),
        );
      case TestStatus.unavailable:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: unavailableState(),
        );
      case TestStatus.simulated:
        return Padding(
            padding: const EdgeInsets.all(8.0), child: simulatedState());
      default:
        return initialState(context);
    }
  }

  Column speedTest() {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: "Testing... ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 36,
                  )),
              WidgetSpan(
                child: Icon(Icons.wifi, size: 36),
              ),
            ]))),
        Container(
          height: 40,
          child: LiquidLinearProgressIndicator(
              backgroundColor: Colors.white,
              // Defaults to the current Theme's backgroundColor.
              borderColor: Colors.black,
              borderWidth: 0.5,
              center: Text(
                "${((_speedTestProvider.percentDownloaded * 100) / 2 + (_speedTestProvider.percentUploaded * 100) / 2).toStringAsPrecision(6).substring(0, 5)} %",
                style: TextStyle(color: Colors.grey),
              ),
              direction: Axis.horizontal,
              value: (_speedTestProvider.percentDownloaded +
                      _speedTestProvider.percentUploaded) /
                  2,
              valueColor: AlwaysStoppedAnimation(lightPrimaryColor)),
        ),
      ],
    );
  }

  Column initialState(BuildContext context) {
    if (buttonTimer != null) _buttonEnabled = true;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        RichText(
            text: TextSpan(children: [
          TextSpan(
              text: "Test WiFi Speed ",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 36,
              )),
          WidgetSpan(
            child: Icon(
              Icons.wifi,
              size: 36,
            ),
          ),
          TextSpan(
              text: "\n",
              style: TextStyle(
                color: Colors.black,
                fontSize: 36,
              )),
          TextSpan(
            text: "Help identify campus WiFi issues. \nRun a speed test now.",
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ])),
        MaterialButton(
            padding: EdgeInsets.all(4.0),
            elevation: 0.0,
            onPressed: () {
              if (_speedTestProvider.onSimulator!) {
                setState(() {
                  cardState = TestStatus.simulated;
                });
              } else {
                setState(() {
                  cardState = TestStatus.running;
                });
                 _speedTestProvider.speedTest().timeout(const Duration(seconds: 1), onTimeout: _onTimeout);
              }
            },
            minWidth: 350,
            height: 40,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: BorderSide(color: Colors.black),
            ),
            color: darkAppBarTheme.color,
            child: Text(
              "Test WiFi Speed",
              style: TextStyle(color: Colors.white),
            )),
        MaterialButton(
            padding: EdgeInsets.all(12.0),
            disabledColor: Colors.grey,
            onPressed: _buttonEnabled
                ? () {
                    _speedTestProvider.reportIssue();
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Container(
                              child: Text(
                                  "Please run speed test to report issue."),
                            ),
                            actions: <Widget>[
                              TextButton(
                                  child: Text("Dismiss"),
                                  style: TextButton.styleFrom(
                                      primary: Theme.of(context).buttonColor),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  })
                            ],
                          );
                        });
                  }
                : null,
            minWidth: 350,
            height: 40,
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: BorderSide(color: Colors.black),
            ),
            color: Colors.grey.shade100,
            child: Text(
              "Report Issue",
              style: TextStyle(color: Colors.black),
            )),
      ],
    );
  }

  Column timedOutState() {
    _speedTestProvider.sendNetworkDiagnostics(lastSpeed);
    bool showDownload = false;
    if(lastSpeed != null && lastSpeed! > 0) {
      showDownload = true;
    }
    return Column(
      children: [
        RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: "Your speed is:  ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 36,
                  )),
              TextSpan(
                text:
                '\n Download speed: ${lastSpeed != null ? lastSpeed!.toStringAsPrecision(3) : _speedTestProvider.speed!.toStringAsPrecision(3)} Mbps \n Upload speed: ${_speedTestProvider.uploadSpeed!.toStringAsPrecision(3)} Mbps\n',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              )])),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: MaterialButton(
              elevation: 0.0,
              onPressed: () {
                setState(() {
                  cardState = TestStatus.initial;
                  _speedTestProvider.resetSpeedTest();
                });
              },
              minWidth: 350,
              height: 40,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side: BorderSide(color: Colors.black),
              ),
              color: darkAppBarTheme.color,
              child: Text(
                "Rerun Test",
                style: TextStyle(color: Colors.white),
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: MaterialButton(
              disabledColor: Colors.grey,
              onPressed: _buttonEnabled
                  ? () {
                _speedTestProvider.reportIssue();
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Container(
                          child: Text(
                              "Thank you for helping improve UCSD wireless. Your test results have been sent to IT Services."),
                        ),
                        actions: <Widget>[
                          TextButton(
                              child: Text("Dismiss"),
                              style: TextButton.styleFrom(
                                  primary: Theme.of(context).buttonColor),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _buttonEnabled = false;
                                buttonTimer =
                                new Timer(Duration(minutes: 2), () {
                                  _buttonEnabled = true;
                                  setState(() {});
                                });
                                setState(() {});
                              })
                        ],
                      );
                    });
              }
                  : null,
              minWidth: 350,
              height: 40,
              elevation: 0.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side: BorderSide(color: Colors.black),
              ),
              color: Colors.grey.shade100,
              child: Text(
                "Report Issue",
                style: TextStyle(color: Colors.black),
              )),
        ),
      ],
    );
  }

  Column finishedState() {
    _speedTestProvider.sendNetworkDiagnostics(lastSpeed);
    String downloadSpeed = lastSpeed != null ? lastSpeed!.toStringAsPrecision(3) : _speedTestProvider.speed!.toStringAsPrecision(3) + " Mbps";
    String uploadSpeed = _speedTestProvider.uploadSpeed!.toStringAsPrecision(3) + " Mbps";

    if(downloadSpeed.contains("Infinity")) {
      downloadSpeed = "N/A";
    }

    if(uploadSpeed.contains("Infinity")) {
      uploadSpeed = "N/A";
    }

    if(timedOut) {
      goodSpeed = false;
      if(_speedTestProvider.percentDownloaded == 1.0) {
        uploadSpeed = "N/A (Timed Out)";
      }
      else {
        uploadSpeed = "N/A (Timed Out)";
        downloadSpeed = "N/A (Timed Out)";
      }
    }

    return Column(
      children: [
        RichText(
            text: TextSpan(children: [
          TextSpan(
            text:
                '\n Download speed was: $downloadSpeed \n Upload speed was: $uploadSpeed\n',
            style: TextStyle(fontSize: 15, color: Colors.grey),
          )
        ])),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: MaterialButton(
              elevation: 0.0,
              onPressed: () {
                setState(() {
                  timedOut = false;
                  cardState = TestStatus.initial;
                  _speedTestProvider.resetSpeedTest();
                });
              },
              minWidth: 350,
              height: 40,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side: BorderSide(color: Colors.black),
              ),
              color: darkAppBarTheme.color,
              child: Text(
                "Rerun Test",
                style: TextStyle(color: Colors.white),
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: MaterialButton(
              disabledColor: Colors.grey,
              onPressed: _buttonEnabled
                  ? () {
                      _speedTestProvider.reportIssue();
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Container(
                                child: Text(
                                    "Thank you for helping improve UCSD wireless. Your test results have been sent to IT Services."),
                              ),
                              actions: <Widget>[
                                TextButton(
                                    child: Text("Dismiss"),
                                    style: TextButton.styleFrom(
                                        primary: Theme.of(context).buttonColor),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _buttonEnabled = false;
                                      buttonTimer =
                                          new Timer(Duration(minutes: 2), () {
                                        _buttonEnabled = true;
                                        setState(() {});
                                      });
                                      setState(() {});
                                    })
                              ],
                            );
                          });
                    }
                  : null,
              minWidth: 350,
              height: 40,
              elevation: 0.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side: BorderSide(color: Colors.black),
              ),
              color: Colors.grey.shade100,
              child: Text(
                "Report Issue",
                style: TextStyle(color: Colors.black),
              )),
        ),
      ],
    );
  }

  Column unavailableState() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Connect to a UCSD Network",
            style: TextStyle(
              fontSize: 25,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        MaterialButton(
            padding: EdgeInsets.all(4.0),
            elevation: 0.0,
            onPressed: () => tryAgain(),
            minWidth: 350,
            height: 40,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: BorderSide(color: Colors.black),
            ),
            color: darkAppBarTheme.color,
            child: Text(
              "Try Again",
              style: TextStyle(color: Colors.white),
            )),
      ],
    );
  }

  void tryAgain() async {
    // re check everything
    await Provider.of<SpeedTestProvider>(context, listen: false).init();

    // reset states if needed
    if(_speedTestProvider.isUCSDWiFi!) {
      setState(() {
        cardState = TestStatus.initial;
      });
    }
    else {
      setState(() {
        cardState = TestStatus.unavailable;
      });
    }
  }
  Column simulatedState() {
    print("WiFi Speed Test feature is only available on physical devices.");
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Sorry",
            style: TextStyle(
              fontSize: 25,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "This feature is only available on physical devices.",
            style: TextStyle(fontSize: 13),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  _onTimeout() {
    _speedTestProvider.cancelDownload();
    _speedTestProvider.cancelUpload();
    setState(() {
      timedOut = true;
      goodSpeed = false;
      cardState = TestStatus.finished;
    });
  }
}

//Image Scaling
class ScalingUtility {
  late MediaQueryData _queryData;
  static late double horizontalSafeBlock;
  static double? verticalSafeBlock;

  void getCurrentMeasurements(BuildContext context) {
    /// Find screen size
    _queryData = MediaQuery.of(context);

    /// Calculate blocks accounting for notches and home bar
    horizontalSafeBlock = (_queryData.size.width -
            (_queryData.padding.left + _queryData.padding.right)) /
        100;
    verticalSafeBlock = (_queryData.size.height -
            (_queryData.padding.top + _queryData.padding.bottom)) /
        100;
  }
}

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;

  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static double? safeBlockHorizontal;
  static double? safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }
}

enum TestStatus { initial, running, finished, unavailable, simulated }
