import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/services/message_service.dart';

//MESSAGES API UNIX TIMESTAMPS IN MILLISECONDS NOT SECONDS

class MessagesDataProvider extends ChangeNotifier {
  MessagesDataProvider() {
    /// DEFAULT STATES
    _isLoading = false;
    _messages = List<MessageElement>();
    _messageService = MessageService();
  }

  /// STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;
  int _previousTimestamp;

  /// MODELS
  List<MessageElement> _messages;
  UserDataProvider _userDataProvider;

  MessageService _messageService;

  //Fetch messages
  void fetchMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    _messages.clear();
    _previousTimestamp = 0;

    if (_userDataProvider != null && _userDataProvider.isLoggedIn) {
      retrieveMoreMyMessages();
    } else {
      retrieveMoreTopicMessages();
    }

    _isLoading = false;
    notifyListeners();
  }

  void retrieveMoreMyMessages() async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    int returnedTimestamp;
    int timestamp = _previousTimestamp;

    if (await _messageService.fetchMyMessagesData(timestamp)) {
      List<MessageElement> temp = _messageService.messagingModels.messages;
      _messages.addAll(temp);
      makeOrderedMessagesList();
      returnedTimestamp = _messages[_messages.length - 1].timestamp;
      _lastUpdated = DateTime.now();
      _previousTimestamp = returnedTimestamp;
    } else {
      _error = _messageService.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void retrieveMoreTopicMessages() async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    int returnedTimestamp;
    int timestamp = _previousTimestamp;

    if (await _messageService.fetchTopicData(timestamp)) {
      List<MessageElement> temp = _messageService.messagingModels.messages;
      _messages.addAll(temp);
      makeOrderedMessagesList();
      returnedTimestamp = _messages[_messages.length - 1].timestamp;
      _lastUpdated = DateTime.now();
      _previousTimestamp = returnedTimestamp;
    } else {
      _error = _messageService.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void makeOrderedMessagesList() {
    Map<String, MessageElement> uniqueMessages = Map<String, MessageElement>();
    uniqueMessages = Map.fromIterable(_messages,
        key: (message) => message.messageId, value: (message) => message);
    _messages.clear();
    uniqueMessages.forEach((k, v) => _messages.add(v));
    _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  ///This setter is only used in provider to supply and updated UserDataProvider object
  set userDataProvider(UserDataProvider value) {
    _userDataProvider = value;
  }

  /// SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;

  List<MessageElement> get messages {
    if (_messages != null) {
      return _messages;
    }
    return List<MessageElement>();
  }
}
