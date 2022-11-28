import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/cards.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/cards.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:connectivity/connectivity.dart';

class CardsDataProvider extends ChangeNotifier {
  CardsDataProvider() {
    for (String card in CardTitleConstants.titleMap.keys.toList()) {
      _cardStates[card] = true;
    }

    /// temporary fix that prevents the student cards from causing issues on launch
    _cardOrder.removeWhere((element) => _studentCards.contains(element));
    _cardStates.removeWhere((key, value) => _studentCards.contains(key));

    _cardOrder.removeWhere((element) => _staffCards.contains(element));
    _cardStates.removeWhere((key, value) => _staffCards.contains(key));
  }

  ///STATES
  bool _noInternet = false;
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  List<String> _cardOrder = [
              'NativeScanner',
              'MyStudentChart',
              'MyUCSDChart',
              'finals',
              'schedule',
              'student_id',
              'employee_id',
              'availability',
              'dining',
              'events',
              'shuttle',
              'parking',
              'news',
              'weather',
              'speed_test',
              ];
  Map<String, bool> _cardStates = {};
  Map<String, CardsModel?> _webCards = {};
  List<String> _studentCards = [
    'finals',
    'schedule',
    'student_id',
  ];
  List<String> _staffCards = [
    'MyUCSDChart',
    'staff_info',
    'employee_id',
  ];
  Map<String, CardsModel>? _availableCards;
  late Box _cardOrderBox;
  late Box _cardStateBox;
  UserDataProvider? _userDataProvider;

  ///Services
  final CardsService _cardsService = CardsService();
  Connectivity _connectivity = Connectivity();

