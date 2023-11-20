import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// class BottomNavigationBarProvider with ChangeNotifier {
//   int _currentIndex = 0;
//
//   int get currentIndex => _currentIndex;
//   set currentIndex(int index) {
//     _currentIndex = index;
//     notifyListeners();
//   }
// }
ValueNotifier<int> _currentIndex = ValueNotifier(0);
ValueNotifier<int> useBottomNavigationBar() {
  useListenable(_currentIndex);
  return _currentIndex;
}
void setBottomNavigationBarIndex(int index){
  _currentIndex.value = index;
}
