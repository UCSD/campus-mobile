import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

ValueNotifier<int> _currentIndex = ValueNotifier(0);
ValueNotifier<int> useBottomNavigationBar() {
  useListenable(_currentIndex);
  return _currentIndex;
}
void setBottomNavigationBarIndex(int index){
  _currentIndex.value = index;
}
