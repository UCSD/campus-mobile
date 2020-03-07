import 'dart:async';
import 'package:campus_mobile_experimental/core/models/special_events_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';

class SpecialEventsService {
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  SpecialEventsModel _specialEventsModel = SpecialEventsModel();

  final Map<String, String> headers = {
    "accept": "application/json",
  };
  final String endpoint =
      "https://ucsd-mobile-dev.s3-us-west-1.amazonaws.com/mock-apis/special-events/welcome-week-always-on.json";

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response =
          await _networkHelper.authorizedFetch(endpoint, headers);

      /// parse data
      _specialEventsModel = specialEventsModelFromJson(_response.toString());
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  bool get isLoading => _isLoading;

  String get error => _error;

  DateTime get lastUpdated => _lastUpdated;

  SpecialEventsModel get specialEventsModel => _specialEventsModel;
}

//TODO
//While shifting things over to the SpecialEventsDataProivder remember to create getters for the data you are going to access. (Most of it should be private)
// The goal is to get any method that does not return a Widget out of the UI file and into SpecialEventsDataProivder or the appropriate file
// Move “List selectEvents(SpecialEventsModel data)” method and place into SpecialEventsDataProivder
// Move String currentDateSelection into SpecialEventsDataProvider
// Move “var appBarTitleText” into SpecialEventsDataProvider
// Move getLabel method into SpecialEventsDataProvider
// Do not use myEventList inside of SpecialEventsViewModel. Instead use “Provider.of(context)” to access variables inside SpecialEventsDataProivder
// Make SpecialEventsViewModel a stateless widget
// Make BannerCard a stateless widget and move it to “lib/UI/cards/special_events/“
// Rename SpecialEventsViewModel to SpecialEventsListView
// Rename SpecialEventsInfoView to SpecialEventsDetailView
// Make sure all the Class names match up with the file names as well
