import 'package:campus_mobile_experimental/core/models/class_schedule_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';

class ClassScheduleService {
  final String endpoint =
      'https://ucsd-mobile-dev.s3-us-west-1.amazonaws.com/mock-apis/academic/MyAcademicHistory-studentdemo.json';
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  ClassScheduleModel _data;

  final NetworkHelper _networkHelper = NetworkHelper();

  Future<bool> fetchData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(endpoint);

      /// parse data
      final data = classScheduleModelFromJson(_response);
      _isLoading = false;
      _data = data;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  String get error => _error;
  ClassScheduleModel get classScheduleModel => _data;
  bool get isLoading => _isLoading;
  DateTime get lastUpdated => _lastUpdated;
}
