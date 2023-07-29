import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import '../../app_networking.dart';
import '../models/dining.dart';
import '../models/dining_menu.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';

const String baseEndpoint = "https://api-qa.ucsd.edu:8243/dining/v3.0.0";
Map<String, String> headers = {
  "accept": "application/json",
};

Future<void> getNewToken() async {
  final String tokenEndpoint = "https://api-qa.ucsd.edu:8243/token";
  final Map<String, String> tokenHeaders = {
    "content-type": 'application/x-www-form-urlencoded',
    "Authorization":
        "Basic djJlNEpYa0NJUHZ5akFWT0VRXzRqZmZUdDkwYTp2emNBZGFzZWpmaWZiUDc2VUJjNDNNVDExclVh"
  };
  var response = await NetworkHelper().authorizedPost(
      tokenEndpoint, tokenHeaders, "grant_type=client_credentials");

  headers["Authorization"] = "Bearer " + response["access_token"];
}

UseQueryResult<List<DiningModel>, dynamic> useFetchDiningModels() {
  return useQuery(['dining'], () async {
    while (true) { // run until token is valid
      try {
        /// fetch data
        String _response = await NetworkHelper()
            .authorizedFetch(baseEndpoint + '/locations', headers);
        debugPrint("DiningModel QUERY HOOK: FETCHING DATA!");

        /// parse data
        final data = diningModelFromJson(_response);
        return data;
      } catch (e) {
        if (e.toString().contains("401")) {
          await getNewToken();
        }
      }
    }
  });
}

UseQueryResult<DiningMenuItemsModel?, dynamic> useFetchDiningMenuModels(
    String? id) {
  return useQuery(['dining_menu', '$id'], () async {
    if (id == null) return null;
    while (true) { // run until token is valid
      try {
        /// fetch data
        String _response = await NetworkHelper()
            .authorizedFetch(baseEndpoint + '/menu/' + id, headers);
        debugPrint("DiningMenuModel QUERY HOOK: FETCHING DATA!");

        /// parse data
        final data = diningMenuItemsModelFromJson(_response);
        return data;
      } catch (e) {
        if (e.toString().contains("401")) {
          await getNewToken();
        }
      }
    }
  });
}

// the function below is used with useFetchDiningModels() to parse data
List<DiningModel> makeLocationsList(
    List<DiningModel> data, Coordinates? coordinates) {
  Map<String?, DiningModel> mapOfDiningLocations = Map<String?, DiningModel>();
  for (DiningModel model in data) {
    mapOfDiningLocations[model.name] = model;
  }
  if (coordinates == null) {
    return mapOfDiningLocations.values.toList();
  }
  List<DiningModel> orderedListOfLots = mapOfDiningLocations.values.toList();
  orderedListOfLots.sort((DiningModel a, DiningModel b) {
    if (a.distance != null && b.distance != null) {
      return a.distance!.compareTo(b.distance!);
    }
    return 0;
  });
  return orderedListOfLots;
}