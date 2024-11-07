import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/gallery_provider.dart';

class EditGalleryPostScreen extends StatefulWidget {
  final String postId;
  final String location;
  final String description;
  final String imageUrl;

  const EditGalleryPostScreen({
    super.key,
    required this.postId,
    required this.location,
    required this.description,
    required this.imageUrl,
  });

  @override
  State<EditGalleryPostScreen> createState() => _EditGalleryPostScreenState();
}

class _EditGalleryPostScreenState extends State<EditGalleryPostScreen> {
  File? _newImage;
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _locationController.text = widget.location;
    _descriptionController.text = widget.description;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _newImage = File(image.path);
      });
    }
  }

  Future<void> _updatePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<GalleryProvider>().updatePost(
            postId: widget.postId,
            location: _locationController.text,
            description: _descriptionController.text,
            newImage: _newImage,
          );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시물이 수정되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 실패: $e')),
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
        title: const Text('게시물 수정'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updatePost,
            child: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '완료',
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
                child: _newImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _newImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
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
