import 'dart:convert';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/wayfinding_constants.dart';

class WayfindingService {
  bool isLoading;
  NetworkHelper networkHelper;
  String error;
  WayfindingConstantsModel wayfindingConstantsModel;
  final String awConstantsEndpoint =
      "https://api-qa.ucsd.edu:8243/bluetoothscanningcharacteristics/v1.0/constants";
  final String deviceTypesEndpoint =
      "https://api-qa.ucsd.edu:8243/bluetoothdevicecharacteristic/v1.0.0/servicenames/1";
  final String mobileLoggerEndpoint =
      "https://api-qa.ucsd.edu:8243/mobileapplogger/v1.0.0/log";
  final Map<String, String> publicHeader = {
    "accept": "application/json",
  };
  Map<String, String> authorizedHeader;

  WayfindingService() {
    isLoading = false;
    networkHelper = NetworkHelper();
  }

  Future<bool> fetchData() async {
    isLoading = true;

    try {
      String deviceTypesResponse = await networkHelper.authorizedFetch(
          awConstantsEndpoint, publicHeader);
      String constantsResponse = await networkHelper.authorizedFetch(
          awConstantsEndpoint, publicHeader);

      Map<String, dynamic> deviceTypesJson = json.decode(deviceTypesResponse);
      Map<String, dynamic> constantsJson = json.decode(constantsResponse);

      wayfindingConstantsModel =
          WayfindingConstantsModel.fromJson(deviceTypesJson, constantsJson);
      isLoading = false;
      return true;
    } catch (exception) {
      error = exception.toString();
      isLoading = false;
      return false;
    }
  }
}
