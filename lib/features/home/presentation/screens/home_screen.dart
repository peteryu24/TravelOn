// lib/features/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // AppBar가 필요한 경우
          AppBar(
            title: const Text('홈'),
          ),
          // 페이지 컨텐츠
          const Expanded(
            child: Center(
              child: Text('홈 페이지 컨텐츠'),
            ),
          ),
        ],
      ),
    );
  }
}