  void updateAvailableCards(String? ucsdAffiliation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _cardsService.fetchCards(ucsdAffiliation)) {
      _availableCards = _cardsService.cardsModel;
      _lastUpdated = DateTime.now();
      if (_availableCards!.isNotEmpty) {
        // remove all inactive or non-existent cards from [_cardOrder]
        var tempCardOrder = List.from(_cardOrder);
        for (String card in tempCardOrder) {
          // check to see if card no longer exists
          if (_availableCards![card] == null) {
            _cardOrder.remove(card);
          }
          // check to see if card is not active
          else if (!(_availableCards![card]!.cardActive ?? false)) {
            _cardOrder.remove(card);
          }
        }
        // remove all inactive or non-existent cards from [_cardStates]
        var tempCardStates = Map.from(_cardStates);
        for (String card in tempCardStates.keys) {
          // check to see if card no longer exists
          if (_availableCards![card] == null) {
            _cardStates.remove(card);
          }
          // check to see if card is not active
          else if (!(_availableCards![card]!.cardActive ?? false)) {
            _cardStates.remove(card);
          }
        }

        // add active webCards
        for (String card in _cardStates.keys) {
          if (_availableCards![card]!.isWebCard!) {
            _webCards[card] = _availableCards![card];
          }
        }
        // add new cards to the top of the list
        for (String card in _availableCards!.keys) {
          if (_studentCards.contains(card)) continue;
          if (_staffCards.contains(card)) continue;
          if (!_cardOrder.contains(card) &&
              (_availableCards![card]!.cardActive ?? false)) {
            _cardOrder.insert(0, card);
          }
          // keep all new cards activated by default
          if (!_cardStates.containsKey(card)) {
            _cardStates[card] = true;
          }
        }
        updateCardOrder(_cardOrder);
        updateCardStates(
            _cardStates.keys.where((card) => _cardStates[card]!).toList());
      }
    } else {
      _error = _cardsService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future changeInternetStatus(noInternet) async {
    _noInternet = noInternet;
  }

  Future<void> initConnectivity() async {
    try {
      var status = await _connectivity.checkConnectivity();
      if (status == ConnectivityResult.none) {
        _noInternet = true;
        notifyListeners();
      } else {
        _noInternet = false;
        notifyListeners();
      }
    } catch (e) {
      print("Encounter $e when monitoring Internet for cards");
    }
  }

  void monitorInternet() async {
    await initConnectivity();
    _connectivity.onConnectivityChanged.listen((result) async {
      if (result == ConnectivityResult.none) {
        _noInternet = true;
        notifyListeners();
      } else {
        _noInternet = false;
        notifyListeners();
      }
    });
  }

  Future loadSavedData() async {
    _cardStateBox = await Hive.openBox(DataPersistence.cardStates);
    _cardOrderBox = await Hive.openBox(DataPersistence.cardOrder);
    await _loadCardOrder();
    await _loadCardStates();
  }

  /// Update the [_cardOrder] stored in state
  /// overwrite the [_cardOrder] in persistent storage with the model passed in
  Future updateCardOrder(List<String>? newOrder) async {
    if (_userDataProvider == null || _userDataProvider!.isInSilentLogin) {
      return;
    }
    try {
      await _cardOrderBox.put(DataPersistence.cardOrder, newOrder);
    } catch (e) {
      _cardOrderBox = await Hive.openBox(DataPersistence.cardOrder);
      await _cardOrderBox.put(DataPersistence.cardOrder, newOrder);
    }
    _cardOrder = newOrder!;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  /// Load [_cardOrder] from persistent storage
  /// Will create persistent storage if no data is found
  Future _loadCardOrder() async {
    if (_userDataProvider == null || _userDataProvider!.isInSilentLogin) {
      return;
    }
    _cardOrderBox = await Hive.openBox(DataPersistence.cardOrder);
    if (_cardOrderBox.get(DataPersistence.cardOrder) == null) {
      await _cardOrderBox.put(DataPersistence.cardOrder, _cardOrder);
    }
    _cardOrder = _cardOrderBox.get(DataPersistence.cardOrder);
    notifyListeners();
  }

  /// Load [_cardStates] from persistent storage
  /// Will create persistent storage if no data is found
  Future _loadCardStates() async {
    _cardStateBox = await Hive.openBox(DataPersistence.cardStates);
    // if no data was found then create the data and save it
    // by default all cards will be on
    if (_cardStateBox.get(DataPersistence.cardStates) == null) {
      await _cardStateBox.put(DataPersistence.cardStates,
          _cardStates.keys.where((card) => _cardStates[card]!).toList());
    } else {
      _deactivateAllCards();
    }
    for (String activeCard in _cardStateBox.get(DataPersistence.cardStates)) {
      _cardStates[activeCard] = true;
    }
    notifyListeners();
  }

  /// Update the [_cardStates] stored in state
  /// overwrite the [_cardStates] in persistent storage with the model passed in
  Future updateCardStates(List<String> activeCards) async {
    if (_userDataProvider == null || _userDataProvider!.isInSilentLogin) {
      return;
    }
    for (String activeCard in activeCards) {
      _cardStates[activeCard] = true;
    }
    try {
      await _cardStateBox.put(DataPersistence.cardStates, activeCards);
    } catch (e) {
      _cardStateBox = await Hive.openBox(DataPersistence.cardStates);
      _cardStateBox.put(DataPersistence.cardStates, activeCards);
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

    updateCardOrder(_cardOrder);
    updateCardStates(
        _cardStates.keys.where((card) => _cardStates[card]!).toList());
  }

  showAllStudentCards() {
    int index = _cardOrder.indexOf('MyStudentChart') + 1;
    _cardOrder.insertAll(index, _studentCards.toList());

    // TODO: test w/o this
    _cardOrder = List.from(_cardOrder.toSet().toList());

    for (String card in _studentCards) {
      _cardStates[card] = true;
    }

    updateCardOrder(_cardOrder);
    updateCardStates(
        _cardStates.keys.where((card) => _cardStates[card]!).toList());
  }

  deactivateStudentCards() {
    for (String card in _studentCards) {
      _cardOrder.remove(card);
      _cardStates[card] = false;
    }
    updateCardOrder(_cardOrder);
    updateCardStates(
        _cardStates.keys.where((card) => _cardStates[card]!).toList());
  }

  activateStaffCards() {
    int index = _cardOrder.indexOf('MyStudentChart') + 1;
    _cardOrder.insertAll(index, _staffCards.toList());

    // TODO: test w/o this
    _cardOrder = List.from(_cardOrder.toSet().toList());
    updateCardOrder(_cardOrder);
    updateCardStates(
        _cardStates.keys.where((card) => _cardStates[card]!).toList());
  }

  showAllStaffCards() {
    int index = _cardOrder.indexOf('MyStudentChart') + 1;
    _cardOrder.insertAll(index, _staffCards.toList());

    // TODO: test w/o this
    _cardOrder = List.from(_cardOrder.toSet().toList());

    for (String card in _staffCards) {
      _cardStates[card] = true;
    }
    updateCardOrder(_cardOrder);
    updateCardStates(
        _cardStates.keys.where((card) => _cardStates[card]!).toList());
  }

  deactivateStaffCards() {
    for (String card in _staffCards) {
      _cardOrder.remove(card);
      _cardStates[card] = false;
    }
    updateCardOrder(_cardOrder);
    updateCardStates(
        _cardStates.keys.where((card) => _cardStates[card]!).toList());
  }

  void reorderCards(List<String> order) {
    _cardOrder = order;
    notifyListeners();
  }

  void toggleCard(String card) {
    _cardStates[card] = !_cardStates[card]!;
    updateCardStates(
        _cardStates.keys.where((card) => _cardStates[card]!).toList());
  }

  set userDataProvider(UserDataProvider value) => _userDataProvider = value;

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  bool get noInternet => _noInternet;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  Map<String, bool> get cardStates => _cardStates;
  List<String> get cardOrder => _cardOrder;
  Map<String, CardsModel?> get webCards => _webCards;
  Map<String, CardsModel>? get availableCards => _availableCards;
}
