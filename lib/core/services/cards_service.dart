import 'package:campus_mobile_experimental/core/models/cards_model.dart';
import 'package:campus_mobile_experimental/core/models/user_profile_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';


class CardsService {


  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;

  Map<String, CardsModel> _cardsModel;

  final NetworkHelper _networkHelper = NetworkHelper();

  Future<bool> fetchCards(String ucsdAffiliation) async {
    String cardListEndpoint =
        'https://rj786p8erh.execute-api.us-west-2.amazonaws.com/qa/defaultcards';
    _error = null;
    _isLoading = true;
    try {
      //form query string with ucsd affiliation
      cardListEndpoint += "?ucsdaffiliation=${ucsdAffiliation}";
      /// fetch data
      String _response = await _networkHelper.fetchData(cardListEndpoint);
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

  String get error => _error;
  Map<String, CardsModel> get cardsModel => _cardsModel;
  bool get isLoading => _isLoading;
  DateTime get lastUpdated => _lastUpdated;
}
