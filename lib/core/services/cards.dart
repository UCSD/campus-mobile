import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/cards.dart';

class CardsService {
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;

  Map<String, CardsModel> _cardsModel;

  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  Future<bool> fetchCards(String ucsdAffiliation) async {
    _error = null;
    _isLoading = true;

    /// API Manager Service
    try {
      String cardListEndpoint =
          "https://api-qa.ucsd.edu:8243/defaultcards/v4.0.0/defaultcards?ucsdaffiliation=${ucsdAffiliation}";
      String _response =
      await _networkHelper.authorizedFetch(cardListEndpoint, headers);
      _cardsModel = cardsModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      if (e.toString().contains("401")) {
        if (await getNewToken()) {
          return await fetchCards(ucsdAffiliation);
        }
      }
      _error = e.toString();
      _isLoading = false;
      return false;
    }

    /// Card Prototyping Service
    // try {
    //   String cardPrototypeEndpoint =
    //       "https://mobile.ucsd.edu/replatform/v1/qa/cards/prototypes/card-prototype--copy-me.json";
    //   String _response = await _networkHelper.fetchData(cardPrototypeEndpoint);
    //   _cardsModel = cardsModelFromJson(_response);
    //   _isLoading = false;
    //   return true;
    // } catch (e) {
    //   print(e);
    //   _error = e.toString();
    //   _isLoading = false;
    //   return false;
    // }
  }

  Future<bool> getNewToken() async {
    final String tokenEndpoint = "https://api-qa.ucsd.edu:8243/token";
    final Map<String, String> tokenHeaders = {
      "content-type": 'application/x-www-form-urlencoded',
      "Authorization":
      "Basic djJlNEpYa0NJUHZ5akFWT0VRXzRqZmZUdDkwYTp2emNBZGFzZWpmaWZiUDc2VUJjNDNNVDExclVh"
    };
    try {
      var response = await _networkHelper.authorizedPost(
          tokenEndpoint, tokenHeaders, "grant_type=client_credentials");
      headers["Authorization"] = "Bearer " + response["access_token"];
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  String get error => _error;
  Map<String, CardsModel> get cardsModel => _cardsModel;
  bool get isLoading => _isLoading;
  DateTime get lastUpdated => _lastUpdated;
}