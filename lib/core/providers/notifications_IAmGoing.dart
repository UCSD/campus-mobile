// ignore_for_file: unused_field

import 'dart:collection';

import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/notifications.dart';
import 'package:campus_mobile_experimental/core/models/notifications_IAmGoing.dart';
import 'package:campus_mobile_experimental/core/providers/messages.dart';
import 'package:campus_mobile_experimental/core/services/notifications_IAmGoing.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class IAmGoingProvider extends ChangeNotifier {
  IAmGoingProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _freeFoodService = FreeFoodService();
    _freeFoodModel = IAmGoingModel();

    ///INITIALIZE VALUES
    initializeValues();
  }

  ///VALUES
  late HashMap<String, int?> _messageToCount;
  late HashMap<String, int?> _messageToMaxCount;
  List<String>? _registeredEvents;

  ///STATES
  bool? _isLoading;
  String? _curId;
  DateTime? _lastUpdated;
  String? _error;

  ///MODELS
  IAmGoingModel? _freeFoodModel;
  late MessagesDataProvider _messageDataProvider;

  ///SERVICES
  late FreeFoodService _freeFoodService;

  void initializeValues() {
    _messageToCount = new HashMap<String, int?>();
    _messageToMaxCount = new HashMap<String, int?>();
    _registeredEvents = [];
  }

  void removeId(String id) {
    _messageToCount.remove(id);
    _messageToMaxCount.remove(id);
    _registeredEvents!.remove(id);
  }

  //parses event message topic to determine if it is an IAmGoing event
  void parseMessages() {
    // initializeValues();
    List<MessageElement?> messages = _messageDataProvider.messages!;
    messages.forEach((m) async {
      if (m!.audience != null &&
          m.audience!.topics != null &&
          (m.audience!.topics!.contains("freeFood") ||
              m.audience!.topics!.contains("campusInnovationEvents"))) {
        fetchCount(m.messageId!);
        fetchMaxCount(m.messageId!);
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

  Future updateRegisteredEvents(List<String>? messageIds) async {
    _registeredEvents = messageIds;
    var box = await Hive.openBox('freefoodRegisteredEvents');
    await box.put('freefoodRegisteredEvents', _registeredEvents);
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  Future<void> fetchCount(String id) async {
    _isLoading = true;
    _curId = id;

    notifyListeners();

    if (await _freeFoodService.fetchData(id)) {
      _freeFoodModel = _freeFoodService.freeFoodModel;
      _lastUpdated = DateTime.now();
      _messageToCount[id] = _freeFoodModel!.body!.count;
    } else {
      _error = _freeFoodService.error;
      if (_error != null &&
          _error!.contains(ErrorConstants.invalidBearerToken)) {
        if (await _freeFoodService.getNewToken()) {
          await fetchCount(id);
        }
      }
      removeId(id);
    }
    _isLoading = false;
    _curId = null;
    notifyListeners();
  }

  Future<void> fetchMaxCount(String id) async {
    _isLoading = true;
    _curId = id;

    notifyListeners();

    if (await _freeFoodService.fetchMaxCount(id)) {
      _freeFoodModel = _freeFoodService.freeFoodModel;
      _lastUpdated = DateTime.now();
      _messageToMaxCount[id] = _freeFoodModel!.body!.maxCount;
    } else {
      _error = _freeFoodService.error;
      if (_error != null &&
          _error!.contains(ErrorConstants.invalidBearerToken)) {
        if (await _freeFoodService.getNewToken()) {
          await fetchMaxCount(id);
        }
      }
      removeId(id);
    }

    _isLoading = false;
    _curId = null;
    notifyListeners();
  }

  void incrementCount(String id) async {
    final Map<String, dynamic> body = {'count': '+1'};
    _registeredEvents!.add(id);
    updateCount(id, body);
  }

  void decrementCount(String id) async {
    final Map<String, dynamic> body = {'count': '-1'};
    _registeredEvents!.remove(id);
    updateCount(id, body);
  }

  Future<void> updateCount(String id, Map<String, dynamic> body) async {
    _isLoading = true;
    _curId = id;
    notifyListeners();
    await updateRegisteredEvents(_registeredEvents);

    if (await _freeFoodService.updateCount(id, body)) {
      _freeFoodModel = _freeFoodService.freeFoodModel;
      _lastUpdated = DateTime.now();
    } else {
      _error = _freeFoodService.error;
      if (_error != null &&
          _error!.contains(ErrorConstants.invalidBearerToken)) {
        if (await _freeFoodService.getNewToken()) {
          await updateCount(id, body);
        }
      }
      removeId(id);
    }

    _isLoading = false;
    _curId = null;
    fetchCount(id);
    notifyListeners();
  }

  int? count(String? messageId) => _messageToCount[messageId!];

  bool isOverCount(String? messageId) {
    if (_messageToCount.containsKey(messageId) &&
        _messageToMaxCount.containsKey(messageId)) {
      return _messageToCount[messageId!]! > _messageToMaxCount[messageId]!;
    }
    return false;
  }

  bool isFreeFood(String? messageId) => _messageToCount.containsKey(messageId);

  /// SETTER
  set messageDataProvider(MessagesDataProvider value) {
    _messageDataProvider = value;
  }

  ///SIMPLE GETTERS
  String? get error => _error;

  DateTime? get lastUpdated => _lastUpdated;

  IAmGoingModel? get freeFoodModel => _freeFoodModel;

  List<String>? get registeredEvents => _registeredEvents;

  bool isLoading(String? id) => id == _curId;
}
