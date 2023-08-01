import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:get/get.dart';

class InternetConnectivityProvider extends ChangeNotifier {
  bool _noInternet = false;
  bool get noInternet => _noInternet;

  Connectivity _connectivity = Connectivity();

  Future<void> initConnectivity() async {
    try {
      var status = await _connectivity.checkConnectivity();
      if (status == ConnectivityResult.none) {
        print("Connectivity status: offline");
        _noInternet = true;
        notifyListeners();
        _showOfflineAlert(Get.context!);
      } else {
        print("Connectivity status: online");
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
        print("Connectivity status: offline");
        _noInternet = true;
        notifyListeners();
        _showOfflineAlert(Get.context!);
      } else {
        print("Connectivity status: online");
        _noInternet = false;
        notifyListeners();
      }
    });
  }

  void _showOfflineAlert(BuildContext context) {
    print("showing the offline alert dialog");
    AlertDialog alert = AlertDialog(
      title: Text(ConnectivityConstants.offlineTitle),
      content: Text(ConnectivityConstants.offlineAlert),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'Ok'),
          child: Text('Ok'),
          style: TextButton.styleFrom(
            // primary: Theme.of(context).buttonColor,
            primary: Theme.of(context).backgroundColor,
          ),
        ),
      ],
    );

    Future.delayed(
        Duration.zero,
        () => {
              showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return alert;
                },
              )
            });
  }
}
