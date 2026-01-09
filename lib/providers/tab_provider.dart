import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class TabProvider with ChangeNotifier{
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void changeTabIndex(int index){
    if (_currentIndex == index) return;
    _currentIndex = index;
    
    notifyListeners();
  }
}