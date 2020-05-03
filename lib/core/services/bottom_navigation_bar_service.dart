import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class BottomNavigationBarProvider with ChangeNotifier {
  int _currentIndex = 0;

  get currentIndex => _currentIndex;
//  set currentIndex(int index) {
//    _currentIndex = index;
//    notifyListeners();
//  }
  get indexChangeSource => _indexChangeSource;

  updateCurrentIndex(int index, String source) {
    _currentIndex = index;
    _indexChangeSource = source;
    notifyListeners();
  }
}
