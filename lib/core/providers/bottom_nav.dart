import 'package:flutter/material.dart';

class BottomNavigationBarProvider with ChangeNotifier {
  var _currentIndex = 0;

  int get currentIndex => _currentIndex;
  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
