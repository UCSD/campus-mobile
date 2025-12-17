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
    CardTitleConstants.TITLE_MAP.keys.forEach((card) => _cardStates[card] = true);

    /// temporary fix that prevents the student cards from causing issues on launch
    _cardOrder.removeWhere((element) => _STUDENT_CARDS.contains(element));
    _cardStates.removeWhere((key, value) => _STUDENT_CARDS.contains(key));
    _cardOrder.removeWhere((element) => _STAFF_CARDS.contains(element));
    _cardStates.removeWhere((key, value) => _STAFF_CARDS.contains(key));
  }

  /// STATES
  bool _noInternet = false;
  bool _isLoading = false;
  bool _hasUserCustomOrder = false; // Check if the user has reordered the cards
  DateTime? _lastUpdated;
  String? _error;
  List<String> _userOrderedCards = []; // Tracks user's custom card order
  Map<String, bool> _userToggledCards = {}; // Tracks user custom toggles
  Map<String, bool> _cardStates = {};
  late Box _userToggledBox; // Box to store user custom toggled card states
  late Box _userOrderBox; // Box to store user custom card order
  late Box _cardOrderBox;
  late Box _cardStateBox;

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
    'my_student_chart',
    'my_ucsd_chart',
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
  static const List<String> _STUDENT_CARDS = [
    'finals',
    'schedule',
    'student_id',
  ];

  // Native staff cards
  static const List<String> _STAFF_CARDS = [
    'my_ucsd_chart',
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
        // Only if the user doesn't have a custom order, use the default
        if (!_hasUserCustomOrder) {
          // print("DEBUG: No custom order, rebuilding default order");
          _cardOrder.clear();

          // add new cards to the top of the list
          _availableCards.forEach((card, model) {
            final bool isStudentCard = _STUDENT_CARDS.contains(model);
            final bool isStaffCard = _STAFF_CARDS.contains(model);
            if (isStudentCard || isStaffCard) return;

            // add active web cards
            if (model.isWebCard) _webCards[card] = model;

            // Add new cards to user's order if they're not already there
            final bool isNewCard = !_cardOrder.contains(model);
            final bool isActiveCard = model.cardActive;
            if (isNewCard && isActiveCard) _cardOrder.add(card);

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
            final bool notInCurrOrder = !_cardOrder.contains(card);
            final bool isActiveCard = model.cardActive;
            final bool isNotStudentCard = !_STUDENT_CARDS.contains(card);
            final bool isNotStaffCard = !_STAFF_CARDS.contains(card);
            final bool shouldAddCard = notInCurrOrder && isActiveCard && isNotStudentCard && isNotStaffCard;

            if (shouldAddCard) _cardOrder.add(card);
            // keep all new cards activated by default
            _cardStates.putIfAbsent(card, () => true);
          });
        }
      }

      updateCardOrder(); // default order isUserReorder: false
      updateCardStates();
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
    await Future.wait([_loadCardOrder(), _loadCardStates(), _loadUserToggledCards(), _loadUserOrderedCards()]);
  }

  /// Update the [_cardOrder] stored in state
  /// overwrite the [_cardOrder] in persistent storage with the model passed in
  Future updateCardOrder({bool isUserReorder = false}) async {
    final bool isUserProviderNull = _userDataProvider == null;
    final bool isInSilentLogin = _userDataProvider?.isInSilentLogin ?? false;
    if (isUserProviderNull || isInSilentLogin) return;

    // If this is a user-initiated reorder, save it as user preference
    if (isUserReorder) {
      _hasUserCustomOrder = true;
      _userOrderedCards = List<String>.from(_cardOrder);
      // print("DEBUG: Saving user custom order: $_userOrderedCards");
      _updateUserOrderedCards(); // Save user's custom order
    }

    // Check if box is already open, if not then open it
    if (!Hive.isBoxOpen(DataPersistence.CARD_ORDER)) {
      _cardOrderBox = await Hive.openBox(DataPersistence.CARD_ORDER);
    } else {
      _cardOrderBox = Hive.box(DataPersistence.CARD_ORDER);
    }

    // no need to await - data is saved to disk in background
    _cardOrderBox.put(DataPersistence.CARD_ORDER, _cardOrder);

    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  /// Load [_cardOrder] from persistent storage
  /// Will create persistent storage if no data is found
  Future _loadCardOrder() async {
    final bool isUserProviderNull = _userDataProvider == null;
    final bool isInSilentLogin = _userDataProvider?.isInSilentLogin ?? false;
    if (isUserProviderNull || isInSilentLogin) return;

    // Check if box is already open, if not then open it
    if (!Hive.isBoxOpen(DataPersistence.CARD_ORDER)) {
      _cardOrderBox = await Hive.openBox(DataPersistence.CARD_ORDER);
    } else {
      _cardOrderBox = Hive.box(DataPersistence.CARD_ORDER);
    }

    if (_cardOrderBox.get(DataPersistence.CARD_ORDER) == null)
      await _cardOrderBox.put(DataPersistence.CARD_ORDER, _cardOrder);
    else
      _cardOrder = _cardOrderBox.get(DataPersistence.CARD_ORDER);

    notifyListeners();
  }

  /// Load [_cardStates] from persistent storage
  /// Will create persistent storage if no data is found
  Future _loadCardStates() async {
    // Check if box is already open, if not then open it
    if (!Hive.isBoxOpen(DataPersistence.CARD_STATES)) {
      _cardStateBox = await Hive.openBox(DataPersistence.CARD_STATES);
    } else {
      _cardStateBox = Hive.box(DataPersistence.CARD_STATES);
    }

    // if no data was found then create the data and save it
    // by default all cards will be on
    if (_cardStateBox.get(DataPersistence.CARD_STATES) == null) {
      await _cardStateBox.put(
          DataPersistence.CARD_STATES, _cardStates.keys.where((card) => _cardStates[card]!).toList());
    } else {
      _deactivateAllCards();
    }
    for (String activeCard in _cardStateBox.get(DataPersistence.CARD_STATES)) {
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
    final bool isUserProviderNull = _userDataProvider == null;
    final bool isInSilentLogin = _userDataProvider?.isInSilentLogin ?? false;
    if (isUserProviderNull || isInSilentLogin) return;

    var activeCards = _cardStates.keys.where((card) => _cardStates[card]!).toList();

    // checks if box is open, creates one if not
    if (!Hive.isBoxOpen(DataPersistence.CARD_STATES)) {
      _cardStateBox = await Hive.openBox(DataPersistence.CARD_STATES);
    } else {
      _cardStateBox = Hive.box(DataPersistence.CARD_STATES);
    }

    // no need to await - data is saved to disk in background
    _cardStateBox.put(DataPersistence.CARD_STATES, activeCards);

    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  void _deactivateAllCards() {
    for (String card in _cardStates.keys) {
      _cardStates[card] = false;
    }
  }

  void activateStudentCards() {
    var index = _cardOrder.indexOf('my_student_chart') + 1;
    _cardOrder.insertAll(index, _STUDENT_CARDS.toList());

    // TODO: test w/o this - December 2025
    _cardOrder = List.from(_cardOrder.toSet().toList());

    updateCardOrder();
    updateCardStates();
  }

  void activateStudentCardsForManualLogin() {
    var index = _cardOrder.indexOf('my_student_chart') + 1;
    _cardOrder.insertAll(index, _STUDENT_CARDS.toList());

    // TODO: test w/o this - December 2025
    _cardOrder = List.from(_cardOrder.toSet().toList());

    // These lines ONLY execute during manual login, not silent login
    // this is the fix that prevents students from NOT seeing their authenticated cards after first login
    _cardStates['student_id'] = true;
    _cardStates['finals'] = true;
    _cardStates['schedule'] = true;

    updateCardOrder();
    updateCardStates();
  }

  void activateStudentCardsForSilentLogin() {
    // Only modify order if user hasn't created a custom order
    if (!_hasUserCustomOrder) {
      var index = _cardOrder.indexOf('MyStudentChart') + 1;
      _cardOrder.insertAll(index, _STUDENT_CARDS.toList());

      // TODO: test w/o this - December 2025
      _cardOrder = List.from(_cardOrder.toSet().toList());
    } else {
      // User has custom order - just ensure student cards are in the list if missing
      for (String card in _STUDENT_CARDS) {
        if (!_cardOrder.contains(card)) {
          // Add missing cards at the end, but don't reorder existing ones
          _cardOrder.add(card);
        }
      }
    }

    // Only show these cards if user hasn't explicitly toggled them off
    for (String card in _STUDENT_CARDS) {
      // If user has never toggled this card, default to true
      if (!_userToggledCards.containsKey(card)) {
        _cardStates[card] = true; // Default to visible for new users
        // print("DEBUG: activateStudentCardsForSilentLogin() - $card set to default true (new user)");
      } else {
        // User has explicitly set this card's state - restore their preference
        _cardStates[card] = _userToggledCards[card]!;
        // print("DEBUG: activateStudentCardsForSilentLogin() - $card restored to user preference: ${_userToggledCards[card]}");
      }
    }

    updateCardOrder(); // Don't pass isUserReorder=true since this is default activation
    updateCardStates();
  }

  void showAllStudentCards() {
    var index = _cardOrder.indexOf('my_student_chart') + 1;
    _cardOrder.insertAll(index, _STUDENT_CARDS.toList());

    // TODO: test w/o this - December 2025
    _cardOrder = List.from(_cardOrder.toSet().toList());

    for (String card in _STUDENT_CARDS) {
      _cardStates[card] = true;
    }

    updateCardOrder();
    updateCardStates();
  }

  void deactivateStudentCards() {
    for (String card in _STUDENT_CARDS) {
      _cardOrder.remove(card);
      _cardStates[card] = false;
    }
    updateCardOrder();
    updateCardStates();
  }

  void activateStaffCards() {
    var index = _cardOrder.indexOf('my_student_chart') + 1;
    _cardOrder.insertAll(index, _STAFF_CARDS.toList());

    // TODO: test w/o this - December 2025
    _cardOrder = List.from(_cardOrder.toSet().toList());
    updateCardOrder();
    updateCardStates();
  }

  void activateStaffCardsForSilentLogin() {
    // Only modify order if user hasn't created a custom order
    if (!_hasUserCustomOrder) {
      var index = _cardOrder.indexOf('MyStudentChart') + 1;
      _cardOrder.insertAll(index, _STAFF_CARDS.toList());

      // TODO: test w/o this - December 2025
      _cardOrder = List.from(_cardOrder.toSet().toList());
    } else {
      // User has custom order - just ensure staff cards are in the list if missing
      for (String card in _STAFF_CARDS) {
        // Add missing cards at the end, but don't reorder existing ones
        if (!_cardOrder.contains(card)) _cardOrder.add(card);
      }
    }

    // Only show these cards if user hasn't explicitly toggled them off
    for (String card in _STAFF_CARDS) {
      // If user has never toggled this card, default to true
      if (!_userToggledCards.containsKey(card)) {
        _cardStates[card] = true; // Default to visible for new users
        print("DEBUG: activateStaffCardsForSilentLogin() - $card set to default true (new user)");
      } else {
        // User has explicitly set this card's state - restore their preference
        _cardStates[card] = _userToggledCards[card]!;
        print(
            "DEBUG: activateStaffCardsForSilentLogin() - $card restored to user preference: ${_userToggledCards[card]}");
      }
    }

    updateCardOrder(); // Don't pass isUserReorder=true since this is system activation
    updateCardStates();
  }

  void showAllStaffCards() {
    var index = _cardOrder.indexOf('my_student_chart') + 1;
    _cardOrder.insertAll(index, _STAFF_CARDS.toList());

    // TODO: test w/o this - December 2025
    _cardOrder = List.from(_cardOrder.toSet().toList());

    for (String card in _STAFF_CARDS) {
      _cardStates[card] = true;
    }
    updateCardOrder();
    updateCardStates();
  }

  void deactivateStaffCards() {
    for (String card in _STAFF_CARDS) {
      _cardOrder.remove(card);
      _cardStates[card] = false;
    }
    updateCardOrder();
    updateCardStates();
  }

  void toggleCard(String card) {
    try {
      final bool isWebCard = _availableCards[card]!.isWebCard;
      final bool isCardActive = _cardStates[card]!;
      if (isWebCard && isCardActive) resetCardHeight(card);

      // Toggle the card state
      _cardStates[card] = !_cardStates[card]!;
      // print("DEBUG: toggleCard() - $card toggled to ${_cardStates[card]}");

      // Store the actual state the user set
      _userToggledCards[card] = _cardStates[card]!;
      _updateUserToggledCards();
      // print("DEBUG: toggleCard() - Saved user preference for $card: ${_userToggledCards[card]}");

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
  get hasUserCustomOrder => _hasUserCustomOrder;
  get error => _error;
  get lastUpdated => _lastUpdated;
  List<String> get cardOrder => _cardOrder;
  Map<String, bool> get cardStates => _cardStates;
  Map<String, CardsModel?> get webCards => _webCards;
  Map<String, CardsModel> get availableCards => _availableCards;
}
