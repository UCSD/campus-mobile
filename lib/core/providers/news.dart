import 'package:campus_mobile_experimental/core/models/news.dart';
import 'package:campus_mobile_experimental/core/services/news.dart';
import 'package:flutter/material.dart';

class NewsDataProvider extends ChangeNotifier {
  NewsDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _newsService = NewsService();
    _newsModels = NewsModel();
  }

  ///STATES
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;

  ///MODELS
  NewsModel? _newsModels;

  ///SERVICES
  late NewsService _newsService;

  void fetchNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _newsService.fetchData()) {
      _newsModels = _newsService.newsModels;
      _lastUpdated = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error = _newsService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool? get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  NewsModel? get newsModels => _newsModels;
}
