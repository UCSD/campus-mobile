import 'dart:async';

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/cards.dart';

class CardsService {
  String CARD_CONSTANT = "{\"NativeScanner\":{\"cardActive\":true,\"initialURL\":\"\",\"isWebCard\":false,\"requireAuth\":false,\"titleText\":\"Scanner\"},\"shuttle\":{\"cardActive\":true,\"initialURL\":\"\",\"isWebCard\":false,\"requireAuth\":false,\"titleText\":\"Shuttle\"},\"dining\":{\"cardActive\":true,\"initialURL\":\"\",\"isWebCard\":false,\"requireAuth\":false,\"titleText\":\"Dining\"},\"parking\":{\"cardActive\":true,\"initialURL\":\"\",\"isWebCard\":false,\"requireAuth\":false,\"titleText\":\"Parking\"},\"availability\":{\"cardActive\":true,\"initialURL\":\"\",\"isWebCard\":false,\"requireAuth\":false,\"titleText\":\"Availability\"},\"events\":{\"cardActive\":true,\"initialURL\":\"\",\"isWebCard\":false,\"requireAuth\":false,\"titleText\":\"Events\"},\"news\":{\"cardActive\":true,\"initialURL\":\"\",\"isWebCard\":false,\"requireAuth\":false,\"titleText\":\"News\"},\"weather\":{\"cardActive\":true,\"initialURL\":\"\",\"isWebCard\":false,\"requireAuth\":false,\"titleText\":\"Weather\"},\"campus_info\":{\"cardActive\":true,\"initialURL\":\"https://mobile.ucsd.edu/replatform/v1/qa/webview/campus_info-v6.html\",\"isWebCard\":true,\"requireAuth\":false,\"titleText\":\"Campus Information\"},\"MyStudentChart\":{\"cardActive\":true,\"initialURL\":\"\",\"isWebCard\":false,\"requireAuth\":false,\"titleText\":\"MyStudentChart\"},\"student_survey\":{\"cardActive\":false,\"initialURL\":\"\",\"isWebCard\":false,\"requireAuth\":false,\"titleText\":\"Student Survey\"},\"student_id\":{\"cardActive\":false,\"initialURL\":\"\",\"isWebCard\":false,\"requireAuth\":false,\"titleText\":\"Student ID\"},\"finals\":{\"cardActive\":false,\"initialURL\":\"\",\"isWebCard\":false,\"requireAuth\":false,\"titleText\":\"Finals\"},\"schedule\":{\"cardActive\":false,\"initialURL\":\"\",\"isWebCard\":false,\"requireAuth\":false,\"titleText\":\"Classes\"},\"student_info\":{\"cardActive\":false,\"initialURL\":\"https://mobile.ucsd.edu/replatform/v1/qa/webview/student_info-v6.html\",\"isWebCard\":true,\"requireAuth\":false,\"titleText\":\"COVID-19 Info\"},\"student_health_wellbeing\":{\"cardActive\":false,\"initialURL\":\"https://mobile.ucsd.edu/replatform/v1/qa/webview/student-health-wellbeing.html\",\"isWebCard\":true,\"requireAuth\":false,\"titleText\":\"Student Health & Wellness\"},\"MyUCSDChart\":{\"cardActive\":false,\"initialURL\":\"\",\"isWebCard\":false,\"requireAuth\":false,\"titleText\":\"MyUCSDChart\"},\"employee_id\":{\"cardActive\":false,\"initialURL\":\"\",\"isWebCard\":false,\"requireAuth\":false,\"titleText\":\"Employee ID\"},\"staff_info\":{\"cardActive\":false,\"initialURL\":\"https://mobile.ucsd.edu/replatform/v1/qa/webview/staff_info-v6.html\",\"isWebCard\":true,\"requireAuth\":false,\"titleText\":\"COVID-19 Info\"},\"ventilation\":{\"cardActive\":false,\"initialURL\":\"\",\"isWebCard\":false,\"requireAuth\":false,\"titleText\":\"Office Environment\"},\"speed_test\":{\"cardActive\":true,\"initialURL\":\"\",\"isWebCard\":false,\"requireAuth\":false,\"titleText\":\"Speed Test\"}}";
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
      String cardListEndpoint =
          "https://api-qa.ucsd.edu:8243/mobilecardsservice/v1.0.0/mobilecardslist?version=7&ucsdaffiliation=" +
              ucsdAffiliation;
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
      }else{
        _cardsModel = cardsModelFromJson(CARD_CONSTANT);
        _isLoading = false;
        return true;
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

  String? get error => _error;
  Map<String, CardsModel>? get cardsModel => _cardsModel;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
