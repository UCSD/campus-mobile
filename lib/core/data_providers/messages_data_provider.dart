import 'package:campus_mobile_experimental/core/constants/notifications_constants.dart';
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
    _statusText = NotificationsConstants.statusFetching;
  }

  /// STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;
  int _previousTimestamp;
  String _statusText;

  /// MODELS
  List<MessageElement> _messages;
  UserDataProvider _userDataProvider;

  MessageService _messageService;

  //Fetch messages
  void fetchMessages() async {
    _isLoading = true;
    _statusText = NotificationsConstants.statusFetching;
    _error = null;
    notifyListeners();
    _previousTimestamp = DateTime.now().millisecondsSinceEpoch;
    var clearMessages = true;

    if (_userDataProvider != null && _userDataProvider.isLoggedIn) {
      retrieveMoreMyMessages(clearMessages);
    } else {
      retrieveMoreTopicMessages(clearMessages);
    }

    _isLoading = false;
    notifyListeners();
  }

  void retrieveMoreMyMessages(bool clearMessages) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    int returnedTimestamp;
    int timestamp = _previousTimestamp;
    Map<String, String> headers = {
      "accept": "application/json",
      "Authorization":
          "Bearer " + _userDataProvider.authenticationModel.accessToken,
    };
    if (await _messageService.fetchMyMessagesData(timestamp, headers)) {
      List<MessageElement> temp = _messageService.messagingModels.messages;
      updateMessages(temp, clearMessages);
      makeOrderedMessagesList();

      returnedTimestamp = _messageService.messagingModels.next == null
          ? 0
          : _messageService.messagingModels.next;
      _lastUpdated = DateTime.now();
      _previousTimestamp = returnedTimestamp;
    } else {
      if (_messageService.error ==
          'DioError [DioErrorType.RESPONSE]: Http status error [401]') {
        _userDataProvider.refreshToken();
      }
      _error = _messageService.error;
      _statusText = NotificationsConstants.statusFetchProblem;
    }

    _isLoading = false;
    notifyListeners();
  }

  void retrieveMoreTopicMessages(bool clearMessages) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    int returnedTimestamp;
    int timestamp = _previousTimestamp;

    if (await _messageService.fetchTopicData(timestamp)) {
      List<MessageElement> temp = _messageService.messagingModels.messages;
      updateMessages(temp, clearMessages);
      makeOrderedMessagesList();

      returnedTimestamp = _messageService.messagingModels.next == null
          ? 0
          : _messageService.messagingModels.next;
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

  updateMessages(List<MessageElement> newMessages, bool clearMessages) {
    if (clearMessages) {
      _messages = newMessages;
    } else {
      _messages.addAll(newMessages);
    }

    if (_messages.length == 0) {
      _statusText = NotificationsConstants.statusNoMessages;
    } else {
      _statusText = NotificationsConstants.statusNone;
    }
  }

  ///This setter is only used in provider to supply and updated UserDataProvider object
  set userDataProvider(UserDataProvider value) {
    _userDataProvider = value;
  }

  /// SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  String get statusText => _statusText;

  List<MessageElement> get messages {
    if (_messages != null) {
      return _messages;
    }
    return List<MessageElement>();
  }
}
