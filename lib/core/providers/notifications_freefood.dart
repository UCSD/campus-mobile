import 'dart:collection';

import 'package:campus_mobile_experimental/core/models/notifications.dart';
import 'package:campus_mobile_experimental/core/models/notifications_freefood.dart';
import 'package:campus_mobile_experimental/core/providers/messages.dart';
import 'package:campus_mobile_experimental/core/services/notifications_freefood.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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
    _registeredEvents = new List<String>();
  }

  ///VALUES
  HashMap<String, int> _messageToCount;
  HashMap<String, int> _messageToMaxCount;
  List<String> _registeredEvents;

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
      if (m.audience != null && m.audience.topics.contains("freeFood")) {
        fetchCount(m.messageId);
        fetchMaxCount(m.messageId);
      }
    });
  }

  Future loadRegisteredEvents() async {
    var box = await Hive.openBox('freefoodRegisteredEvents');
    if (box.get('freefoodRegisteredEvents') == null) {
      await box.put('freefoodRegisteredEvents', _registeredEvents);
    }
    _registeredEvents = box.get('freefoodRegisteredEvents');
    notifyListeners();
  }

  Future updateRegisteredEvents(List<String> messageIds) async {
    _registeredEvents = messageIds;
    var box = await Hive.openBox('freefoodRegisteredEvents');
    await box.put('freefoodRegisteredEvents', _registeredEvents);
    _lastUpdated = DateTime.now();
    notifyListeners();
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

    _registeredEvents.remove(id);
    await updateRegisteredEvents(_registeredEvents);

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

    _registeredEvents.add(id);
    await updateRegisteredEvents(_registeredEvents);

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
    if (_messageToCount.containsKey(messageId) &&
        _messageToMaxCount.containsKey(messageId)) {
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
  List<String> get registeredEvents => _registeredEvents;

  bool isLoading(String id) => id == _curId;
}
