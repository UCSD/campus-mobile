import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/news.dart';

class NewsService {
  NewsService();
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  final String endpoint =
      "https://api-qa.ucsd.edu:8243/campusnews/1.0.0/ucsdnewsaggregator";

  NewsModel _newsModels = NewsModel();

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      await getNewToken();
      String _response =
          await (_networkHelper.authorizedFetch(endpoint, headers));

      /// parse data
      _newsModels = newsModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      if (e.toString().contains("401")) {
        if (await getNewToken()) {
          return await fetchData();
        }
      }

      _error = e.toString();
      _isLoading = false;
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
      var response = await _networkHelper.authorizedPost(
          tokenEndpoint, tokenHeaders, "grant_type=client_credentials");
      var splitted = response.split('"');
      String accessToken = splitted[3];
      headers["Authorization"] = "Bearer " + accessToken;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  String? get error => _error;
  NewsModel get newsModels => _newsModels;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
