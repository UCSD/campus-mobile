import 'package:campus_mobile_experimental/core/models/free_food_model.dart';
import 'package:campus_mobile_experimental/core/services/free_food_service.dart';
import 'package:flutter/material.dart';

class FreeFoodDataProvider extends ChangeNotifier {
  FreeFoodDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _freeFoodService = FreeFoodService();
    _freeFoodModel = FreeFoodModel();
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;

  ///MODELS
  FreeFoodModel _freeFoodModel;

  ///SERVICES
  FreeFoodService _freeFoodService;

  void fetchCount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _freeFoodService.fetchData()) {
      _freeFoodModel = _freeFoodService.freeFoodModel;
      _lastUpdated = DateTime.now();
    } else {
      _error = _freeFoodService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

   void decrementCount(String id) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    if (await _freeFoodService.decrementCount(id)) {
      _freeFoodModel = _freeFoodService.freeFoodModel;
      _lastUpdated = DateTime.now();
    } else {
      _error = _freeFoodService.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void incrementCount(String id) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    if (await _freeFoodService.incrementCount(id)) {
      _freeFoodModel = _freeFoodService.freeFoodModel;
      _lastUpdated = DateTime.now();
    } else {
      _error = _freeFoodService.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  FreeFoodModel get freeFoodModel => _freeFoodModel;
}
