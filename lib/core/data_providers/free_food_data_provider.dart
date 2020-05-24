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
    _messageToMaxCount = new HashMap<String, int>();
  }

  ///VALUES
  HashMap<String, int> _messageToCount;
  HashMap<String, int> _messageToMaxCount;

  ///STATES
  bool _isLoading;
  String _curId;
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
        fetchMaxCount(m.messageId);
      }
    });
  }

  void fetchCount(String id) async {
    _isLoading = true;
    _curId = id;
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
    _curId = null;
    notifyListeners();
  }

  void fetchMaxCount(String id) async {
    _isLoading = true;
    _curId = id;
    _error = null;

    notifyListeners();

    if (await _freeFoodService.fetchMaxCount(id)) {
      _freeFoodModel = _freeFoodService.freeFoodModel;
      _lastUpdated = DateTime.now();
      _messageToMaxCount[id] = _freeFoodModel.body.maxCount;
    } else {
      _error = _freeFoodService.error;
    }

    _isLoading = false;
    _curId = null;
    notifyListeners();
  }

   void decrementCount(String id) async {
    _isLoading = true;
    _curId = id;
    _error = null;

    notifyListeners();

    if (await _freeFoodService.decrementCount(id)) {
      _freeFoodModel = _freeFoodService.freeFoodModel;
      _lastUpdated = DateTime.now();
    } else {
      _error = _freeFoodService.error;
    }

    _isLoading = false;
    _curId = null;
    fetchCount(id);
    notifyListeners();
  }

  void incrementCount(String id) async {
    _isLoading = true;
    _curId = id;
    _error = null;

    notifyListeners();

    if (await _freeFoodService.incrementCount(id)) {
      _freeFoodModel = _freeFoodService.freeFoodModel;
      _lastUpdated = DateTime.now();
    } else {
      _error = _freeFoodService.error;
    }

    _isLoading = false;
    _curId = null;
    fetchCount(id);
    notifyListeners();
  }

  int count(String messageId) => _messageToCount[messageId];
  
  bool isOverCount(String messageId) {
    if(_messageToCount.containsKey(messageId) && _messageToMaxCount.containsKey(messageId)) {
      return _messageToCount[messageId] > _messageToMaxCount[messageId];
    }
    return false;
  }
  bool isFreeFood(String messageId) => _messageToCount.containsKey(messageId);

  /// SETTER
  set messageDataProvider(MessagesDataProvider value) {
    _messageDataProvider = value;
  }

  ///SIMPLE GETTERS
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  FreeFoodModel get freeFoodModel => _freeFoodModel;

  bool isLoading(String id) => id == _curId;
}
