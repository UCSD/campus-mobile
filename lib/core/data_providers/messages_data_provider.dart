import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/services/message_service.dart';

class MessagesDataProvider extends ChangeNotifier {
  MessagesDataProvider() {
    /// DEFAULT STATES
    _isLoading = false;
    _messages = List<MessageElement>();

    /// TODO: initialize services here
    _messageService = MessageService();
  }

  /// STATES
  /// TODO: create any other states needed for the feature
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;
  int previousTimestamp;

  /// MODELS
  /// TODO: add models that will be needed in this data provider
  List<MessageElement> _messages;
  //List<Message> _privateMessages;
  UserDataProvider _userDataProvider;

  /// DATA PROVIDERS
  /// TODO: add data providers that will be needed if this is a dependent data provider
  /// create setters for each of these providers

  /// SERVICES
  /// TODO: split fetchMessages() into fetchPrivateMessages() and fetchPublicMessages()
  /// if functionality is split in the API
  MessageService _messageService;

  //Fetch messages
  void fetchMessages() async {
    _isLoading = true;
    _error = null;

    print("called fetch");
    notifyListeners();

    if(_userDataProvider != null && _userDataProvider.isLoggedIn){
      retrieveMoreMyMessages();
    }
    else{
      retrieveMoreTopicMessages();
    }

    _isLoading = false;
    notifyListeners();
  }

  void retrieveMoreMyMessages() async {
    int returnedTimestamp;
    int timestamp = previousTimestamp;

    if(await _messageService.fetchMyMessagesData(timestamp)){
        returnedTimestamp = _messageService.messagingModels.messages[_messageService.messagingModels.messages.length - 1].timestamp;
        print(returnedTimestamp);
        List<MessageElement>temp = _messageService.messagingModels.messages;
        if(timestamp != 0){
          temp.removeAt(0);
        }
        _messages.addAll(temp);
        _lastUpdated = DateTime.now();
        previousTimestamp = returnedTimestamp;
      }
      else{
        _error = _messageService.error;
      }
  }

  void retrieveMoreTopicMessages() async {
    int returnedTimestamp;
    int timestamp = previousTimestamp;

    if(await _messageService.fetchTopicData(timestamp)){
        returnedTimestamp = _messageService.messagingModels.messages[_messageService.messagingModels.messages.length - 1].timestamp;
        print(returnedTimestamp);
        List<MessageElement>temp = _messageService.messagingModels.messages;
        if(timestamp != 0){
          temp.removeAt(0);
        }
        _messages.addAll(temp);
        _lastUpdated = DateTime.now();
        previousTimestamp = returnedTimestamp;
      }
      else{
        _error = _messageService.error;
      }
  }

  //TODO: Need to fix ordering of messages, dependent on API feedback
  List<MessageElement>makeOrderedMessagesList(){
    Map<String,MessageElement>uniqueMessages = Map<String,MessageElement>();
    uniqueMessages = Map.fromIterable(_messages, key: (message) => message.messageId, value: (message) => message);
    _messages.clear();
    uniqueMessages.forEach((k,v) => _messages.add(v));
    _messages.sort((a,b) => b.timestamp.compareTo(a.timestamp));
    print("Size of _messages: " + _messages.length.toString());
    return _messages;
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
      return makeOrderedMessagesList();
    }
    return List<MessageElement>();
  }
  
}