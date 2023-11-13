import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import '../../app_networking.dart';
import '../models/notifications_freefood.dart';
import '../services/notifications_freefood.dart';


final String baseEndpoint =
    'https://api-qa.ucsd.edu:8243/campusevents/1.0.0/';
final Map<String, String> headers = {
  "accept": "application/json",
};


Future<void> getNewToken() async {
  final String tokenEndpoint = "https://api-qa.ucsd.edu:8243/token";
  final Map<String, String> tokenHeaders = {
    "content-type": 'application/x-www-form-urlencoded',
    "Authorization":
    "Basic djJlNEpYa0NJUHZ5akFWT0VRXzRqZmZUdDkwYTp2emNBZGFzZWpmaWZiUDc2VUJjNDNNVDExclVh"
  };
  // try {
    var response = await NetworkHelper().authorizedPost(
        tokenEndpoint, tokenHeaders, "grant_type=client_credentials");

    headers["Authorization"] = "Bearer " + response["access_token"];
  //   return true;
  // } catch (e) {
  //   return false;
  // }
}

//helper function for fetch free food
Future<FreeFoodModel?> fetchDataWithRetries(String id, int maxRetries) async {
  for (int retryCount = 0; retryCount < maxRetries; retryCount++) {
    try {
      var _response = await NetworkHelper().authorizedFetch(
          baseEndpoint + 'events/' + id + '/rsvpCount', headers);
      debugPrint("DiningModel QUERY HOOK: FETCHING DATA!");

      final data = freeFoodModelFromJson(_response);
      return data;
    } catch (e) {
      if (e.toString().contains("401")) {
        await getNewToken(); // Retry the request with updated token
        continue; // Continue the loop for the next retry
      }
    }
  }
  return null;
}

UseQueryResult<FreeFoodModel?, dynamic>? useFetchFreeFoodModel(String id) {
  return useQuery(['free_food_data'], () async {
    try {
      return await fetchDataWithRetries(id, 5);
    } catch (e) {
      // Handle the timeout exception or other errors here
      return null;
    }
  });
}

//helper function for useFetchMaxFreeFood
Future<FreeFoodModel?> fetchMaxFreeFoodWithRetries(String id, int maxRetries) async {
  for (int retryCount = 0; retryCount < maxRetries; retryCount++) {
    try {
      var _response = await NetworkHelper().authorizedFetch(
          baseEndpoint + 'events/' + id + '/rsvpLimit', headers);
      debugPrint("DiningModel QUERY HOOK: FETCHING DATA!");

      final data = freeFoodModelFromJson(_response);
      return data;
    } catch (e) {
      if (e.toString().contains("401")) {
        await getNewToken(); // Retry the request with updated token
        continue; // Continue the loop for the next retry
      }
    }
  }
  return null;
}

UseQueryResult<FreeFoodModel?, dynamic> useFetchMaxFreeFood(String id) {
  return useQuery(['free_food_max'], () async {
    try {
      return await fetchMaxFreeFoodWithRetries(id, 5);
    } catch (e) {
      // Handle the timeout exception or other errors here
      return null;
    }
  });
}


Future<bool> updateCount(String id, Map<String, dynamic> body) async {
  try {
    String _url = baseEndpoint + 'events/' + id;

    /// update count
    var _response = await NetworkHelper().authorizedPut(_url, headers, body);

    if (_response != null) {
      return true;
    } else {
      throw (_response.toString());
    }
  } catch (e) {
    /// if the authorized fetch failed we know we have to refresh the
    /// token for this service
    if (e.toString().contains("401")) {
      getNewToken();
      return await updateCount(id, body);
    }
    return false;
  }
}