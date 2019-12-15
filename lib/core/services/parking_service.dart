import 'package:campus_mobile_experimental/core/models/parking_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';

class ParkingService {
  ParkingService() {
    fetchParkingLotData();
  }
  bool _isLoading = false;
  List<ParkingModel> _data;
  DateTime _lastUpdated;
  String _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  final String endpoint =
      "https://ucsd-mobile-dev.s3-us-west-1.amazonaws.com/mock-apis/parking/mock_parking_data.json";

  Future<bool> fetchParkingLotData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(endpoint);

      /// parse data
      _data = parkingModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  List<ParkingModel> get data => _data;
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
}
