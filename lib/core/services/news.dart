import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/news.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewsService {
  NewsService();

  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  /// MODELS
  NewsModel _newsModels = NewsModel();

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await (NetworkHelper.authorizedFetch(
          dotenv.get('NEWS_ENDPOINT'), headers));

      /// parse data
      _newsModels = newsModelFromJson(_response);
      return true;
    } catch (e) {
      if (e.toString().contains("401")) {
        if (await NetworkHelper.getNewToken(headers)) return await fetchData();
      }
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// SIMPLE GETTERS
  get error => _error;
  get isLoading => _isLoading;
  get lastUpdated => _lastUpdated;
  NewsModel get newsModels => _newsModels;
}
