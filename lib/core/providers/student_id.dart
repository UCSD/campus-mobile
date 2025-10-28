import 'package:campus_mobile_experimental/core/models/student_id_name.dart';
import 'package:campus_mobile_experimental/core/models/student_id_photo.dart';
import 'package:campus_mobile_experimental/core/models/student_id_profile.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/student_id.dart';
import 'package:flutter/material.dart';

class StudentIdDataProvider extends ChangeNotifier {
  /// STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  int? _selectedCourse;

  /// MODELS
  StudentIdNameModel _studentIdNameModel = StudentIdNameModel();
  StudentIdPhotoModel _studentIdPhotoModel = StudentIdPhotoModel();
  StudentIdProfileModel _studentIdProfileModel = StudentIdProfileModel();

  /// PROVIDERS
  late UserDataProvider _userDataProvider;

  /// SERVICES
  final _studentIdService = StudentIdService();

  // Fetch Information From Models
  void fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    /// Verify that user is logged in
    if (_userDataProvider.isLoggedIn) {
      /// Initialize header
      final Map<String, String> header = {
        'Authorization':
            'Bearer ${_userDataProvider.authenticationModel.accessToken}'
      };

      /// Fetch Name
      if (await _studentIdService.fetchStudentIdName(header)) {
        _studentIdNameModel = _studentIdService.studentIdNameModel;
      } else {
        /// Error Handling
        _error = _studentIdService.error;
        _isLoading = false;
        notifyListeners();

        /// Short Circuit
        return;
      }

      /// Fetch Photo
      if (await _studentIdService.fetchStudentIdPhoto(header)) {
        _studentIdPhotoModel = _studentIdService.studentIdPhotoModel;
      } else {
        /// Error Handling
        _error = _studentIdService.error;
        _isLoading = false;
        notifyListeners();

        /// Short Circuit
        return;
      }

      // Fetch Profile
      if (await _studentIdService.fetchStudentIdProfile(header)) {
        _studentIdProfileModel = _studentIdService.studentIdProfileModel;
      } else {
        /// Error Handling
        _error = _studentIdService.error;
        _isLoading = false;
        notifyListeners();

        /// Short Circuit
        return;
      }
    } else {
      _error = 'User not logged in';
      _isLoading = false;
      notifyListeners();

      /// Short Circuit
      return;
    }
    _isLoading = false;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  /// SIMPLE SETTERS
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;

  /// SIMPLE GETTERS
  get isLoading => _isLoading;
  get error => _error;
  get lastUpdated => _lastUpdated;
  get selectedCourse => _selectedCourse;
  StudentIdNameModel get studentIdNameModel => _studentIdNameModel;
  StudentIdPhotoModel get studentIdPhotoModel => _studentIdPhotoModel;
  StudentIdProfileModel get studentIdProfileModel => _studentIdProfileModel;
}
