import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class InternetConnectivityProvider extends ChangeNotifier {
  bool _noInternet = false;
  bool get noInternet => _noInternet;

  Connectivity _connectivity = Connectivity();

  Future<void> initConnectivity() async {
    try {
      var status = await _connectivity.checkConnectivity();
      if (status == ConnectivityResult.none) {
        _noInternet = true;
        notifyListeners();
      } else {
        _noInternet = false;
        notifyListeners();
      }
    } catch (e) {
      print("Encounter $e when monitoring Internet for cards");
    }
  }

  void monitorInternet() async {
    await initConnectivity();
    _connectivity.onConnectivityChanged.listen((result) async {
      if (result == ConnectivityResult.none) {
        _noInternet = true;
        notifyListeners();
      } else {
        _noInternet = false;
        notifyListeners();
      }
    });
  }
}
