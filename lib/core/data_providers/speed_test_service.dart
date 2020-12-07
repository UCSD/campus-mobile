import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
//import 'package:internet_speed_test/callbacks_enum.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
//import 'package:internet_speed_test/internet_speed_test.dart';
class SpeedTestService extends ChangeNotifier {
  SpeedTestService() {
    _networkHelper = Dio();
    _timer = Stopwatch();
    _speed = 0.0;
    _percentDownloaded = 0.00;
  }

  Dio _networkHelper;
  Stopwatch _timer;
  double _speed;
  double _percentDownloaded;
  CancelToken _cancelToken;
  bool _speedTestDone = false;



  String url =
      'https://ucsd-its-wts-dev.s3-us-west-1.amazonaws.com/Services/WifiAnalyzer/webpage_100MB.html';
  Stream<bool> speedStream() async* {
    while (true) {
      try {
        yield _speedTestDone;
      }
      catch (error) {}
    }
  }
  void speedTest() async {
    // final internetSpeedTest = InternetSpeedTest();
    // _resetSpeedTest();
    // notifyListeners();
    // try{
    //   await internetSpeedTest.startDownloadTesting(
    //     onDone: (double transferRate, SpeedUnit unit) {
    //       _speed = transferRate;
    //       _percentDownloaded = 1;
    //
    //       if(unit == SpeedUnit.Mbps){
    //         print("IN Mbps");
    //       }
    //       notifyListeners();
    //     },
    //     onProgress: (double percent, double transferRate, SpeedUnit unit) {
    //       _percentDownloaded = percent/100;
    //       _speed = transferRate;
    //       print("Percent downloaded: $_percentDownloaded");
    //       print("Transfer rate: $speed" + (unit == SpeedUnit.Mbps ? "Mpbs": "Kbps"));
    //
    //       notifyListeners();
    //
    //     },
    //     onError: (String errorMessage, String speedTestError) {
    //       // print(errorMessage);
    //       // print(speedTestError);
    //     },
    //
    //   );
    // }catch (e){
    //   print("ERROR: ${e.toString()}");
    // }
    //
    // notifyListeners();
    //
    // _cancelToken = CancelToken();
    //  //get location to app directory
    String path = (await getApplicationDocumentsDirectory()).path;
    //create file
    File tempDownload = File(path + "/temp.html");
    resetSpeedTest();
    // _timer.start();
    notifyListeners();
    try {
      _timer.start();
      await _networkHelper.download(url, (tempDownload.path),
          onReceiveProgress: _progressCallback, cancelToken: _cancelToken);
    } catch (e) {
      print(e.toString());
    }
    _timer.stop();
    notifyListeners();
  }

  _progressCallback(int bytesDownloaded, int totalBytes) {
    double speedInBytes = (bytesDownloaded / _timer.elapsed.inSeconds);
    _speed = _convertToMbps(speedInBytes) * 10;

    _percentDownloaded = bytesDownloaded / totalBytes;
    if(percentDownloaded == 100){
      _speedTestDone = true;
    }
    notifyListeners();

  }

  double _convertToMbps(double speed) {
    return speed / 125000;
  }

   void resetSpeedTest() {
    _timer.reset();
    _percentDownloaded = 0.0;
    _speed = 0.00;
  }

  void cancelDownload() {
    try {
      if (_timer.isRunning) {
        _timer.stop();
        _cancelToken.cancel("cancelled");
      }
    } catch (e) {
      print('test was not running');
    }
  }

  double get speed => _speed;
  Stopwatch get timer => _timer;
  double get percentDownloaded => _percentDownloaded;
  bool get speedTestDone => _speedTestDone;
}
