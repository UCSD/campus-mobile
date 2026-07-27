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

      final bool shouldTriggerFetch = notificationScrollController.position.pixels > triggerFetchMoreSize;
      if (shouldTriggerFetch) if (!_isLoading && _hasMoreMessagesToLoad) fetchMessages(false);
      setNotificationsScrollOffset(notificationScrollController.offset);
    });
  }

  /// STATES
  bool _isLoading = false;
  bool _hasMoreMessagesToLoad = false;
  DateTime? _lastUpdated;
  int _previousTimestamp = 0;
  String? _error;
  String _statusText = NotificationsConstants.STATUS_FETCHING;

  /// MODELS
  List<MessageElement> _messages = [];
  UserDataProvider? userDataProvider;

  /// SERVICES
  final _messageService = MessageService();
  final notificationScrollController = ScrollController();

  // Fetch messages
  Future<bool> fetchMessages(bool clearMessages) async {
    debugPrint(
      '[Messages] fetchMessages start clear=$clearMessages '
      'loggedIn=${userDataProvider?.isLoggedIn} raw=${_messages.length} visible=${messages.length}',
    );
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
      debugPrint(
        '[Messages] fetchMessages done clear=$clearMessages error=$_error '
        'raw=${_messages.length} visible=${messages.length}',
      );
      notifyListeners();
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
      final directCount = temp.where((message) => message.audience.topics == null).length;
      debugPrint('[Messages] retrieveMoreMyMessages fetched=${temp.length} direct=$directCount timestamp=$timestamp');
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
    _error = _messageService.error;
    debugPrint('[Messages] retrieveMoreMyMessages failed: $_error');
    return false;
  }

  Future<bool> retrieveMoreTopicMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    int returnedTimestamp;

    final bool topicDataFetched = await _messageService.fetchTopicData(
      _previousTimestamp,
      userDataProvider!.subscribedTopics!,
    );
    if (topicDataFetched) {
      List<MessageElement> temp = _messageService.messagingModels.messages;
      debugPrint(
        '[Messages] retrieveMoreTopicMessages fetched=${temp.length} '
        'topics=${userDataProvider!.subscribedTopics}',
      );
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
    _statusText = _messages.isEmpty ? NotificationsConstants.STATUS_NO_MESSAGES : NotificationsConstants.STATUS_NONE;
  }

  /// SIMPLE GETTERS
  get isLoading => _isLoading;
  get error => _error;
  get lastUpdated => _lastUpdated;
  get statusText => _statusText;
  get hasMoreMessagesToLoad => _hasMoreMessagesToLoad;
  ScrollController get scrollController => notificationScrollController;
  List<MessageElement> get messages {
    final subscribedTopics = userDataProvider?.subscribedTopics ?? [];
    return _messages.where((message) {
      final topics = message.audience.topics;
      if (topics == null) return userDataProvider?.isLoggedIn ?? false;
      return topics.any(subscribedTopics.contains);
    }).toList();
  }
}
