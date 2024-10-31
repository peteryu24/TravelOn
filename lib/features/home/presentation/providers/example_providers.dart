// lib/features/home/presentation/providers/example_providers.dart

import 'package:flutter/material.dart';

class ExampleProvider extends ChangeNotifier {
  // 상태를 저장할 변수
  String _exampleText = "초기 값";

  // 상태에 대한 getter
  String get exampleText => _exampleText;

  // 상태를 변경하는 메서드
  void updateExampleText(String newText) {
    _exampleText = newText;
    notifyListeners(); // 상태가 변경되었음을 알림
  }
}
