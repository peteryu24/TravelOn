import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/chat/presentation/providers/chat_provider.dart';
import 'package:travel_on_final/features/chat/presentation/widgets/message_bubble_widget.dart';
import 'package:travel_on_final/features/chat/presentation/widgets/bottom_sheet_widget.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final BottomSheetWidget _bottomSheetWidget = BottomSheetWidget();
  String? otherUserId;
  String otherUserName = "Chat";
  bool isMessageEntered = false;

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    final userIds = widget.chatId.split('_');
    otherUserId = userIds.first == authProvider.currentUser!.id
        ? userIds.last
        : userIds.first;

    // 채팅방 존재 여부 확인 및 생성
    chatProvider
        .ensureChatRoomExists(
      widget.chatId,
      context,
      otherUserId!,
    )
        .then((_) {
      // 채팅방 생성 후 메시지 구독 시작
      chatProvider.startListeningToMessages(widget.chatId);

      // 읽음 처리
      chatProvider.resetUnreadCount(
        widget.chatId,
        authProvider.currentUser!.id,
      );
    });

    chatProvider.fetchOtherUserInfo(otherUserId!).then((name) {
      if (mounted) {
        setState(() {
          otherUserName = name;
        });
      }
    });
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
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$otherUserName ",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              TextSpan(
                text: "님과의 대화",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
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
                  final isMe = message.uId ==
                      Provider.of<AuthProvider>(context, listen: false)
                          .currentUser!
                          .id;
                  return MessageBubble(
                    message: message,
                    isMe: isMe,
                    otherUserName: otherUserName,
                    currentUserId:
                        Provider.of<AuthProvider>(context, listen: false)
                            .currentUser!
                            .id,
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 1.5.w),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon:
                                Icon(Icons.add, color: Colors.blue, size: 24.w),
                            onPressed: () {
                              _bottomSheetWidget.showBottomSheetMenu(
                                parentContext: context,
                                chatId: widget.chatId,
                                userId: Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .currentUser!
                                    .id,
                                otherUserId: otherUserId!,
                                currentUserProfileImage:
                                    Provider.of<AuthProvider>(context,
                                                listen: false)
                                            .currentUser!
                                            .profileImageUrl ??
                                        '',
                                username: Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .currentUser!
                                    .name,
                              );
                            },
                          ),
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
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 10.h),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    decoration: BoxDecoration(
                      color: isMessageEntered ? Colors.blue : Colors.white,
                      border: Border.all(color: Colors.blue, width: 1.5.w),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: IconButton(
                      icon: Transform.rotate(
                        angle: 0,
                        child: Icon(
                          Icons.airplanemode_active,
                          color: isMessageEntered ? Colors.white : Colors.grey,
                          size: 27.w,
                        ),
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
