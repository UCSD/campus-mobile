import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import '../../app_networking.dart';
import '../models/dining.dart';
import '../models/dining_menu.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/models/location.dart';

final String baseEndpoint = "https://api-qa.ucsd.edu:8243/dining/v3.0.0";
final Map<String, String> headers = {
  "accept": "application/json",
};

UseQueryResult<List<DiningModel>, dynamic> useFetchDiningModels()
{
  return useQuery(['dining'], () async {
    /// fetch data
    String _response = await NetworkHelper().authorizedFetch(
        baseEndpoint + '/locations', headers);
    debugPrint("DiningModel QUERY HOOK: FETCHING DATA!");

    /// parse data
    final data = diningModelFromJson(_response);
    return data;
  });
}

UseQueryResult<DiningMenuItemsModel, dynamic> useFetchDiningMenuModels(String id)
{
  return useQuery(['dining_menu','$id'], () async {
    /// fetch data
    String _response = await NetworkHelper().authorizedFetch(
        baseEndpoint + '/menu/' + id, headers);
    debugPrint("DiningMenuModel QUERY HOOK: FETCHING DATA!");

    /// parse data
    final data = diningMenuItemsModelFromJson(_response);
    return data;
  });
}

// the function below is used with useFetchDiningModels() to parse data
List<DiningModel> makeLocationsList (List<DiningModel> data, Coordinates? coordinates) {
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
