import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:campus_mobile_experimental/core/services/message_service.dart';

class MessagesDataProvider extends ChangeNotifier {
  MessagesDataProvider() {
    /// DEFAULT STATES
    _isLoading = false;

    /// TODO: initialize services here
    _messageService = MessageService();
  }

  /// STATES
  /// TODO: create any other states needed for the feature
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;

  /// MODELS
  /// TODO: add models that will be needed in this data provider
  List<Message> _messages;
  List<Message> _privateMessages;
  UserDataProvider _userDataProvider;

  ///
  /// DATA PROVIDERS
  /// TODO: add data providers that will be needed if this is a dependent data provider
  /// create setters for each of these providers

  /// SERVICES
  /// TODO: split fetchMessages() into fetchPrivateMessages() and fetchPublicMessages()
  MessageService _messageService;

  void fetchMessages() async {
    _isLoading = true;
    _error = null;

    notifyListeners();
    /// creating  new map ensures we remove all unsupported lots
    //Map<String, MessagingModel> newMapOfLots =
        //Map<String, MessagingModel>();
    if (await _messageService.fetchData()) {
      for (Message message in _messageService.messagingModels.messages) {
        _messages.add(message);
      }

      _lastUpdated = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error = _messageService.error;
    }
    _isLoading = false;
    notifyListeners();
  }



  ///This setter is only used in provider to supply and updated UserDataProvider object
  set userDataProvider(UserDataProvider value) {
    _userDataProvider = value;
  }

  /// SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;

  List<Message> get messages {
    if (_messages != null) {
      ///check if we have an offline _userProfileModel
      if (_userDataProvider.userProfileModel != null) {
        //Return private and public messages in chronological order here
        //Make new method for makeOrderedList
        return makeOrderedList(
            _userDataProvider.userProfileModel.selectedOccuspaceLocations);
      }
      return messages;
    }
    return List<Message>();
  }
}
