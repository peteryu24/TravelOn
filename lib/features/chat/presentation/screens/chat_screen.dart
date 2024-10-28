// lib/features/profile/presentation/screens/chat_screen.dart

import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: const Center(child: Text('마이페이지 화면')),
    );
  }
}
