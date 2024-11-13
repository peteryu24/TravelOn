import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int _totalUnreadCount = 0;

  int get currentIndex => _currentIndex;
  int get totalUnreadCount => _totalUnreadCount;

  bool shouldResetChatListScreen = false;

  void setIndex(int index) {
    _currentIndex = index;
    if (index != 2) {
      requestChatListReset();
    }
    notifyListeners();
  }

  void updateTotalUnreadCount(int count) {
    _totalUnreadCount = count;
    notifyListeners();
  }

  void requestChatListReset() {
    shouldResetChatListScreen = true;
    notifyListeners();
  }

  void confirmChatListReset() {
    shouldResetChatListScreen = false;
  }

  String get totalUnreadDisplay {
    return _totalUnreadCount > 999 ? "+999" : _totalUnreadCount.toString();
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
