

import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/employee_id.dart';

class EmployeeIdService {
  final String myEmployeeProfileApiUrl =
      'https://api-qa.ucsd.edu:8243/staff/my/v1/profile';

  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  EmployeeIdModel _employeeIdModel = EmployeeIdModel();

  final NetworkHelper _networkHelper = NetworkHelper();

  Future<bool> fetchEmployeeIdProfile(Map<String, String> headers) async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await (_networkHelper.authorizedFetch(
          myEmployeeProfileApiUrl, headers) as FutureOr<String>);

      _employeeIdModel = employeeIdModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  String? get error => _error;
  EmployeeIdModel get employeeIdModel => _employeeIdModel;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
