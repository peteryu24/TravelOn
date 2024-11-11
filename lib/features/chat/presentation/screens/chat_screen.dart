import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/chat/presentation/providers/chat_provider.dart';
import 'package:travel_on_final/features/chat/presentation/widgets/message_bubble_widget.dart';
import 'package:travel_on_final/features/chat/presentation/widgets/bottom_sheet_widget.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  ChatScreen({required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final BottomSheetWidget _bottomSheetWidget = BottomSheetWidget();
  String? otherUserId;
  String otherUserName = "Chat";
  bool isMessageEntered = false;
  Color intermediateColor = Color.lerp(Colors.lightBlue[50], Colors.lightBlue[100], 0.5)!;

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userIds = widget.chatId.split('_');
    otherUserId = userIds.first == authProvider.currentUser!.id ? userIds.last : userIds.first;

    Provider.of<ChatProvider>(context, listen: false).fetchOtherUserInfo(otherUserId!).then((name) {
      setState(() {
        otherUserName = "$name";
      });
    });

    Provider.of<ChatProvider>(context, listen: false).startListeningToMessages(widget.chatId);
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("${otherUserName}님과의 대화"),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: chatProvider.messages.length,
                itemBuilder: (ctx, index) {
                  final message = chatProvider.messages[index];
                  final isMe = message.uId == Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
                  return MessageBubble(
                    message: message,
                    isMe: isMe,
                    otherUserName: otherUserName,
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: 0.6,
                    color: Colors.blue.withOpacity(0.5),
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: intermediateColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.add, color: Colors.lightBlue[700]),
                      onPressed: () {
                        _bottomSheetWidget.showBottomSheetMenu(
                          parentContext: context,
                          chatId: widget.chatId,
                          userId: Provider.of<AuthProvider>(context, listen: false).currentUser!.id,
                          otherUserId: otherUserId!,
                          currentUserProfileImage: Provider.of<AuthProvider>(context, listen: false).currentUser!.profileImageUrl ?? '',
                          username: Provider.of<AuthProvider>(context, listen: false).currentUser!.name,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 8,),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        setState(() {
                          isMessageEntered = value.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        filled: true,
                        fillColor: Colors.lightBlue[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  SizedBox(width: 8,),
                  Container(
                    decoration: BoxDecoration(
                      color: intermediateColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: isMessageEntered ? Colors.blue : Colors.grey,
                      ),
                      onPressed: isMessageEntered
                          ? () {
                              chatProvider.sendMessageToChat(
                                chatId: widget.chatId,
                                text: messageController.text,
                                otherUserId: otherUserId!,
                                context: context,
                              );
                              messageController.clear();
                              setState(() {
                                isMessageEntered = false;
                              });
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
