import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/services/barcode_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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

  ///SERVICES

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

  /// Load [_cardStates] from persistent storage
  /// Will create persistent storage if no data is found
  Future loadCardStates() async {
    var box = await Hive.openBox('cardStates');
    // if no data was found then create the data and save it
    // by default all cards will be on
    if (box.get('cardStates') == null) {
      await box.put('cardStates',
          _cardStates.keys.where((card) => _cardStates[card]).toList());
    } else {
      _deactivateAllCards();
    }
    for (String activeCard in box.get('cardStates')) {
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
    var box = await Hive.openBox('cardStates');
    await box.put('cardStates', activeCards);
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  _deactivateAllCards() {
    for (String card in _cardStates.keys) {
      _cardStates[card] = false;
    }
    notifyListeners();
  }

  activateStudentCards() {
    int index = _cardOrder.indexOf('MyStudentChart') + 1;
    _cardOrder.insertAll(index, _studentCards.toList());
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
