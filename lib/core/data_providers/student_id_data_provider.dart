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


  UserDataProvider _userDataProvider;

  ///SERVICES
  StudentIdService _studentIdService;

  void fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print("fetchData-----------");

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

  //Peter G.
   void setUserDataProvider(UserDataProvider dataProvider){
     _userDataProvider = dataProvider;
   }
}
