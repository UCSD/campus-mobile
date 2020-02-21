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

    /// TODO: initialize services here
    _messageService = MessageService();
  }

  /// STATES
  /// TODO: create any other states needed for the feature
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;
  int _previousTimestamp;

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

    //print("called fetch");
    notifyListeners();
     _messages.clear();
    _previousTimestamp = 0;

    if(_userDataProvider != null && _userDataProvider.isLoggedIn){
      retrieveMoreMyMessages();
    }
    else{
      retrieveMoreTopicMessages();
    }

    _isLoading = false;
    notifyListeners();
  }

  void refreshMessages() async {
    _isLoading = true;
    _error = null;

    //print("called fetch");
    notifyListeners();
    _previousTimestamp = 0;

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
    _isLoading = true;
    _error = null;

    notifyListeners();

    int returnedTimestamp;
    //print(_previousTimestamp);
    int timestamp = _previousTimestamp;

    if(await _messageService.fetchMyMessagesData(timestamp)){
      List<MessageElement>temp = _messageService.messagingModels.messages;
      _messages.addAll(temp);
      makeOrderedMessagesList();
      returnedTimestamp = _messages[_messages.length - 1].timestamp;
      print("something here: " + returnedTimestamp.toString());
      _lastUpdated = DateTime.now();
      _previousTimestamp = returnedTimestamp;
    }
    else{
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

    if(await _messageService.fetchTopicData(timestamp)){
      List<MessageElement>temp = _messageService.messagingModels.messages;
      _messages.addAll(temp);
      makeOrderedMessagesList();
      returnedTimestamp = _messages[_messages.length - 1].timestamp;
      print("another time: " + returnedTimestamp.toString());
      _lastUpdated = DateTime.now();
      _previousTimestamp = returnedTimestamp;
    }
    else{
      _error = _messageService.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void makeOrderedMessagesList(){
    Map<String,MessageElement>uniqueMessages = Map<String,MessageElement>();
    uniqueMessages = Map.fromIterable(_messages, key: (message) => message.messageId, value: (message) => message);
    _messages.clear();
    uniqueMessages.forEach((k,v) => _messages.add(v));
    _messages.sort((a,b) => b.timestamp.compareTo(a.timestamp));
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