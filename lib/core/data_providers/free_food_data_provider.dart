import 'package:campus_mobile_experimental/core/data_providers/messages_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/free_food_model.dart';
import 'package:campus_mobile_experimental/core/models/message_model.dart';
import 'package:campus_mobile_experimental/core/services/free_food_service.dart';
import 'package:flutter/material.dart';
import 'dart:collection';

class FreeFoodDataProvider extends ChangeNotifier {
  FreeFoodDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _freeFoodService = FreeFoodService();
    _freeFoodModel = FreeFoodModel();

    ///INITIALIZE VALUES
    _messageToCount = new HashMap<String, int>();
  }

  ///VALUES
  HashMap<String, int> _messageToCount;

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;

  ///MODELS
  FreeFoodModel _freeFoodModel;
  MessagesDataProvider _messageDataProvider;

  ///SERVICES
  FreeFoodService _freeFoodService;

  void parseMessages() {
    List<MessageElement> messages = _messageDataProvider.messages;
    messages.forEach((m) async {
      if(m.audience != null && m.audience.topics.contains("freefood")) {
        fetchCount(m.messageId);
      }
    });
  }

  void fetchCount(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _freeFoodService.fetchData(id)) {
      _freeFoodModel = _freeFoodService.freeFoodModel;
      _lastUpdated = DateTime.now();
      _messageToCount[id] = _freeFoodModel.body.count;
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
    fetchCount(id);
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
    fetchCount(id);
    notifyListeners();
  }

  int count(String messageId) => _messageToCount[messageId];

  bool isFreeFood(String messageId) => _messageToCount.containsKey(messageId);

  /// SETTER
  set messageDataProvider(MessagesDataProvider value) {
    _messageDataProvider = value;
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  FreeFoodModel get freeFoodModel => _freeFoodModel;
}
