import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int _totalUnreadCount = 0;

  int get currentIndex => _currentIndex;
  int get totalUnreadCount => _totalUnreadCount;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void updateTotalUnreadCount(int count) {
    _totalUnreadCount = count;
    notifyListeners();
  }

  String getPathForIndex(int index) {
    switch (index) {
      case 0:
        return '/';
      case 1:
        return '/search';
      case 2:
        return '/chat_list';
      case 3:
        return '/profile';
      default:
        return '/';
    }
  }
}
