import 'package:campus_mobile_experimental/core/models/student_id_barcode.dart';
import 'package:campus_mobile_experimental/core/models/student_id_name.dart';
import 'package:campus_mobile_experimental/core/models/student_id_photo.dart';
import 'package:campus_mobile_experimental/core/models/student_id_profile.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/student_id.dart';
import 'package:flutter/material.dart';

class StudentIdDataProvider extends ChangeNotifier
{
  ///STATES
  bool _isLoading = false;
  DateTime? _lastUpdated;
  String? _error;
  int? _selectedCourse;

  ///MODELS
  StudentIdBarcodeModel? _studentIdBarcodeModel;
  StudentIdNameModel? _studentIdNameModel;
  StudentIdPhotoModel? _studentIdPhotoModel;
  StudentIdProfileModel? _studentIdProfileModel;

  ///Additional Provider
  late UserDataProvider _userDataProvider;

  ///SERVICES
  StudentIdService _studentIdService = StudentIdService();

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
            'Bearer ${_userDataProvider.authenticationModel.accessToken}'
      };

      /// Fetch Barcode
      if (await _studentIdService.fetchStudentIdBarcode(header) &&
          _studentIdService.studentIdBarcodeModel.barCode != null) {
        _studentIdBarcodeModel = _studentIdService.studentIdBarcodeModel;
      } else {
        /// Error Handling
        _error = _studentIdService.error.toString();
        _isLoading = false;
        notifyListeners();

        /// Short Circuit
        return;
      }

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
  StudentIdBarcodeModel? get studentIdBarcodeModel => _studentIdBarcodeModel;
  StudentIdNameModel? get studentIdNameModel => _studentIdNameModel;
  StudentIdPhotoModel? get studentIdPhotoModel => _studentIdPhotoModel;
  StudentIdProfileModel? get studentIdProfileModel => _studentIdProfileModel;
  int? get selectedCourse => _selectedCourse;

  ///Simple Setters
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;
}
