import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/cards.dart';

class CardsService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  Map<String, CardsModel>? _cardsModel;

  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
    "Authorization":
        "Basic djJlNEpYa0NJUHZ5akFWT0VRXzRqZmZUdDkwYTp2emNBZGFzZWpmaWZiUDc2VUJjNDNNVDExclVh"
  };

  Future<bool> fetchCards(String? ucsdAffiliation) async {
    _error = null;
    _isLoading = true;

    if (ucsdAffiliation == null) ucsdAffiliation = "";

    /// API Manager Service
    try {
      String cardListEndpoint =
          "https://api-qa.ucsd.edu:8243/mobilecardsservice/v1.0.0/mobilecardslist?version=10&ucsdaffiliation=" +
              ucsdAffiliation;
      String _response =
          await _networkHelper.authorizedFetch(cardListEndpoint, headers);
      _cardsModel = cardsModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
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
