import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/cards.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CardsService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  Map<String, CardsModel>? _cardsModel;

  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  Future<bool> fetchCards(String? ucsdAffiliation) async {
    _error = null;
    _isLoading = true;

    if (ucsdAffiliation == null) ucsdAffiliation = "";

    /// API Manager Service
    try {
      String cardListEndpoint = dotenv.get('CARD_LIST_ENDPOINT') + ucsdAffiliation;
      String _response =
          await _networkHelper.authorizedFetch(cardListEndpoint, headers);
      _cardsModel = cardsModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      if (e.toString().contains("401")) {
        if (await _networkHelper.getNewToken(headers)) {
          return await fetchCards(ucsdAffiliation);
        }
      }
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  String? get error => _error;
  Map<String, CardsModel>? get cardsModel => _cardsModel;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
