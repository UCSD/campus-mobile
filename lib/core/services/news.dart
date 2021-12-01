import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/news.dart';

class NewsService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  final NetworkHelper _networkHelper = NetworkHelper();
  final String endpoint =
      'https://dy6k9h2x5k.execute-api.us-west-2.amazonaws.com/qa/campusnews/v1/ucsdnewsaggregator';

  NewsModel _newsModels = NewsModel();

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(endpoint);

      /// parse data
      _newsModels = newsModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
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
