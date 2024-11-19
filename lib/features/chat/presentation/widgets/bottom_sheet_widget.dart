import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/chat/presentation/providers/chat_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class BottomSheetWidget {
  final ImagePicker _picker = ImagePicker();

  void showBottomSheetMenu({
    required BuildContext parentContext,
    required String chatId,
    required String userId,
    required String otherUserId,
    required String currentUserProfileImage,
    required String username,
    double initialHeightFactor = 0.15,
  }) {
    final chatProvider = Provider.of<ChatProvider>(parentContext, listen: false);

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: initialHeightFactor,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 13.w),
                // 갤러리 버튼
                buildIconButton(
                  context,
                  icon: Icons.image,
                  label: '갤러리',
                  backgroundColor: Colors.lightBlue,
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      _showConfirmationDialog(parentContext, image, chatId, userId, otherUserId, currentUserProfileImage, username);
                    }
                  },
                ),
                SizedBox(width: 15.w),
                // 카메라 버튼
                buildIconButton(
                  context,
                  icon: Icons.camera_alt,
                  label: '카메라',
                  backgroundColor: Colors.blueAccent,
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      _showConfirmationDialog(parentContext, image, chatId, userId, otherUserId, currentUserProfileImage, username);
                    }
                  },
                ),
                SizedBox(width: 15.w),
                // 사용자 버튼
                buildIconButton(
                  context,
                  icon: Icons.person,
                  label: '사용자',
                  backgroundColor: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(
                      '/user-search',
                      extra: {'chatId': chatId, 'otherUserId': otherUserId},
                    );
                  },
                ),
                SizedBox(width: 15.w),
                // 패키지 버튼
                buildIconButton(
                  context,
                  icon: Icons.card_travel,
                  label: '패키지',
                  backgroundColor: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(
                      '/package-search',
                      extra: {'chatId': chatId, 'otherUserId': otherUserId},
                    );
                  },
                ),
                SizedBox(width: 15.w),
                // 지도 버튼
                buildIconButton(
                  context,
                  icon: Icons.map,
                  label: '지도',
                  backgroundColor: Color(0xFF03C75A),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(
                      '/map-search',
                      extra: {'chatId': chatId, 'otherUserId': otherUserId},
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildIconButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: CircleAvatar(
            backgroundColor: backgroundColor,
            radius: 27.w,
            child: Icon(icon, size: 28.w, color: Colors.white),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    XFile image,
    String chatId,
    String userId,
    String otherUserId,
    String currentUserProfileImage,
    String username,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('사진 보내기'),
          content: Image.file(File(image.path)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('아니오'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                chatProvider.sendMessageToChat(
                  chatId: chatId,
                  text: '[Image]',
                  otherUserId: otherUserId,
                  imageFile: image,
                  context: context,
                );
              },
              child: Text('예'),
            ),
          ],
        );
      },
    );
  }
}
