import 'dart:async';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/speed_test.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/ui/common/action_button.dart';
import 'package:campus_mobile_experimental/ui/common/action_link.dart';
import 'package:campus_mobile_experimental/ui/common/alert_dialog_widget.dart';

class WiFiCard extends StatefulWidget {
  @override
  _WiFiCardState createState() => _WiFiCardState();
}

enum TestStatus { initial, running, finished, unavailable, simulated }

class _WiFiCardState extends State<WiFiCard> with AutomaticKeepAliveClientMixin {
  /// STATES
  String cardId = "speed_test";
  bool _buttonEnabled = true;
  bool timedOut = false;
  late bool goodSpeed;
  int? lastSpeed;
  Timer? buttonTimer;
  TestStatus? cardState;
  static const int SPEED_TEST_TIMEOUT_CONST = 30;

  /// PROVIDERS
  var _speedTestProvider = SpeedTestProvider();

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
    super.build(context);
    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false).toggleCard(cardId),
      reload: () => cardState != TestStatus.running
          ? Provider.of<SpeedTestProvider>(context, listen: false).init()
          : print("running test..."),
      isLoading: _speedTestProvider.isLoading!,
      titleText: CardTitleConstants.TITLE_MAP[cardId]!,
      errorText: _speedTestProvider.error,
      child: () => buildCardContent(context),
    );
  }

  // Wifi card changes its contents based on the state i.e.
  // initial, speedTest, finished, unavailableState, simulated
  Widget buildCardContent(BuildContext context) {
    if (!_speedTestProvider.isUCSDWiFi!) {
      return Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
        child: unavailableState(),
      );
    }
    if (timedOut) {
      return Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
        child: finishedState(),
      );
    }

    _speedTestProvider.addListener(() {
      try {
        if (_speedTestProvider.onSimulator!) {
          setState(() {
            cardState = TestStatus.simulated;
          });
        } else if (!_speedTestProvider.isUCSDWiFi!) {
          setState(() => cardState = TestStatus.unavailable);
        } else {
          final bool hasTimedOut =
              _speedTestProvider.timeElapsedDownload + _speedTestProvider.timeElapsedUpload > SPEED_TEST_TIMEOUT_CONST;
          if (hasTimedOut) {
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
        }
      } catch (_) {}
    });

    // STATE MACHINE
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
      child: switch (cardState) {
        TestStatus.initial => initialState(context),
        TestStatus.running => speedTest(),
        TestStatus.finished => finishedState(),
        TestStatus.unavailable => unavailableState(),
        TestStatus.simulated => simulatedState(),
        _ => initialState(context) // Default State (Initial)
      },
    );
  }

  //////////// INITIAL STATE (Before Testing for the first time) ////////////
  Column initialState(BuildContext context) {
    if (buttonTimer != null) _buttonEnabled = true;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Wifi icon + Description
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(
            Icons.wifi_sharp,
            color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : darkPrimaryColor2,
            size: 38,
          ),
          SizedBox(width: 10),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              "Help identify campus WiFi issues.",
              style: TextStyle(
                fontSize: 22,
                color: Theme.of(context).brightness == Brightness.light
                    ? descriptiveTextColorLight
                    : descriptiveTextColorDark,
                fontWeight: FontWeight.w400,
              ),
            ),
          )
        ]),
        SizedBox(height: 50),
        // TEST SPEED and REPORT ISSUE buttons
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TEST SPEED
            ActionButton(
                buttonText: 'TEST SPEED',
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
                }),
            // REPORT ISSUE
            ActionLink(
              buttonText: 'REPORT ISSUE',
              onPressed: _buttonEnabled
                  ? () {
                      _speedTestProvider.reportIssue();
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialogWidget(
                                type: MessageTypeConstants.ERROR,
                                icon: Icons.block_flipped,
                                title: WifiConstants.WIFI_ISSUE_FAILED_TITLE,
                                description: WifiConstants.WIFI_ISSUE_FAILED_DESC,
                                onClose: () {
                                  Navigator.of(context).pop();
                                });
                          });
                    }
                  : () {},
            )
          ],
        ),
      ],
    );
  }

  //////////// SPEED TEST STATE (During testing) ////////////
  Column speedTest() {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
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
              value: (_speedTestProvider.percentDownloaded + _speedTestProvider.percentUploaded) / 2,
              valueColor: AlwaysStoppedAnimation(lightPrimaryColor)),
        ),
      ],
    );
  }

  //////////// FINISHED STATE (After Testing) ////////////
  Column finishedState() {
    _speedTestProvider.sendNetworkDiagnostics(lastSpeed);
    String downloadSpeed = lastSpeed != null
        ? lastSpeed!.toStringAsPrecision(3)
        : _speedTestProvider.speed!.toStringAsPrecision(3) + " Mbps";
    String uploadSpeed = _speedTestProvider.uploadSpeed!.toStringAsPrecision(3) + " Mbps";

    if (downloadSpeed.contains("Infinity")) downloadSpeed = "N/A";
    if (uploadSpeed.contains("Infinity")) uploadSpeed = "N/A";
    if (timedOut) {
      goodSpeed = false;
      if (_speedTestProvider.percentDownloaded == 1.0) {
        uploadSpeed = "N/A (Timed Out)";
      } else {
        uploadSpeed = "N/A (Timed Out)";
        downloadSpeed = "N/A (Timed Out)";
      }
    }
    // Card contents for Download Speed and Upload Speed
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // DOWNLOAD SPEED
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Download speed:',
                  style: TextStyle(
                    fontSize: 26,
                    color: Theme.of(context).brightness == Brightness.light
                        ? descriptiveTextColorLight
                        : descriptiveTextColorDark,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              // Download Speed in Mbps
              Expanded(
                  flex: 4,
                  child: Text(
                    downloadSpeed,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : darkPrimaryColor2,
                    ),
                  ))
            ],
          ),
        ),
        SizedBox(height: 20),
        // UPLOAD SPEED
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Upload speed:',
                  style: TextStyle(
                    fontSize: 26,
                    color: Theme.of(context).brightness == Brightness.light
                        ? descriptiveTextColorLight
                        : descriptiveTextColorDark,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                  flex: 4,
                  child: Text(
                    downloadSpeed,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).brightness == Brightness.light ? lightPrimaryColor : darkPrimaryColor2,
                    ),
                  ))
            ],
          ),
        ),
        SizedBox(height: 20),
        // TEST SPEED and REPORT ISSUE buttons
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TEST SPEED
            // TODO: This brings you back to the initial state, but that requires two "TEST SPEED" Button clicks. - December 2025
            // TODO: For the UI people, do you want 1 click? or 2 clicks but the first one indicating to "Reset" - December 2025
            ActionButton(
                buttonText: 'TEST SPEED',
                onPressed: () {
                  setState(() {
                    timedOut = false;
                    cardState = TestStatus.running;
                    _speedTestProvider.resetSpeedTest();
                  });
                  _speedTestProvider.speedTest().timeout(const Duration(seconds: 1), onTimeout: _onTimeout);
                  // setState(() {
                  //   timedOut = false;
                  //   cardState = TestStatus.initial;
                  //   _speedTestProvider.resetSpeedTest();
                  // });
                }),
            SizedBox(width: 10),
            // REPORT ISSUE
            ActionLink(
              buttonText: 'REPORT ISSUE',
              onPressed: _buttonEnabled // TODO: DO WE REALLY NEED THIS BUTTON ENABLED? - December 2025
                  ? () {
                      _speedTestProvider.reportIssue();
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialogWidget(
                                type: MessageTypeConstants.SUCCESS,
                                icon: Icons.check_circle_outline_sharp,
                                title: WifiConstants.WIFI_ISSUE_SUCCESS_TITLE,
                                description: WifiConstants.WIFI_ISSUE_SUCCESS_DESC,
                                onClose: () {
                                  Navigator.of(context).pop();
                                });
                          });
                    }
                  : () {},
            )
          ],
        ),
      ],
    );
  }

  //////////// UNAVAILABLE STATE (Not in a UCSD Network) ////////////
  Column unavailableState() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
          child: Text(
            "Connect to a UCSD Network",
            style: TextStyle(
              fontSize: 25,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 50),
        ActionButton(buttonText: 'TRY AGAIN', onPressed: () => tryAgain()),
      ],
    );
  }

  void tryAgain() async {
    // re check everything
    await Provider.of<SpeedTestProvider>(context, listen: false).init();

    // reset states if needed
    if (_speedTestProvider.isUCSDWiFi!) {
      setState(() {
        cardState = TestStatus.initial;
      });
    } else {
      setState(() {
        cardState = TestStatus.unavailable;
      });
    }
  }

////////////////////////////////////////////////////////////////////////////
  ////////////// SIMULATED STATE ////////////
  Column simulatedState() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8, right: 8, top: 8),
          child: Text(
            "Sorry",
            style: TextStyle(
              fontSize: 25,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
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

  /// SIMPLE GETTERS
  bool get wantKeepAlive => true;
}

// Image Scaling
class ScalingUtility {
  late MediaQueryData _queryData;
  static late double horizontalSafeBlock;
  static double? verticalSafeBlock;

  void getCurrentMeasurements(BuildContext context) {
    /// Find screen size
    _queryData = MediaQuery.of(context);

    /// Calculate blocks accounting for notches and home bar
    horizontalSafeBlock = (_queryData.size.width - (_queryData.padding.left + _queryData.padding.right)) / 100;
    verticalSafeBlock = (_queryData.size.height - (_queryData.padding.top + _queryData.padding.bottom)) / 100;
  }
}

// Configurations
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

    _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }
}
