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
    double initialHeightFactor = 0.3,
  }) {
    final chatProvider = Provider.of<ChatProvider>(parentContext, listen: false);

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: initialHeightFactor,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 4.w),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16.w,
                runSpacing: 16.h,
                children: [
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
                  // 지도 버튼
                  buildIconButton(
                    context,
                    icon: Icons.map,
                    label: '지도',
                    backgroundColor: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildIconButton(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return SizedBox(
      width: 60.w,
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: CircleAvatar(
              backgroundColor: backgroundColor,
              radius: 30.w,
              child: Icon(icon, size: 35.w, color: Colors.white),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
