import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/notifications.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/messages.dart';
import 'package:flutter/material.dart';

//MESSAGES API UNIX TIMESTAMPS IN MILLISECONDS NOT SECONDS

class MessagesDataProvider extends ChangeNotifier {
  MessagesDataProvider() {
    /// DEFAULT STATES
    _isLoading = false;
    _messages = List<MessageElement>();
    _messageService = MessageService();
    _statusText = NotificationsConstants.statusFetching;
    _hasMoreMessagesToLoad = false;
    _scrollController = ScrollController();
    _scrollController
      ..addListener(() {
        var triggerFetchMoreSize =
            0.9 * _scrollController.position.maxScrollExtent;

        if (_scrollController.position.pixels > triggerFetchMoreSize) {
          if (!_isLoading && _hasMoreMessagesToLoad) {
            fetchMessages(false);
          }
        }
      });
  }

  /// STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;
  int _previousTimestamp;
  String _statusText;
  bool _hasMoreMessagesToLoad;
  ScrollController _scrollController;

  /// MODELS
  List<MessageElement> _messages;
  UserDataProvider _userDataProvider;

  MessageService _messageService;

  //Fetch messages
  Future<bool> fetchMessages(bool clearMessages) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (clearMessages) {
      _clearMessages();
    }
    if (_userDataProvider != null && _userDataProvider.isLoggedIn) {
      var returnVal = await retrieveMoreMyMessages();
      _isLoading = false;
      return returnVal;
    } else {
      var returnVal = await retrieveMoreTopicMessages();
      _isLoading = false;
      return returnVal;
    }
  }

  void _clearMessages() {
    _messages = List<MessageElement>();
    _hasMoreMessagesToLoad = false;
    _previousTimestamp = DateTime.now().millisecondsSinceEpoch;
  }

  Future<bool> retrieveMoreMyMessages() async {
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
      updateMessages(temp);
      makeOrderedMessagesList();

      returnedTimestamp = _messageService.messagingModels.next == null
          ? 0
          : _messageService.messagingModels.next;
      // this is to check if we can no more message to paginate through
      if (_previousTimestamp == returnedTimestamp || returnedTimestamp == 0) {
        _hasMoreMessagesToLoad = false;
      } else {
        _hasMoreMessagesToLoad = true;
      }
      _lastUpdated = DateTime.now();
      _previousTimestamp = returnedTimestamp;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      if (_messageService.error ==
          'DioError [DioErrorType.RESPONSE]: Http status error [401]') {
        await _userDataProvider.silentLogin();
        headers["Authorization"] =
            "Bearer " + _userDataProvider.authenticationModel.accessToken;
        if (await _messageService.fetchMyMessagesData(timestamp, headers)) {
          List<MessageElement> temp = _messageService.messagingModels.messages;
          updateMessages(temp);
          makeOrderedMessagesList();

          returnedTimestamp = _messageService.messagingModels.next == null
              ? 0
              : _messageService.messagingModels.next;
          // this is to check if we can no more message to paginate through
          if (_previousTimestamp == returnedTimestamp ||
              returnedTimestamp == 0) {
            _hasMoreMessagesToLoad = false;
          } else {
            _hasMoreMessagesToLoad = true;
          }
          _lastUpdated = DateTime.now();
          _previousTimestamp = returnedTimestamp;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = _messageService.error;
          _statusText = NotificationsConstants.statusFetchProblem;
        }
      }
      _error = _messageService.error;
      _statusText = NotificationsConstants.statusFetchProblem;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> retrieveMoreTopicMessages() async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    int returnedTimestamp;

    if (await _messageService.fetchTopicData(
        _previousTimestamp, _userDataProvider.subscribedTopics)) {
      List<MessageElement> temp = _messageService.messagingModels.messages;
      updateMessages(temp);
      makeOrderedMessagesList();

      returnedTimestamp = _messageService.messagingModels.next ?? 0;
      // this is to check if we can no more message to paginate through
      if (_previousTimestamp == returnedTimestamp || returnedTimestamp == 0) {
        _hasMoreMessagesToLoad = false;
      } else {
        _hasMoreMessagesToLoad = true;
      }
      _lastUpdated = DateTime.now();
      _previousTimestamp = returnedTimestamp;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = _messageService.error;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void makeOrderedMessagesList() {
    Map<String, MessageElement> uniqueMessages = Map<String, MessageElement>();
    uniqueMessages = Map.fromIterable(_messages,
        key: (message) => message.messageId, value: (message) => message);
    _messages.clear();
    uniqueMessages.forEach((k, v) => _messages.add(v));
    _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  updateMessages(List<MessageElement> newMessages) {
    _messages.addAll(newMessages);
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
  bool get hasMoreMessagesToLoad => _hasMoreMessagesToLoad;
  ScrollController get scrollController => _scrollController;
  UserDataProvider get userDataProvider => _userDataProvider;

  List<MessageElement> get messages {
    if (_messages != null) {
      return _messages;
    }
    return List<MessageElement>();
  }
}
