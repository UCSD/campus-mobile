import 'dart:convert';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/wayfinding_constants.dart';
import 'package:dio/dio.dart';

class WayfindingService {
  bool isLoading;
  NetworkHelper networkHelper;
  String error;
  WayfindingConstantsModel wayfindingConstantsModel;
  final String awConstantsEndpoint =
      "https://api-qa.ucsd.edu:8243/bluetoothscanningcharacteristics/v1.0/constants";
  final String deviceTypesEndpoint =
      "https://api-qa.ucsd.edu:8243/bluetoothdevicecharacteristic/v1.0.0/servicenames/1";
  final Map<String, String> tokenHeader = {
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
      await getNewToken();
      print(tokenHeader);
      String deviceTypesResponse = await networkHelper.authorizedFetch(
          deviceTypesEndpoint, tokenHeader);
      String constantsResponse = await networkHelper.authorizedFetch(
          awConstantsEndpoint, tokenHeader);
      Map<String, dynamic> deviceTypesJson = json.decode(deviceTypesResponse);
      Map<String, dynamic> constantsJson = json.decode(constantsResponse);

      wayfindingConstantsModel =
          WayfindingConstantsModel.fromJson(deviceTypesJson, constantsJson);
      isLoading = false;
      return true;
    } catch (exception) {
      print(exception);
      error = exception.toString();
      isLoading = false;
      return false;
    }
  }
  Future<bool> getNewToken() async {
    final String tokenEndpoint = "https://api-qa.ucsd.edu:8243/token";
    final Map<String, String> tokenHeaders = {
      "content-type": 'application/x-www-form-urlencoded',
      "Authorization":
      "Basic djJlNEpYa0NJUHZ5akFWT0VRXzRqZmZUdDkwYTp2emNBZGFzZWpmaWZiUDc2VUJjNDNNVDExclVh"
    };
    try {
      var response = await networkHelper.authorizedPost(
          tokenEndpoint, tokenHeaders, "grant_type=client_credentials");

      tokenHeader["Authorization"] = "Bearer " + response["access_token"];

      return true;
    } catch (e) {
      return false;
    }
  }
}
