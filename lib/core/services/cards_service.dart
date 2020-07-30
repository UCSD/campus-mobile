import 'package:campus_mobile_experimental/core/models/cards_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';

class CardsService {
  final String cardListEndpoint =
      'https://mobile.ucsd.edu/replatform/v1/qa/cards-v4.json';

  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;

  Map<String, CardsModel> _cardsModel;

  final NetworkHelper _networkHelper = NetworkHelper();

  Future<bool> fetchCards() async {
    _error = null;
    _isLoading = true;
    try {
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
