import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/gallery_provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';

class AddGalleryPostScreen extends StatefulWidget {
  const AddGalleryPostScreen({super.key});

  @override
  State<AddGalleryPostScreen> createState() => _AddGalleryPostScreenState();
}

class _AddGalleryPostScreenState extends State<AddGalleryPostScreen> {
  File? _image;
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> _uploadPost() async {
    if (!_formKey.currentState!.validate() || _image == null) return;

    setState(() => _isLoading = true);

    try {
      final user = context.read<AuthProvider>().currentUser!;
      await context.read<GalleryProvider>().uploadPost(
            userId: user.id,
            username: user.name,
            userProfileUrl: user.profileImageUrl,
            imageFile: _image!,
            location: _locationController.text,
            description: _descriptionController.text,
          );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물이 업로드되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('업로드 실패: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 게시물'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _uploadPost,
            child: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '공유',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200.h,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0XFF2196F3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 50),
                          Text('이미지 추가'),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: '위치',
                hintText: '예: 서울 남산타워',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0XFF2196F3),
                  ),
                ),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? '위치를 입력해주세요' : null,
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '설명',
                hintText: '여행 경험을 공유해주세요',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0XFF2196F3),
                  ),
                ),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 5,
              validator: (value) =>
                  value?.isEmpty ?? true ? '설명을 입력해주세요' : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
