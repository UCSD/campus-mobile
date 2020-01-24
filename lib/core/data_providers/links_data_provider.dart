import 'package:campus_mobile_experimental/core/models/links_model.dart';
import 'package:campus_mobile_experimental/core/services/links_service.dart';
import 'package:flutter/material.dart';

class LinksDataProvider extends ChangeNotifier {
  LinksDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _linksService = LinksService();
    _linksModels = List<LinksModel>();
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;

  ///MODELS
  List<LinksModel> _linksModels;

  ///SERVICES
  LinksService _linksService;

  void fetchLinks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _linksService.fetchData()) {
      _linksModels = _linksService.linksModels;
      _lastUpdated = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error = _linksService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  List<LinksModel> get linksModels => _linksModels;
}
