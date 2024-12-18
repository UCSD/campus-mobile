import 'package:flutter/material.dart';

class BottomNavigationBarProvider with ChangeNotifier {
  var _currentIndex = 0;

  /// SIMPLE SETTERS
  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  /// SIMPLE GETTERS
  int get currentIndex => _currentIndex;
}
