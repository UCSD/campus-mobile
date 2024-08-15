import 'package:campus_mobile_experimental/core/models/employee_id.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/employee_id.dart';
import 'package:flutter/material.dart';

class EmployeeIdDataProvider extends ChangeNotifier
{
  ///STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;

  ///MODELS
  EmployeeIdModel? _employeeIdModel;

  ///Additional Provider
  late UserDataProvider _userDataProvider;

  ///SERVICES
  EmployeeIdService _employeeIdService = EmployeeIdService();

  void fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final Map<String, String> header = {
      'Authorization':
      'Bearer ${_userDataProvider.authenticationModel.accessToken}'
    };

    /// Verify that user is logged in
    if (_userDataProvider.isLoggedIn
        && await _employeeIdService.fetchEmployeeIdProfile(header))
    {
      // Fetch Profile
      _employeeIdModel = _employeeIdService.employeeIdModel;
    } else {
      _error = _employeeIdService.error.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  EmployeeIdModel? get employeeIdModel => _employeeIdModel;

  ///Simple Setters
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;
}
