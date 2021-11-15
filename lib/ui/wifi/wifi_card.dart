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

class _WiFiCardState extends State<WiFiCard> {
  String cardId = "speed_test";
  TestStatus? cardState;
  int? lastSpeed;
  late bool goodSpeed;
  SpeedTestProvider _speedTestProvider = SpeedTestProvider();
  UserDataProvider? _userDataProvider;
  bool _buttonEnabled = true;
  Timer? buttonTimer;

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
          Provider.of<SpeedTestProvider>(context, listen: false).init(),
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
    _speedTestProvider.addListener(() {
      //TODO: Add print statements to verify not reloading
      try {
        if (_speedTestProvider.onSimulator!) {
          cardState = TestStatus.simulated;
        } else if (!_speedTestProvider.isUCSDWiFi!) {
          cardState = TestStatus.unavailable;
        } else if (_speedTestProvider.timeElapsedDownload +
                _speedTestProvider.timeElapsedUpload >
            15) {
          _speedTestProvider.cancelDownload();
          _speedTestProvider.cancelUpload();
          setState(() {
            goodSpeed = false;
            cardState = TestStatus.finished;
          });
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
                  _speedTestProvider.speedTest();
                });
              }
            },
            minWidth: 350,
            height: 40,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: BorderSide(color: Colors.black),
            ),
            color: darkAppBarTheme.backgroundColor,
            child: Text(
              "Run Speed Test",
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
                                      primary: Theme.of(context).colorScheme.secondary),
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

  Column finishedState() {
    _speedTestProvider.sendNetworkDiagnostics(lastSpeed);
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
          WidgetSpan(
            child: goodSpeed
                ? Icon(Icons.thumb_up, size: 36, color: Colors.green)
                : Icon(Icons.thumb_down, size: 36, color: Colors.red),
          ),
          TextSpan(
            text:
                '\n Your download speed was: ${lastSpeed != null ? lastSpeed!.toStringAsPrecision(3) : _speedTestProvider.speed!.toStringAsPrecision(3)} Mbps \n Your upload speed was: ${_speedTestProvider.uploadSpeed!.toStringAsPrecision(3)} Mbps\n',
            style: TextStyle(fontSize: 15, color: Colors.grey),
          )
        ])),
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
              color: darkAppBarTheme.backgroundColor,
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
                                        primary: Theme.of(context).colorScheme.secondary),
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
            "Looks like you aren’t on a UCSD network",
            style: TextStyle(
              fontSize: 25,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Please check your connection and try again.",
            style: TextStyle(fontSize: 13),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
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
