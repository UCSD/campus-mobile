import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/core/models/cards.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/cards.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CardsDataProvider extends ChangeNotifier {
  CardsDataProvider() {
    ///DEFAULT STATES
    _noInternet = false;
    _isLoading = false;
    _cardStates = {};
    _webCards = {};

    // Default card order for native cards
    _cardOrder = [
      'NativeScanner',
      'MyStudentChart',
      'MyUCSDChart',
      'finals',
      'schedule',
      'student_survey',
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
      'ventilation',
    ];

    // Native student cards
    _studentCards = [
      'finals',
      'schedule',
      'student_survey',
      'student_id',
    ];

    // Native staff cards
    _staffCards = [
      'MyUCSDChart',
      'staff_info',
      'employee_id',
      'ventilation',
    ];

    for (String card in CardTitleConstants.titleMap.keys.toList()) {
      _cardStates![card] = true;
    }

    /// temporary fix that prevents the student cards from causing issues on launch
    _cardOrder!.removeWhere((element) => _studentCards.contains(element));
    _cardStates!.removeWhere((key, value) => _studentCards.contains(key));

    _cardOrder!.removeWhere((element) => _staffCards.contains(element));
    _cardStates!.removeWhere((key, value) => _staffCards.contains(key));
  }

  ///STATES
  bool? _noInternet;
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;
  List<String>? _cardOrder;
  Map<String, bool>? _cardStates;
  Map<String, CardsModel?>? _webCards;
  late List<String> _studentCards;
  late List<String> _staffCards;
  Map<String, CardsModel>? _availableCards;
  late Box _cardOrderBox;
  late Box _cardStateBox;
  UserDataProvider? _userDataProvider;

  ///Services
  final CardsService _cardsService = CardsService();

  void updateAvailableCards(String? ucsdAffiliation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (await _cardsService.fetchCards(ucsdAffiliation)) {
      _availableCards = _cardsService.cardsModel;
      _lastUpdated = DateTime.now();
      if (_availableCards!.isNotEmpty) {
        // remove all inactive or non-existent cards from [_cardOrder]
        var tempCardOrder = List.from(_cardOrder!);
        for (String card in tempCardOrder) {
          // check to see if card no longer exists
          if (_availableCards![card] == null) {
            _cardOrder!.remove(card);
          }
          // check to see if card is not active
          else if (!(_availableCards![card]!.cardActive ?? false)) {
            _cardOrder!.remove(card);
          }
        }
        // remove all inactive or non-existent cards from [_cardStates]
        var tempCardStates = Map.from(_cardStates!);
        for (String card in tempCardStates.keys) {
          // check to see if card no longer exists
          if (_availableCards![card] == null) {
            _cardStates!.remove(card);
          }
          // check to see if card is not active
          else if (!(_availableCards![card]!.cardActive ?? false)) {
            _cardStates!.remove(card);
          }
        }

        // add active webCards
        for (String card in _cardStates!.keys) {
          if (_availableCards![card]!.isWebCard!) {
            _webCards![card] = _availableCards![card];
          }
        }
        // add new cards to the top of the list
        for (String card in _availableCards!.keys) {
          if (_studentCards.contains(card)) continue;
          if (_staffCards.contains(card)) continue;
          if (!_cardOrder!.contains(card) &&
              (_availableCards![card]!.cardActive ?? false)) {
            _cardOrder!.insert(0, card);
          }
          // keep all new cards activated by default
          if (!_cardStates!.containsKey(card)) {
            _cardStates![card] = true;
          }
        }
        updateCardOrder(_cardOrder);
        updateCardStates(
            _cardStates!.keys.where((card) => _cardStates![card]!).toList());
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

  Future loadSavedData() async {
    _cardStateBox = await Hive.openBox(DataPersistence.cardStates);
    _cardOrderBox = await Hive.openBox(DataPersistence.cardOrder);
    await _loadCardOrder();
    await _loadCardStates();
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
          _cardStates!.keys.where((card) => _cardStates![card]!).toList());
    } else {
      _deactivateAllCards();
    }
    for (String activeCard in _cardStateBox.get(DataPersistence.cardStates)) {
      _cardStates![activeCard] = true;
    }
    notifyListeners();
  }

  /// Returns the account type (visitor, staff, or student) as a string.
  String accountType() {
    // set bool vars to user values if they exist, else they will be set to false
    bool isStudent =
        _userDataProvider?.userProfileModel?.classifications?.student ?? false;
    bool isStaff =
        _userDataProvider?.userProfileModel?.classifications?.staff ?? false;
    String accountType;

    // check which type of account the user is currently
    if (isStudent) {
      accountType = 'student';
    } else if (isStaff) {
      accountType = 'staff';
    } else {
      accountType = 'visitor';
    }

    return accountType;
  }

  /// Checks if the account has cardOrder and cardStates. If not then it
  /// calls createDefault to create default ones.
  /// Returns true when both exist, false otherwise.
  /// NOTE: Function should only get called when the user is logged in.
  bool checkIfExist() {
    // define authenticated variables
    String account = accountType();
    List<String> accountCards =
        _userDataProvider!.userProfileModel!.classifications!.student!
            ? _studentCards
            : _staffCards;

    // check if a cardMapping exists for the account type
    if (_userDataProvider!.userProfileModel!.cardMappings![account] != null) {
      // cardMapping, cardOrder, and cardStates exist, so exit the function
      if (_userDataProvider!.userProfileModel!.cardMappings![account]
                  ['cardOrder'] !=
              null &&
          _userDataProvider!.userProfileModel!.cardMappings![account]
                  ['cardStates'] !=
              null) {
        return true;
      }
    }

    // create a cardMapping for the account
    else {
      _userDataProvider!.userProfileModel!.cardMappings![account] =
          new Map<String, dynamic>();
    }

    // create default cardOrder and cardStates
    _createDefault(account, accountCards);

    return false;
  }

  /// Creates default, authenticated _cardOrder and _cardStates.
  _createDefault(String account, List<String> accountCards) {
    // insert authenticated cards to the start of the list
    int index = _cardOrder!.indexOf('MyStudentChart') + 1;
    _cardOrder!.insertAll(index, accountCards);

    // TODO: test w/o this
    _cardOrder = List.from(_cardOrder!.toSet().toList());

    // set all card's state to true
    for (String card in accountCards) {
      _cardStates![card] = true;
    }

    updateCardOrder(_cardOrder);
    updateCardStates(
        _cardStates!.keys.where((card) => _cardStates![card]!).toList());
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
    _cardOrder = newOrder;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  /// Toggles [_cardStates] and updates [userDataProvider]
  void toggleCard(String card) async {
    String account = accountType();
    _cardStates![card] = !_cardStates![card]!;
    updateCardStates(
        _cardStates!.keys.where((card) => _cardStates![card]!).toList());
    _userDataProvider!.userProfileModel!.cardMappings![account]['cardStates'] =
        _cardStates;
    await _userDataProvider!
        .postUserProfile(_userDataProvider!.userProfileModel);
  }

  /// Update the [_cardStates] stored in state
  /// overwrite the [_cardStates] in persistent storage with the model passed in
  Future updateCardStates(List<String> activeCards) async {
    if (_userDataProvider == null || _userDataProvider!.isInSilentLogin) {
      return;
    }
    for (String activeCard in activeCards) {
      _cardStates![activeCard] = true;
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

  /// Call [updateCardOrder()] and updates [userDataProvider]
  updateProfileAndCardOrder(List<String>? newOrder) async {
    String account = accountType();
    await updateCardOrder(newOrder);
    _userDataProvider!.userProfileModel!.cardMappings![account]['cardOrder'] =
        newOrder;
    await _userDataProvider!
        .postUserProfile(_userDataProvider!.userProfileModel);
  }

  /// Update [_cardStates] to all false
  _deactivateAllCards() {
    for (String card in _cardStates!.keys) {
      _cardStates![card] = false;
    }
  }

  /// Updates [_cardOrder] and [_cardStates] to remove and turn off all
  /// student cards
  deactivateStudentCards() {
    // remove and turn off all authenticated cards
    for (String card in _studentCards) {
      _cardOrder!.remove(card);
      _cardStates![card] = false;
    }

    updateCardOrder(_cardOrder);
    updateCardStates(
        _cardStates!.keys.where((card) => _cardStates![card]!).toList());
  }

  /// Updates [_cardOrder] and [_cardStates] to remove and turn off all
  /// staff cards
  deactivateStaffCards() {
    // remove and turn off all authenticated cards
    for (String card in _staffCards) {
      _cardOrder!.remove(card);
      _cardStates![card] = false;
    }

    updateCardOrder(_cardOrder);
    updateCardStates(
        _cardStates!.keys.where((card) => _cardStates![card]!).toList());
  }

  /// Update [_cardOrder] to include authenticated cards
  activateAuthenticatedCards() {
    // define authenticated variables
    List<String> accountCards =
        _userDataProvider!.userProfileModel!.classifications!.student!
            ? _studentCards
            : _staffCards;

    // do nothing if an account card already exists in the list
    for (String card in accountCards) {
      if (_cardOrder!.contains(card)) return;
    }

    // account cards do not exist in the list, so add them in
    int index = _cardOrder!.indexOf('MyStudentChart') + 1;
    _cardOrder!.insertAll(index, accountCards.toList());

    // TODO: test w/o this
    _cardOrder = List.from(_cardOrder!.toSet().toList());
    updateCardOrder(_cardOrder);
    updateCardStates(
        _cardStates!.keys.where((card) => _cardStates![card]!).toList());
  }

  /// If user is logged in, fetch cardStates and cardOrder from user profile;
  /// however, if those do not exist, create and upload default order and states.
  showAllAuthenticatedCards() async {
    // grab account type
    String account = accountType();

    // leave function if the account is a visitor
    if (account == 'visitor') {
      return;
    }

    // created a default cardOrder and cardStates
    if (!checkIfExist()) {
      // give the user the default cardOrder and cardStates
      _userDataProvider!.userProfileModel!.cardMappings![account]['cardOrder'] =
          _cardOrder;
      _userDataProvider!.userProfileModel!.cardMappings![account]
          ['cardStates'] = _cardStates;

      // update user profile
      await _userDataProvider!
          .postUserProfile(_userDataProvider!.userProfileModel);
    }

    // load in cardOrder and cardStates from the user profile
    else {
      _cardOrder = _userDataProvider!
          .userProfileModel!.cardMappings![account]['cardOrder']
          .cast<String>();
      _cardStates = _userDataProvider!
          .userProfileModel!.cardMappings![account]['cardStates']
          .cast<String, bool>();
    }

    // update app preferences
    updateCardOrder(_cardOrder);
    updateCardStates(
        _cardStates!.keys.where((card) => _cardStates![card]!).toList());
  }

  /// SIMPLE SETTERS
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;

  /// SIMPLE GETTERS
  bool? get isLoading => _isLoading;
  bool? get noInternet => _noInternet;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  Map<String, bool>? get cardStates => _cardStates;
  List<String>? get cardOrder => _cardOrder;
  Map<String, CardsModel?>? get webCards => _webCards;
  Map<String, CardsModel>? get availableCards => _availableCards;
}
