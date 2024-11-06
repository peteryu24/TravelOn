import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/chat/presentation/providers/chat_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomSheetWidget {
  final ImagePicker _picker = ImagePicker();

  void showBottomSheetMenu({
    required BuildContext parentContext,
    required String chatId,
    required String userId,
    required String otherUserId,
    required String currentUserProfileImage,
    required String username,
  }) {
    final chatProvider = Provider.of<ChatProvider>(parentContext, listen: false);

    showModalBottomSheet(
      context: parentContext,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconButton(
                  context,
                  icon: Icons.image,
                  label: '갤러리',
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      _showConfirmationDialog(parentContext, image, chatId, userId, otherUserId, currentUserProfileImage, username);
                    }
                  },
                ),
                _buildIconButton(
                  context,
                  icon: Icons.camera_alt,
                  label: '카메라',
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      _showConfirmationDialog(parentContext, image, chatId, userId, otherUserId, currentUserProfileImage, username);
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 30.w,
            child: Icon(icon, size: 30.w, color: Colors.white),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 14.sp),
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
