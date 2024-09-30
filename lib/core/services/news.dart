import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/news.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewsService {
  NewsService();
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  NewsModel _newsModels = NewsModel();

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await (_networkHelper.authorizedFetch(dotenv.get('NEWS_ENDPOINT'), headers));

      /// parse data
      _newsModels = newsModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      if (e.toString().contains("401")) {
        if (await _networkHelper.getNewToken(headers)) {
          return await fetchData();
        }
      }

      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  String? get error => _error;
  NewsModel get newsModels => _newsModels;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
