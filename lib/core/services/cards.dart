import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/cards.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CardsService {
  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  final Map<String, String> headers = {"accept": "application/json"};

  /// MODELS
  late Map<String, CardsModel> _cardsModel;

  Future<bool> fetchCards(String? ucsdAffiliation) async {
    _error = null;
    _isLoading = true;
    if (ucsdAffiliation == null) ucsdAffiliation = "";

    /// API Manager Service
    try {
      String cardListEndpoint = dotenv.get('CARD_LIST_ENDPOINT') + ucsdAffiliation;
      String _response = await NetworkHelper.authorizedFetch(cardListEndpoint, headers);
      _cardsModel = cardsModelFromJson(_response);
      return true;
    } catch (e) {
      if (e.toString().contains("401")) {
        var isNewTokenObtained = await NetworkHelper.getNewToken(headers);
        if (isNewTokenObtained) return await fetchCards(ucsdAffiliation);
      }
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// SIMPLE GETTERS
  get error => _error;
  get isLoading => _isLoading;
  get lastUpdated => _lastUpdated;
  Map<String, CardsModel> get cardsModel => _cardsModel;
}
