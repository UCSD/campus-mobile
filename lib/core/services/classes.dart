import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/classes.dart';
import 'package:campus_mobile_experimental/core/models/term.dart';

class ClassScheduleService {
  final String academicTermEndpoint =
      'https://m9zc9vs4f1.execute-api.us-west-2.amazonaws.com/dev/v1/term/current';
  final String myAcademicHistoryApiEndpoint =
      'https://api-qa.ucsd.edu:8243/student/my/academic_history/v1/class_list';
  bool _isLoading = false;
  DateTime _lastUpdated;
  String _error;
  ClassScheduleModel _UNdata = ClassScheduleModel();
  ClassScheduleModel _GRdata = ClassScheduleModel();
  AcademicTermModel _academicTermModel;

  final NetworkHelper _networkHelper = NetworkHelper();

  Future<bool> fetchUNCourses(Map<String, String> headers, String term) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.authorizedFetch(
          myAcademicHistoryApiEndpoint + '?academic_level=UN&term_code=' + term,
          headers);

      /// parse data
      _UNdata = classScheduleModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<bool> fetchGRCourses(Map<String, String> headers, String term) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.authorizedFetch(
          myAcademicHistoryApiEndpoint + '?academic_level=GR&term_code=' + term,
          headers);

      /// parse data
      _GRdata = classScheduleModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Future<bool> fetchAcademicTerm() async {
    _error = null;
    _isLoading = true;
    try {
      String _response = await _networkHelper.fetchData(academicTermEndpoint);
      _academicTermModel = academicTermModelFromJson(_response);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  String get error => _error;
  ClassScheduleModel get UNdata => _UNdata;
  ClassScheduleModel get GRdata => _GRdata;
  AcademicTermModel get academicTermModel => _academicTermModel;
  bool get isLoading => _isLoading;
  DateTime get lastUpdated => _lastUpdated;
}
