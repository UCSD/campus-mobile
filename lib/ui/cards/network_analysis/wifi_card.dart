//import 'dart:io';
// import 'dart:js';

import 'dart:ffi';
import 'dart:io';

import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/cards_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/speed_test_service.dart';
import 'package:campus_mobile_experimental/core/data_providers/student_id_data_provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/weather_data_provider.dart';
import 'package:campus_mobile_experimental/ui/reusable_widgets/card_container.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:wifi_connection/WifiConnection.dart';
import 'package:wifi_connection/WifiInfo.dart';

class WiFiCard extends StatefulWidget {
  @override
  _WiFiCardState createState() => _WiFiCardState();
}

class _WiFiCardState extends State<WiFiCard> {
  String cardId = "speed_test";
  TestStatus cardState;
  int lastSpeed;
  bool goodSpeed;
  SpeedTestService _speedTestService;

  @override
  void initState() {
    cardState = TestStatus.initial;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _speedTestService = Provider.of<SpeedTestService>(context);

    return CardContainer(
      active: Provider.of<CardsDataProvider>(context).cardStates[cardId],
      hide: () => Provider.of<CardsDataProvider>(context, listen: false)
          .toggleCard(cardId),
      reload: () => Provider.of<WeatherDataProvider>(context, listen: false)
          .fetchWeather(),
      isLoading: Provider.of<WeatherDataProvider>(context).isLoading,
      titleText: CardTitleConstants.titleMap[cardId],
      errorText: Provider.of<StudentIdDataProvider>(context).error,
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
    _speedTestService.addListener(() {
      try {
        if (_speedTestService.timeElapsedDownload +
                _speedTestService.timeElapsedUpload >
            105) {
          _speedTestService.cancelDownload();
          _speedTestService.cancelUpload();
          setState(() {
            goodSpeed = false;
            cardState = TestStatus.finished;
          });
        } else if (_speedTestService.speedTestDone) {
          setState(() {
            goodSpeed = true;
            cardState = TestStatus.finished;
          });
        }
      } catch (e) {}
    });

    switch (cardState) {
      case TestStatus.initial:
        return initialState();
        break;
      case TestStatus.running:
        return speedTest();
        break;
      case TestStatus.finished:
        return finishedState();
        break;
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
                    color: Colors.black,
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
                "${((_speedTestService.percentDownloaded * 100) / 2 + (_speedTestService.percentUploaded * 100) / 2).toStringAsPrecision(6).substring(0, 4)} %",
                style: TextStyle(color: Colors.grey),
              ),
              direction: Axis.horizontal,
              value: (_speedTestService.percentDownloaded +
                      _speedTestService.percentUploaded) /
                  2,
              valueColor: AlwaysStoppedAnimation(lightPrimaryColor)),
        ),
      ],
    );
  }

  Column initialState() {
    WifiInfo wifiConnection;
    WifiConnection.wifiInfo.then((value) {
      wifiConnection = value;
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        RichText(
            text: TextSpan(children: [
          TextSpan(
              text: "Test WiFi Speed ",
              style: TextStyle(
                color: Colors.black,
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
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: MaterialButton(
              elevation: 0.0,
              onPressed: () {
                setState(() {
                  cardState = TestStatus.running;
                  _speedTestService.speedTest();
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
                "Run Speed Test",
                style: TextStyle(color: Colors.white),
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: MaterialButton(
              onPressed: () {},
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
    return Column(
      children: [
        RichText(
            text: TextSpan(children: [
          TextSpan(
              text: "Your speed is:  ",
              style: TextStyle(
                color: Colors.black,
                fontSize: 36,
              )),
          WidgetSpan(
            child: goodSpeed
                ? Icon(
                    Icons.thumb_up,
                    size: 36,
                    color: Colors.green,
                  )
                : Icon(Icons.thumb_down, size: 36, color: Colors.red),
          ),
          TextSpan(
            text:
                '\n Your download speed was: ${lastSpeed != null ? lastSpeed.toStringAsPrecision(3) : _speedTestService.speed.toStringAsPrecision(3)} Mbps \n Your upload speed was: ${_speedTestService.uploadSpeed.toStringAsPrecision(3)} Mbps\n',
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
                  _speedTestService.resetSpeedTest();
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
              onPressed: () {},
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

  Future<bool> sendNetworkDiagnostics() async {
    bool sentSuccessfully = false;

    List<Object> locationWifiConnectivity = await futureCombo();
    if (locationWifiConnectivity[2] == ConnectivityResult.wifi) {
      if (Platform.isAndroid) {
        Map wifiLog = {
          "Platform": "Android",
          "SSID": (locationWifiConnectivity[0] as WifiInfo).ssid,
          "BSSID": (locationWifiConnectivity[0] as WifiInfo).bssId,
          "IPAddress": (locationWifiConnectivity[0] as WifiInfo).ipAddress,
          "MacAddress": (locationWifiConnectivity[0] as WifiInfo).macAddress,
          "LinkSpeed": (locationWifiConnectivity[0] as WifiInfo).linkSpeed,
          "SignalStrength":
              (locationWifiConnectivity[0] as WifiInfo).signalStrength,
          "Frequency": (locationWifiConnectivity[0] as WifiInfo).frequency,
          "NetworkID": (locationWifiConnectivity[0] as WifiInfo).networkId,
          "IsHiddenSSID":
              (locationWifiConnectivity[0] as WifiInfo).isHiddenSSid,
          "RouterIP": (locationWifiConnectivity[0] as WifiInfo).routerIp,
          "Channel": (locationWifiConnectivity[0] as WifiInfo).channel,
          "Latitude":
              (locationWifiConnectivity[1] as LocationData).latitude as Double,
          "Longitude":
              (locationWifiConnectivity[1] as LocationData).longitude as Double,
          "TimeStamp": DateTime.fromMillisecondsSinceEpoch(
                  DateTime.now().millisecondsSinceEpoch)
              .toString(),
          "DownloadSpeed": lastSpeed != null
              ? lastSpeed.toStringAsPrecision(3)
              : _speedTestService.speed.toStringAsPrecision(3),
          "UploadSpeed": _speedTestService.uploadSpeed.toStringAsPrecision(3),
        };
      } else {
        Map wifiLog = {
          "Platform": "iOS",
          "SSID": (locationWifiConnectivity[0] as WifiInfo).ssid,
          "BSSID": (locationWifiConnectivity[0] as WifiInfo).bssId,
          "IPAddress": (locationWifiConnectivity[0] as WifiInfo).ipAddress,
          "MacAddress": (locationWifiConnectivity[0] as WifiInfo).macAddress,
          "LinkSpeed": "",
          "SignalStrength": "",
          "Frequency": "",
          "NetworkID": "",
          "IsHiddenSSID": "",
          "RouterIP": "",
          "Channel": "",
          "Latitude":
              (locationWifiConnectivity[1] as LocationData).latitude as Double,
          "Longitude":
              (locationWifiConnectivity[1] as LocationData).longitude as Double,
          "TimeStamp": DateTime.fromMillisecondsSinceEpoch(
                  DateTime.now().millisecondsSinceEpoch)
              .toString(),
          "DownloadSpeed": lastSpeed != null
              ? lastSpeed.toStringAsPrecision(3)
              : _speedTestService.speed.toStringAsPrecision(3),
          "UploadSpeed": _speedTestService.uploadSpeed.toStringAsPrecision(3),
        };

        //TODO: Send data for submission
        sentSuccessfully = true;
      }
    }

    return sentSuccessfully; //Due to failed submission or not connected to wifi
  }

  Future<List<Object>> futureCombo() async {
    if (await (Connectivity().checkConnectivity()) != ConnectivityResult.wifi) {
      return [null, null, await (Connectivity().checkConnectivity())];
    }

    var location = Location();
    location.changeSettings(accuracy: LocationAccuracy.low);

    LocationData position;
    return [
      await WifiConnection.wifiInfo,
      await location.getLocation(),
      await (Connectivity().checkConnectivity())
    ];
  }
}

//Image Scaling
class ScalingUtility {
  MediaQueryData _queryData;
  static double horizontalSafeBlock;
  static double verticalSafeBlock;

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
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;

  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;

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

enum TestStatus { initial, running, finished }
