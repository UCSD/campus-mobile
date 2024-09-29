import 'dart:async';
import 'package:campus_mobile_experimental/app_networking.dart';
import 'package:campus_mobile_experimental/core/models/employee_id.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmployeeIdService {
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  EmployeeIdModel _employeeIdModel = EmployeeIdModel();
  final NetworkHelper _networkHelper = NetworkHelper();

  Future<bool> fetchEmployeeIdProfile(Map<String, String> headers) async {
    _error = null; _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.authorizedFetch(
          dotenv.get('MY_EMPLOYEE_PROFILE_API_ENDPOINT'), headers);

      _employeeIdModel = employeeIdModelFromJson(_response);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
    finally {
      _isLoading = false;
    }
  }

  String? get error => _error;
  EmployeeIdModel get employeeIdModel => _employeeIdModel;
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
