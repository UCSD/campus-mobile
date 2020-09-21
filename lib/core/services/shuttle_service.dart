import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_arrival_model.dart';
import 'package:campus_mobile_experimental/core/models/shuttle_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';

class ShuttleService {
  ShuttleService();
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  ShuttleModel _shuttleModel = ShuttleModel();
  List<ShuttleModel> _data = List<ShuttleModel>();
  UserDataProvider userDataProvider;
  /// add state related things for view model here
  /// add any type of data manipulation here so it can be accessed via provider

  List<ShuttleModel> get data => _data;

  final NetworkHelper _networkHelper = NetworkHelper();
  final String endpoint = "https://api-qa.ucsd.edu:8243/shuttles/v1.0.0/stops";
  String arrivingEndpoint;
  final Map<String, String> headers = {
    "accept": "application/json",
    "Authorization":
    "Bearer "
  };

  Future<bool> fetchData() async {
//    if(userDataProvider.isLoggedIn) {
//      headers["Authorization"] = "Bearer " + userDataProvider.authenticationModel?.accessToken.toString();
//    }
//    print("headers:" + headers.toString());
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
//      String _response = await _networkHelper.authorizedFetch(endpoint, headers);
      String _response = await _networkHelper.fetchData("https://api.jsonbin.io/b/5f6101a07243cd7e823cd3d9");
      /// parse data
//      var data = shuttleModelFromJson(_response);
      var data = _shuttleModel.getListOfShuttles(_response);
      _data = data;
      _isLoading = false;
      return true;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
//      if (e.response != null && e.response.statusCode == 401) {
//        if (await getNewToken()) {
//          return await fetchData();
//        }
//      }
//      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<ArrivingShuttle> getArrivingInformation(stopId) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      arrivingEndpoint = "https://api.jsonbin.io/b/5f63b30265b18913fc4e0776";
      String _response = await _networkHelper.fetchData(arrivingEndpoint);
      /// parse data
      final arrivingData = getArrivingShuttles(_response);
      _isLoading = false;
      return arrivingData;
    } catch (e) {
      /// if the authorized fetch failed we know we have to refresh the
      /// token for this service
//      if (e.response != null && e.response.statusCode == 401) {
//        if (await getNewToken()) {
//          return await getArrivingInformation(stopId);
//        }
//      }
//      _error = e.toString();
      _isLoading = false;
    }
  }

  Future<bool> getNewToken() async {
    final String tokenEndpoint = "https://api-qa.ucsd.edu:8243/token";
    final Map<String, String> tokenHeaders = {
      "content-type": 'application/x-www-form-urlencoded',
      "Authorization": "Basic WUNaMXlLTW9wMjNxcGtvUFQ1aDYzdHB5bm9rYTpQNnFCbWNIRFc5azNJME56S3hHSm5QTTQzV0lh"
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

  bool get isLoading => _isLoading;

  String get error => _error;

  DateTime get lastUpdated => _lastUpdated;
}