import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/student_id_barcode_model.dart';
import 'package:campus_mobile_experimental/core/models/student_id_name_model.dart';
import 'package:campus_mobile_experimental/core/models/student_id_photo_model.dart';
import 'package:campus_mobile_experimental/core/models/student_id_profile_model.dart';
import 'package:campus_mobile_experimental/core/services/student_id_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentIdDataProvider extends ChangeNotifier {
  StudentIdDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;

    ///INITIALIZE SERVICES
    _studentIdService = StudentIdService();
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;
  int _selectedCourse;

  ///MODELS
  StudentIdBarcodeModel _studentIdBarcodeModel;
  StudentIdNameModel _studentIdNameModel;
  StudentIdPhotoModel _studentIdPhotoModel;
  StudentIdProfileModel _studentIdProfileModel;

  ///Additional Provider
  UserDataProvider _userDataProvider;

  ///SERVICES
  StudentIdService _studentIdService;

  //Fetch Information From Models
  void fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    /// Verify that user is logged in
    if(_userDataProvider.isLoggedIn){

      //Initialize header
      final Map<String, String> header = {
        'Authorization':
            'Bearer ${_userDataProvider?.authenticationModel?.accessToken}'
      };

      // Fetch Barcode
      if(await _studentIdService.fetchStudentIdBarcode(header)){
        _studentIdBarcodeModel = _studentIdService.studentIdBarcodeModel;
      }else{
        /// Error Handling
        _error = _studentIdService.error.toString();
        _isLoading = false;
        notifyListeners();

        /// Short Circuit
        return;
      }
      
      /// Fetch Name
      if(await _studentIdService.fetchStudentIdName(header)){
        _studentIdNameModel = _studentIdService.studentIdNameModel;
      }else{
        /// Error Handling
        _error = _studentIdService.error.toString();
        _isLoading = false;
        notifyListeners();

        /// Short Circuit
        return;
      }
      
      /// Fetch Photo
      if(await _studentIdService.fetchStudentIdPhoto(header)){
        _studentIdPhotoModel = _studentIdService.studentIdPhotoModel;
      }else{
        /// Error Handling
        _error = _studentIdService.error.toString();
        _isLoading = false;
        notifyListeners();

        /// Short Circuit
        return;
      }

      // Fetch Profile
      if(await _studentIdService.fetchStudentIdProfile(header)){
        _studentIdProfileModel = _studentIdService.studentIdProfileModel;
      }else{
        /// Error Handling
        _error = _studentIdService.error.toString();
        _isLoading = false;
        notifyListeners();

        /// Short Circuit
        return;
      }

    }else{
      _error = _studentIdService.error.toString();
      _isLoading = false;
      notifyListeners();

      /// Short Circuit
      return;
    }

  }


  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  StudentIdBarcodeModel get studentIdBarcodeModel => _studentIdBarcodeModel;
  StudentIdNameModel get studentIdNameModel => _studentIdNameModel;
  StudentIdPhotoModel get studentIdPhotoModel => _studentIdPhotoModel;
  StudentIdProfileModel get studentIdProfileModel => _studentIdProfileModel;
  int get selectedCourse => _selectedCourse;


  ///Simple Setters
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;
}
