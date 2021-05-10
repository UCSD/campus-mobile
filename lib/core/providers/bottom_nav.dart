

import 'package:flutter/material.dart';

class BottomNavigationBarProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;
  set currentIndex(int index) {
    print('Tab: currentIndex: ' + index.toString());
    _currentIndex = index;
    notifyListeners();
  }
}
