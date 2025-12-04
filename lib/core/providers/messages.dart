import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/notifications.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/messages.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/ui/navigator/bottom.dart';

// MESSAGES API UNIX TIMESTAMPS IN MILLISECONDS NOT SECONDS
var notificationScrollController = ScrollController();

class MessagesDataProvider extends ChangeNotifier {
  MessagesDataProvider() {
    /// DEFAULT STATES
    notificationScrollController.addListener(() {
      var triggerFetchMoreSize = 0.9 * notificationScrollController.position.maxScrollExtent;

      if (notificationScrollController.position.pixels > triggerFetchMoreSize) if (!_isLoading &&
          _hasMoreMessagesToLoad) fetchMessages(false);
      setNotificationsScrollOffset(notificationScrollController.offset);
    });
  }

  /// STATES
  bool _isLoading = false;
  bool _hasMoreMessagesToLoad = false;
  DateTime? _lastUpdated;
  int _previousTimestamp = 0;
  String? _error;
  String _statusText = NotificationsConstants.statusFetching;

  /// MODELS
  List<MessageElement> _messages = [];
  UserDataProvider? userDataProvider;

  /// SERVICES
  final _messageService = MessageService();
  final notificationScrollController = ScrollController();

  // Fetch messages
  Future<bool> fetchMessages(bool clearMessages) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (clearMessages) _clearMessages();
      return userDataProvider != null && userDataProvider!.isLoggedIn
          ? await retrieveMoreMyMessages()
          : await retrieveMoreTopicMessages();
    } finally {
      _isLoading = false;
    }
  }

  void _clearMessages() {
    _messages = [];
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
      "Authorization": "Bearer " + userDataProvider!.authenticationModel.accessToken!,
    };

    if (await _messageService.fetchMyMessagesData(timestamp, headers)) {
      List<MessageElement> temp = _messageService.messagingModels.messages;
      updateMessages(temp);
      makeOrderedMessagesList();
      returnedTimestamp = _messageService.messagingModels.next ?? 0;
      // checks if we have no more messages to paginate through
      _hasMoreMessagesToLoad = !(_previousTimestamp == returnedTimestamp || returnedTimestamp == 0);
      _lastUpdated = DateTime.now();
      _previousTimestamp = returnedTimestamp;
      _isLoading = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> retrieveMoreTopicMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    int returnedTimestamp;

    if (await _messageService.fetchTopicData(_previousTimestamp, userDataProvider!.subscribedTopics!)) {
      List<MessageElement> temp = _messageService.messagingModels.messages;
      updateMessages(temp);
      makeOrderedMessagesList();
      returnedTimestamp = _messageService.messagingModels.next ?? 0;
      // checks if we have no more messages to paginate through
      _hasMoreMessagesToLoad = !(_previousTimestamp == returnedTimestamp || returnedTimestamp == 0);
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
    uniqueMessages = Map.fromIterable(_messages, key: (message) => message.messageId, value: (message) => message);
    _messages.clear();
    uniqueMessages.forEach((k, v) => _messages.add(v));
    _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void updateMessages(List<MessageElement> newMessages) {
    _messages.addAll(newMessages);
    _statusText = _messages.isEmpty ? NotificationsConstants.statusNoMessages : NotificationsConstants.statusNone;
  }

  /// SIMPLE GETTERS
  get isLoading => _isLoading;
  get error => _error;
  get lastUpdated => _lastUpdated;
  get statusText => _statusText;
  get hasMoreMessagesToLoad => _hasMoreMessagesToLoad;
  ScrollController get scrollController => notificationScrollController;
  List<MessageElement> get messages => _messages;
}
