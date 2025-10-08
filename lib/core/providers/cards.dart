import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/cards.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/cards.dart';
import 'package:campus_mobile_experimental/ui/home/home.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CardsDataProvider extends ChangeNotifier {
  CardsDataProvider() {
    CardTitleConstants.titleMap.keys
        .forEach((card) => _cardStates[card] = true);

    /// temporary fix that prevents the student cards from causing issues on launch
    _cardOrder.removeWhere((element) => _studentCards.contains(element));
    _cardStates.removeWhere((key, value) => _studentCards.contains(key));
    _cardOrder.removeWhere((element) => _staffCards.contains(element));
    _cardStates.removeWhere((key, value) => _staffCards.contains(key));
  }

  /// STATES
  bool _noInternet = false;
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  Map<String, bool> _cardStates = {};
  Map<String, bool> _userToggledCards = {}; // Track what the user has manually toggled
  List<String> _userOrderedCards = []; // Also track user's custom card order
  bool _hasUserCustomOrder = false; // Flag to check if the user has reordered the cards
  late Box _cardOrderBox;
  late Box _cardStateBox;
  late Box _userToggledBox;
  late Box _userOrderBox;

  /// MODELS
  late Map<String, CardsModel> _availableCards;

  /// PROVIDERS
  Map<String, CardsModel> _webCards = {};
  UserDataProvider? _userDataProvider;

  /// SERVICES
  final _cardsService = CardsService();
  final _connectivity = Connectivity();

  // Default card order for native cards
  // Most of the time immediately overwritten by default card order coming from server
  List<String> _cardOrder = [
    'student_id',
    'employee_id',
    'MyStudentChart',
    'MyUCSDChart',
    'finals',
    'schedule',
    'availability',
    'dining',
    'events',
    'shuttle',
    'parking',
    'news',
    'speed_test',
  ];

  // Native student cards
  static const List<String> _studentCards = [
    'finals',
    'schedule',
    'student_id',
  ];

  // Native staff cards
  static const List<String> _staffCards = [
    'MyUCSDChart',
    'staff_info',
    'employee_id',
  ];

  void updateAvailableCards(String? ucsdAffiliation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (await _cardsService.fetchCards(ucsdAffiliation)) {
      _availableCards = _cardsService.cardsModel;
      _lastUpdated = DateTime.now();

      if (_availableCards.isNotEmpty) {
        // If the user doesn't have a custom order, use the app order
        if (!_hasUserCustomOrder) {
          // print("DEBUG: No custom order, rebuilding default order");
          _cardOrder.clear();

          // add new cards to the top of the list
          _availableCards.forEach((card, model) {
            if (_studentCards.contains(model) || _staffCards.contains(model)) return;
            // add active web cards
            if (model.isWebCard) _webCards[card] = model;
            // Add new cards to user's order if they're not already there
            if (!_cardOrder.contains(model) && model.cardActive) _cardOrder.add(card);
            // keep all new cards activated by default
            _cardStates.putIfAbsent(card, () => true);
          });
        } else {
          // User has custom order - just add any new web cards and ensure they're in available cards
          // print("DEBUG: User has custom order, preserving: $_cardOrder");
          _availableCards.forEach((card, model) {
            // add active web cards
            if (model.isWebCard) _webCards[card] = model;
            // Add new cards to user's order if they're not already there
            if (!_cardOrder.contains(card) && model.cardActive && 
                !_studentCards.contains(card) && !_staffCards.contains(card)) {
              _cardOrder.add(card);
            }
            // keep all new cards activated by default
            _cardStates.putIfAbsent(card, () => true);
          });
        }

        updateCardOrder(isUserReorder: false); // System update, not user reorder
        updateCardStates();
      }
    } else {
      _error = _cardsService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future changeInternetStatus(bool noInternet) async {
    _noInternet = noInternet;
  }

  Future<void> initConnectivity() async {
    try {
      var status = await _connectivity.checkConnectivity();
      _noInternet = (status == ConnectivityResult.none);
      notifyListeners();
    } catch (e) {
      print("Encounter $e when monitoring Internet for cards");
    }
  }

  void monitorInternet() async {
    await initConnectivity();
    _connectivity.onConnectivityChanged.listen((result) async {
      _noInternet = (result == ConnectivityResult.none);
      notifyListeners();
    });
  }

  /// Load saved data from disk or create new persistent storage if none exists
  Future<void> loadSavedData() async {
    await Future.wait([
      _loadCardOrder(),
      _loadCardStates(),
      _loadUserToggledCards(),
      _loadUserOrderedCards()
    ]);
  }

  /// Update the [_cardOrder] stored in state
  /// overwrite the [_cardOrder] in persistent storage with the model passed in
  Future updateCardOrder({bool isUserReorder = false}) async {
    if (_userDataProvider == null || _userDataProvider!.isInSilentLogin) return;

    // If this is a user-initiated reorder, save it as user preference
    if (isUserReorder) {
      _hasUserCustomOrder = true;
      _userOrderedCards = List<String>.from(_cardOrder);
      // print("DEBUG: Saving user custom order: $_userOrderedCards");
      _updateUserOrderedCards(); // Save user's custom order
    }

    // Check if box is already open, if not then open it
    if (!Hive.isBoxOpen(DataPersistence.cardOrder)) {
      _cardOrderBox = await Hive.openBox(DataPersistence.cardOrder);
    } else {
      _cardOrderBox = Hive.box(DataPersistence.cardOrder);
    }

    // no need to await - data is saved to disk in background
    _cardOrderBox.put(DataPersistence.cardOrder, _cardOrder);

    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  /// Load [_cardOrder] from persistent storage
  /// Will create persistent storage if no data is found
  Future _loadCardOrder() async {
    if (_userDataProvider == null || _userDataProvider!.isInSilentLogin) return;

    // Check if box is already open, if not then open it
    if (!Hive.isBoxOpen(DataPersistence.cardOrder)) {
      _cardOrderBox = await Hive.openBox(DataPersistence.cardOrder);
    } else {
      _cardOrderBox = Hive.box(DataPersistence.cardOrder);
    }

    if (_cardOrderBox.get(DataPersistence.cardOrder) == null)
      await _cardOrderBox.put(DataPersistence.cardOrder, _cardOrder);
    else
      _cardOrder = _cardOrderBox.get(DataPersistence.cardOrder);

    notifyListeners();
  }

  /// Load [_cardStates] from persistent storage
  /// Will create persistent storage if no data is found
  Future _loadCardStates() async {
    // Check if box is already open, if not then open it
    if (!Hive.isBoxOpen(DataPersistence.cardStates)) {
      _cardStateBox = await Hive.openBox(DataPersistence.cardStates);
    } else {
      _cardStateBox = Hive.box(DataPersistence.cardStates);
    }

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

  /// Load [_userToggledCards] from persistent storage
  /// Will create persistent storage if no data is found
  Future _loadUserToggledCards() async {
    // Check if box is already open, if not then open it
    if (!Hive.isBoxOpen('userToggledCards')) {
      _userToggledBox = await Hive.openBox('userToggledCards');
    } else {
      _userToggledBox = Hive.box('userToggledCards');
    }

    // Load the toggled cards map from disk
    Map<dynamic, dynamic>? savedToggles = _userToggledBox.get('userToggledCards');
    if (savedToggles != null) _userToggledCards = Map<String, bool>.from(savedToggles);
    notifyListeners();
  }

  /// Update the [_userToggledCards] stored on disk
  Future _updateUserToggledCards() async {
    // Check if box is already open, if not then open it
    if (!Hive.isBoxOpen('userToggledCards')) {
      _userToggledBox = await Hive.openBox('userToggledCards');
    } else {
      _userToggledBox = Hive.box('userToggledCards');
    }

    // Save the toggled cards map to storage
    _userToggledBox.put('userToggledCards', _userToggledCards);
  }

  /// Load [_userOrderedCards] from persistent storage
  /// Will create persistent storage if no data is found
  Future _loadUserOrderedCards() async {
    // Check if box is already open, if not then open it
    if (!Hive.isBoxOpen('userOrderedCards')) {
      _userOrderBox = await Hive.openBox('userOrderedCards');
    } else {
      _userOrderBox = Hive.box('userOrderedCards');
    }

    // Load the user's custom order from storage
    List<dynamic>? savedOrder = _userOrderBox.get('userOrderedCards');
    bool? hasCustomOrder = _userOrderBox.get('hasUserCustomOrder');
    
    if (savedOrder != null && hasCustomOrder == true) {
      _userOrderedCards = List<String>.from(savedOrder);
      _hasUserCustomOrder = true;
      // Use user's custom order instead of default order
      _cardOrder = List<String>.from(_userOrderedCards);
      // print("DEBUG: Loaded user custom order: $_userOrderedCards");
    } else {
      _hasUserCustomOrder = false;
      // print("DEBUG: No user custom order found, using default");
    }

    notifyListeners();
  }

  /// Update the [_userOrderedCards] stored on disk
  Future _updateUserOrderedCards() async {
    // Check if box is already open, if not then open it
    if (!Hive.isBoxOpen('userOrderedCards')) {
      _userOrderBox = await Hive.openBox('userOrderedCards');
    } else {
      _userOrderBox = Hive.box('userOrderedCards');
    }

    // Save the user's custom order to storage
    _userOrderBox.put('userOrderedCards', _userOrderedCards);
    _userOrderBox.put('hasUserCustomOrder', _hasUserCustomOrder);
  }

  /// Update the [_cardStates] stored on disk
  Future updateCardStates() async {
    if (_userDataProvider == null || _userDataProvider!.isInSilentLogin) return;

    var activeCards =
        _cardStates.keys.where((card) => _cardStates[card]!).toList();

    // Check if box is already open, if not then open it
    if (!Hive.isBoxOpen(DataPersistence.cardStates)) {
      _cardStateBox = await Hive.openBox(DataPersistence.cardStates);
    } else {
      _cardStateBox = Hive.box(DataPersistence.cardStates);
    }

    // no need to await - data is saved to disk in background
    _cardStateBox.put(DataPersistence.cardStates, activeCards);

    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  void _deactivateAllCards() {
    for (String card in _cardStates.keys) {
      _cardStates[card] = false;
    }
  }

  void activateStudentCards() {
    var index = _cardOrder.indexOf('MyStudentChart') + 1;
    _cardOrder.insertAll(index, _studentCards.toList());

    // TODO: test w/o this
    _cardOrder = List.from(_cardOrder.toSet().toList());

    updateCardOrder();
    updateCardStates();
  }

  void activateStudentCardsForManualLogin() {
    var index = _cardOrder.indexOf('MyStudentChart') + 1;
    _cardOrder.insertAll(index, _studentCards.toList());

    // TODO: test w/o this
    _cardOrder = List.from(_cardOrder.toSet().toList());

    // These lines ONLY execute during manual login, not silent login
    _cardStates['student_id'] = true;
    _cardStates['finals'] = true;
    _cardStates['schedule'] = true;

    updateCardOrder();
    updateCardStates();
  }

  void showAllStudentCards() {
    var index = _cardOrder.indexOf('MyStudentChart') + 1;
    _cardOrder.insertAll(index, _studentCards.toList());

    // TODO: test w/o this
    _cardOrder = List.from(_cardOrder.toSet().toList());

    for (String card in _studentCards) {
      _cardStates[card] = true;
    }

    updateCardOrder();
    updateCardStates();
  }

  void activateStudentCardsForSilentLogin() {
    // Only modify order if user hasn't created a custom order
    if (!_hasUserCustomOrder) {
      var index = _cardOrder.indexOf('MyStudentChart') + 1;
      _cardOrder.insertAll(index, _studentCards.toList());

      // TODO: test w/o this
      _cardOrder = List.from(_cardOrder.toSet().toList());
    } else {
      // User has custom order - just ensure student cards are in the list if missing
      for (String card in _studentCards) {
        if (!_cardOrder.contains(card)) {
          // Add missing cards at the end, but don't reorder existing ones
          _cardOrder.add(card);
        }
      }
    }

    // Only show these cards if user hasn't explicitly toggled them off
    for (String card in _studentCards) {
      // If user has never toggled this card, default to true
      // If user has toggled it, respect their last choice
      if (!_userToggledCards.containsKey(card)) _cardStates[card] = true; // Default to visible for new users
      // If user has toggled it before, keep their preference (don't override)
    }

    updateCardOrder(); // Don't pass isUserReorder=true since this is system activation
    updateCardStates();
  }

  void deactivateStudentCards() {
    for (String card in _studentCards) {
      _cardOrder.remove(card);
      _cardStates[card] = false;
    }
    updateCardOrder();
    updateCardStates();
  }

  void activateStaffCards() {
    var index = _cardOrder.indexOf('MyStudentChart') + 1;
    _cardOrder.insertAll(index, _staffCards.toList());

    // TODO: test w/o this
    _cardOrder = List.from(_cardOrder.toSet().toList());
    updateCardOrder();
    updateCardStates();
  }

  void activateStaffCardsForSilentLogin() {
    // Only modify order if user hasn't created a custom order
    if (!_hasUserCustomOrder) {
      var index = _cardOrder.indexOf('MyStudentChart') + 1;
      _cardOrder.insertAll(index, _staffCards.toList());

      // TODO: test w/o this
      _cardOrder = List.from(_cardOrder.toSet().toList());
    } else {
      // User has custom order - just ensure staff cards are in the list if missing
      for (String card in _staffCards) {
        // Add missing cards at the end, but don't reorder existing ones
        if (!_cardOrder.contains(card)) _cardOrder.add(card);
      }
    }

    // Only show these cards if user hasn't explicitly toggled them off
    for (String card in _staffCards) {
      // If user has never toggled this card, default to true
      // If user has toggled it, respect their last choice
      if (!_userToggledCards.containsKey(card)) _cardStates[card] = true; // Default to visible for new users
      // If user has toggled it before, keep their preference (don't override)
    }

    updateCardOrder(); // Don't pass isUserReorder=true since this is system activation
    updateCardStates();
  }

  void showAllStaffCards() {
    var index = _cardOrder.indexOf('MyStudentChart') + 1;
    _cardOrder.insertAll(index, _staffCards.toList());

    // TODO: test w/o this
    _cardOrder = List.from(_cardOrder.toSet().toList());

    for (String card in _staffCards) {
      _cardStates[card] = true;
    }
    updateCardOrder();
    updateCardStates();
  }

  void deactivateStaffCards() {
    for (String card in _staffCards) {
      _cardOrder.remove(card);
      _cardStates[card] = false;
    }
    updateCardOrder();
    updateCardStates();
  }

  void toggleCard(String card) {
    try {
      if (_availableCards[card]!.isWebCard && _cardStates[card]!) resetCardHeight(card);

      // Toggle the card state
      _cardStates[card] = !_cardStates[card]!;

      // Mark this card as explicitly toggled by user
      _userToggledCards[card] = true;
      _updateUserToggledCards(); // Save to storage

      // Update states in persistent storage
      updateCardStates();

      // Force an additional notification to ensure UI is updated
      Future.microtask(() => notifyListeners());
    } catch (e) {
      print("Error toggling card state for $card: $e");
      // Revert the state change if it fails
      _cardStates[card] = !_cardStates[card]!;
      notifyListeners();
    }
  }

  /// SIMPLE SETTERS
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;

  /// SIMPLE GETTERS
  get isLoading => _isLoading;
  get noInternet => _noInternet;
  get error => _error;
  get lastUpdated => _lastUpdated;
  List<String> get cardOrder => _cardOrder;
  Map<String, bool> get cardStates => _cardStates;
  Map<String, CardsModel?> get webCards => _webCards;
  Map<String, CardsModel> get availableCards => _availableCards;
  bool get hasUserCustomOrder => _hasUserCustomOrder;
}
