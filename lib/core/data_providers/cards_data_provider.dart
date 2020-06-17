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
      'links': true,
      'news': true,
      'parking': true,
      'special_events': true,
      'weather': true,
      'dining': true,
      'MyStudentChart': true
    };
    _studentCards = ['finals', 'schedule'];
    _cardOrder = [
      'MyStudentChart',
      'dining',
      'events',
      'news',
//      'special_events',
//      'parking',
//      'availability',
//      'weather',
//      'links',
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
  Box _cardOrderBox;
  Box _cardStateBox;

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
        updateCardStates(
            _cardStates.keys.where((card) => _cardStates[card]).toList());
      }
    } else {
      ///TODO: determine what error to show to the user
      _error = _cardsService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future loadSavedData() async {
    await _loadCardOrder();
    await _loadCardStates();
  }

  /// Update the [_cardOrder] stored in state
  /// overwrite the [_cardOrder] in persistent storage with the model passed in
  Future updateCardOrder(List<String> newOrder) async {
    try {
      await _cardOrderBox.put('cardOrder', newOrder);
    } catch (e) {
      _cardOrderBox = await Hive.openBox('cardOrder');
      await _cardOrderBox.put('cardOrder', newOrder);
    }
    _cardOrder = newOrder;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  /// Load [_cardOrder] from persistent storage
  /// Will create persistent storage if no data is found
  Future _loadCardOrder() async {
    _cardOrderBox = await Hive.openBox('cardOrder');
    if (_cardOrderBox.get('cardOrder') == null) {
      await _cardOrderBox.put('cardOrder', _cardOrder);
    }
    _cardOrder = _cardOrderBox.get('cardOrder');
    notifyListeners();
  }

  /// Load [_cardStates] from persistent storage
  /// Will create persistent storage if no data is found
  Future _loadCardStates() async {
    _cardStateBox = await Hive.openBox('cardStates');
    // if no data was found then create the data and save it
    // by default all cards will be on
    if (_cardStateBox.get('cardStates') == null) {
      print(cardStates.keys.where((card) => _cardStates[card]).toList());
      await _cardStateBox.put('cardStates',
          _cardStates.keys.where((card) => _cardStates[card]).toList());
    } else {
      _deactivateAllCards();
    }
    for (String activeCard in _cardStateBox.get('cardStates')) {
      _cardStates[activeCard] = true;
    }
    notifyListeners();
  }

  /// Update the [_cardStates] stored in state
  /// overwrite the [_cardStates] in persistent storage with the model passed in
  Future updateCardStates(List<String> activeCards) async {
    for (String activeCard in activeCards) {
      _cardStates[activeCard] = true;
    }
    try {
      _cardStateBox.put('cardStates', activeCards);
    } catch (e) {
      _cardStateBox = await Hive.openBox('cardStates');
      _cardStateBox.put('cardStates', activeCards);
    }
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  _deactivateAllCards() {
    for (String card in _cardStates.keys) {
      _cardStates[card] = false;
    }
  }

  activateStudentCards() {
    int index = _cardOrder.indexOf('MyStudentChart') + 1;
    _cardOrder.insertAll(index, _studentCards.toList());

    // TODO: test w/o this
    _cardOrder = List.from(_cardOrder.toSet().toList());
    for (String card in _studentCards) {
      _cardStates[card] = true;
    }
    updateCardOrder(_cardOrder);
    updateCardStates(
        _cardStates.keys.where((card) => _cardStates[card]).toList());
  }

  deactivateStudentCards() {
    for (String card in _studentCards) {
      _cardOrder.remove(card);
      _cardStates[card] = false;
    }
    updateCardOrder(_cardOrder);
    updateCardStates(
        _cardStates.keys.where((card) => _cardStates[card]).toList());
  }

  void reorderCards(List<String> order) {
    _cardOrder = order;
    notifyListeners();
  }

  void toggleCard(String card) {
    _cardStates[card] = !_cardStates[card];
    updateCardStates(
        _cardStates.keys.where((card) => _cardStates[card]).toList());
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;

  Map<String, bool> get cardStates => _cardStates;
  List<String> get cardOrder => _cardOrder;
}
