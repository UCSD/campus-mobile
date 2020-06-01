import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/services/barcode_service.dart';
import 'package:flutter/material.dart';
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

  activateStudentCards() {
    int index = _cardOrder.indexOf('MyStudentChart') + 1;
    _cardOrder.insertAll(index, _studentCards.toList());
    for (String card in _studentCards) {
      _cardStates[card] = true;
    }
    notifyListeners();
  }

  deactivateStudentCards() {
    for (String card in _studentCards) {
      _cardOrder.remove(card);
      _cardStates[card] = false;
    }
    notifyListeners();
  }

  void reorderCards(List<String> order) {
    _cardOrder = order;
    notifyListeners();
  }

  void toggleCard(String card) {
    _cardStates[card] = !_cardStates[card];
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;

  Map<String, bool> get cardStates => _cardStates;
  List<String> get cardOrder => _cardOrder;
}
