import 'package:campus_mobile_experimental/core/models/cards_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';

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
    String cardListEndpoint =
        'https://api-qa.ucsd.edu:8243/defaultcards/v1.0.0';
    _error = null;
    _isLoading = true;
    if (ucsdAffiliation == null) {
      ucsdAffiliation = "";
    }
    try {
      //form query string with ucsd affiliation
      cardListEndpoint += "?ucsdaffiliation=${ucsdAffiliation}";

      /// fetch data
      String _response =
          await _networkHelper.authorizedFetch(cardListEndpoint, headers);

      /// parse data
      _cardsModel = cardsModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<bool> getNewToken() async {
    final String tokenEndpoint = "https://api-qa.ucsd.edu:8243/token";
    final Map<String, String> tokenHeaders = {
      "content-type": 'application/x-www-form-urlencoded',
      "Authorization":
          "Basic WUNaMXlLTW9wMjNxcGtvUFQ1aDYzdHB5bm9rYTpQNnFCbWNIRFc5azNJME56S3hHSm5QTTQzV0lh"
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
