import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  String getPathForIndex(int index) {
    switch (index) {
      case 0:
        return '/';
      case 1:
        return '/search';
      case 2:
        return '/chat';
      case 3:
        return '/profile';
      default:
        return '/';
    }
  }
}
