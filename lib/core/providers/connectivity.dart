import 'package:campus_mobile/ui/common/alert_dialog_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile/app_constants.dart';
import 'package:get/get.dart';

class InternetConnectivityProvider extends ChangeNotifier {
  /// STATES
  bool _noInternet = false;

  /// SERVICES
  var _connectivity = Connectivity();

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
    AlertDialogWidget alert = AlertDialogWidget(
      type: MessageTypeConstants.ERROR,
      icon: Icons.block_flipped,
      title: ConnectivityConstants.offlineTitle,
      description: ConnectivityConstants.offlineAlert,
      onClose: () {
        Navigator.of(context).pop();
      },
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

  /// SIMPLE GETTERS
  get noInternet => _noInternet;
}
