import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travel_on_final/features/chat/domain/entities/message_entity.dart';
import 'package:travel_on_final/features/chat/domain/usecases/create_chat_id.dart';
import 'package:go_router/go_router.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final String otherUserName;
  final String currentUserId;

  const MessageBubble({
    required this.message,
    required this.isMe,
    required this.otherUserName,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!isMe)
          Padding(
            padding: EdgeInsets.only(left: 50.w),
            child: Text(
              otherUserName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: 14.sp,
              ),
            ),
          ),
        Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            if (!isMe && message.profileImageUrl != null)
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: CircleAvatar(
                  backgroundImage: message.profileImageUrl != null && message.profileImageUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(message.profileImageUrl!)
                      : AssetImage('assets/images/default_profile.png') as ImageProvider,
                  radius: 15.r,
                ),
              ),
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue.shade100 : Colors.blueAccent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
              margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
              child: (message.sharedUser != null)
                  ? _buildUserDetails(context, message.sharedUser!)
                  : (message.imageUrl != null && message.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: message.imageUrl!,
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        )
                      : Text(
                          message.text,
                          style: TextStyle(
                            color: isMe ? Colors.black : Colors.white,
                            fontSize: 14.sp,
                          ),
                        )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserDetails(BuildContext context, Map<String, dynamic> user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: user['profileImageUrl'] != null && user['profileImageUrl'].isNotEmpty
              ? CachedNetworkImageProvider(user['profileImageUrl'])
              : AssetImage('assets/images/default_profile.png') as ImageProvider,
          radius: 30.r,
        ),
        SizedBox(height: 8.h),
        Text(
          user['name'] ?? '이름 없음',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        Text(
          user['email'] ?? '이메일 없음',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
        SizedBox(height: 8.h),
        Text(
          user['introduction'] ?? '소개 없음',
          style: TextStyle(fontSize: 14.sp),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                ),
                onPressed: () {
                  if (currentUserId.isNotEmpty && user['id'] is String && (user['id'] as String).isNotEmpty) {
                    final userId = user['id'] as String;
                    final chatId = CreateChatId().call(currentUserId, userId);
                    try {
                      Navigator.pop(context);
                      context.push('/chat/$chatId');
                    } catch (e) {
                      print('Navigation error: $e');
                    }
                  } else {
                    print('유효하지 않은 ID입니당');
                  }
                },
                child: Text(
                  '1:1 채팅',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                ),
                onPressed: () {
                  // 프로필 보기 기능 추가 예정
                },
                child: Text(
                  '프로필 보기',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
