import 'package:campus_mobile_experimental/core/models/student_id_name.dart';
import 'package:campus_mobile_experimental/core/models/student_id_photo.dart';
import 'package:campus_mobile_experimental/core/models/student_id_profile.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/student_id.dart';
import 'package:flutter/material.dart';

class StudentIdDataProvider extends ChangeNotifier {
  StudentIdDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _studentIdService = StudentIdService();
  }

  ///STATES
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;
  int? _selectedCourse;

  ///MODELS
  StudentIdNameModel? _studentIdNameModel;
  StudentIdPhotoModel? _studentIdPhotoModel;
  StudentIdProfileModel? _studentIdProfileModel;

  ///Additional Provider
  late UserDataProvider _userDataProvider;

  ///SERVICES
  late StudentIdService _studentIdService;

  //Fetch Information From Models
  void fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    /// Verify that user is logged in
    if (_userDataProvider.isLoggedIn) {
      /// Initialize header
      final Map<String, String> header = {
        'Authorization':
            'Bearer ${_userDataProvider.authenticationModel?.accessToken}'
      };

      /// Fetch Name
      if (await _studentIdService.fetchStudentIdName(header) &&
          _studentIdService.studentIdNameModel.firstName != null &&
          _studentIdService.studentIdNameModel.lastName != null) {
        _studentIdNameModel = _studentIdService.studentIdNameModel;
      } else {
        /// Error Handling
        _error = _studentIdService.error.toString();
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
        _error = _studentIdService.error.toString();
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
        _error = _studentIdService.error.toString();
        _isLoading = false;
        notifyListeners();

        /// Short Circuit
        return;
      }
    } else {
      _error = _studentIdService.error.toString();
      _isLoading = false;
      notifyListeners();

      /// Short Circuit
      return;
    }
    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool? get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  StudentIdNameModel? get studentIdNameModel => _studentIdNameModel;
  StudentIdPhotoModel? get studentIdPhotoModel => _studentIdPhotoModel;
  StudentIdProfileModel? get studentIdProfileModel => _studentIdProfileModel;
  int? get selectedCourse => _selectedCourse;

  ///Simple Setters
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;
}
