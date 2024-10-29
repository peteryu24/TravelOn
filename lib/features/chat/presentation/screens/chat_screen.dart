import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_on_final/features/chat/presentation/providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  ChatScreen({required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<ChatProvider>(context, listen: false).startListeningToMessages(widget.chatId);
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: chatProvider.messages.length,
              itemBuilder: (ctx, index) {
                final message = chatProvider.messages[index];
                return ListTile(title: Text(message.text));
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요...',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  if (messageController.text.isNotEmpty) {
                    chatProvider.sendMessageToChat(
                      chatId: widget.chatId,
                      text: messageController.text,
                      otherUserId: 'otherUserId', // 실제 상대방 사용자 ID 필요
                      context: context,
                    );
                    messageController.clear();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
