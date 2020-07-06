import 'package:campus_mobile_experimental/core/models/cards_model.dart';
import 'package:campus_mobile_experimental/core/services/cards_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CardsDataProvider extends ChangeNotifier {
  CardsDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;
    _cardStates = {
      'availability': true,
      'events': true,
      'news': true,
      'parking': true,
      'special_events': true,
      'weather': true,
      'dining': true,
      'MyStudentChart': true
    };
    _studentCards = ['student_id', 'finals', 'schedule'];
    _cardOrder = [
//      'special_events',
      'MyStudentChart',
      'dining',
      'availability',
//      'shuttle',
//      'parking',
      'events',
      'news',
//      'weather',
    ];
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;
  List<String> _cardOrder;
  Map<String, bool> _cardStates;
  List<String> _studentCards;
  Map<String, CardsModel> _availableCards;

  ///Services
  final CardsService _cardsService = CardsService();

  void updateAvailableCards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _cardsService.fetchCards()) {
      _availableCards = _cardsService.cardsModel;
      _lastUpdated = DateTime.now();
      if (_availableCards.isNotEmpty) {
        // remove all inactive or non-existent cards from [_cardOrder]
        var tempCardOrder = List.from(_cardOrder);
        for (String card in tempCardOrder) {
          // check to see if card no longer exists
          if (_availableCards[card] == null) {
            _cardOrder.remove(card);
          }
          // check to see if card is not active
          else if (!(_availableCards[card].cardActive ?? false)) {
            _cardOrder.remove(card);
          }
        }
        // remove all inactive or non-existent cards from [_cardStates]
        var tempCardStates = Map.from(_cardStates);
        for (String card in tempCardStates.keys) {
          // check to see if card no longer exists
          if (_availableCards[card] == null) {
            _cardStates.remove(card);
          }
          // check to see if card is not active
          else if (!(_availableCards[card].cardActive ?? false)) {
            _cardStates.remove(card);
          }
        }

        // add new cards to the top of the list
        for (String card in _availableCards.keys) {
          if (_studentCards.contains(card)) continue;
          if (!_cardOrder.contains(card) &&
              (_availableCards[card].cardActive ?? false)) {
            _cardOrder.insert(0, card);
          }
          // keep all new cards activated by default
          if (!_cardStates.containsKey(card)) {
            _cardStates[card] = true;
          }
        }
        updateCardOrder(_cardOrder);
//        updateCardStates(
//            _cardStates.keys.where((card) => _cardStates[card]).toList());
      }
    } else {
      ///TODO: determine what error to show to the user
      _error = _cardsService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Update the [_cardOrder] stored in state
  /// overwrite the [_cardOrder] in persistent storage with the model passed in
  Future updateCardOrder(List<String> newOrder) async {
    _cardOrder = newOrder;
    var box = await Hive.openBox('cardOrder');
    await box.put('cardOrder', _cardOrder);
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  /// Load [_cardOrder] from persistent storage
  /// Will create persistent storage if no data is found
  Future loadCardOrder() async {
    var box = await Hive.openBox('cardOrder');
    if (box.get('cardOrder') == null) {
      await box.put('cardOrder', _cardOrder);
    }
    _cardOrder = box.get('cardOrder');
    notifyListeners();
  }
//
//  /// Load [_cardStates] from persistent storage
//  /// Will create persistent storage if no data is found
//  Future loadCardStates() async {
//    var box = await Hive.openBox('cardStates');
//    // if no data was found then create the data and save it
//    // by default all cards will be on
//    if (box.get('cardStates') == null) {
//      await box.put('cardStates',
//          _cardStates.keys.where((card) => _cardStates[card]).toList());
//    } else {
//      _deactivateAllCards();
//    }
//    for (String activeCard in box.get('cardStates')) {
//      _cardStates[activeCard] = true;
//    }
//    notifyListeners();
//  }
//
//  /// Update the [_cardStates] stored in state
//  /// overwrite the [_cardStates] in persistent storage with the model passed in
//  Future updateCardStates(List<String> activeCards) async {
//    for (String activeCard in activeCards) {
//      _cardStates[activeCard] = true;
//    }
//    var box = await Hive.openBox('cardStates');
//    await box.put('cardStates', activeCards);
//    _lastUpdated = DateTime.now();
//    notifyListeners();
//  }
//
//  _deactivateAllCards() {
//    for (String card in _cardStates.keys) {
//      _cardStates[card] = false;
//    }
//    notifyListeners();
//  }

  activateStudentCards() {
    int index = _cardOrder.indexOf('MyStudentChart') + 1;
    _cardOrder.insertAll(index, _studentCards.toList());

    // TODO: test w/o this
    _cardOrder = List.from(_cardOrder.toSet().toList());
    for (String card in _studentCards) {
      _cardStates[card] = true;
    }
    updateCardOrder(_cardOrder);
//    updateCardStates(
//        _cardStates.keys.where((card) => _cardStates[card]).toList());
    notifyListeners();
  }

  deactivateStudentCards() {
    for (String card in _studentCards) {
      _cardOrder.remove(card);
      _cardStates[card] = false;
    }
    updateCardOrder(_cardOrder);
//    updateCardStates(
//        _cardStates.keys.where((card) => _cardStates[card]).toList());
    notifyListeners();
  }

  void reorderCards(List<String> order) {
    _cardOrder = order;
    notifyListeners();
  }

  void toggleCard(String card) {
    _cardStates[card] = !_cardStates[card];
//    updateCardStates(
//        _cardStates.keys.where((card) => _cardStates[card]).toList());
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;

  Map<String, bool> get cardStates => _cardStates;
  List<String> get cardOrder => _cardOrder;
}
