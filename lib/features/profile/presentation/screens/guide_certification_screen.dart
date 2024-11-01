import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../../auth/presentation/providers/auth_provider.dart';

class GuideCertificationScreen extends StatefulWidget {
  const GuideCertificationScreen({Key? key}) : super(key: key);

  @override
  State<GuideCertificationScreen> createState() => _GuideCertificationScreenState();
}

class _GuideCertificationScreenState extends State<GuideCertificationScreen> {
  File? _certificateImage;
  final _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _certificateImage = File(image.path);
      });
    }
  }

  Future<void> _submitCertification() async {
    if (_certificateImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증 사진을 선택해주세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<AuthProvider>().certifyAsGuide(_certificateImage!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('가이드 인증이 완료되었습니다')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가이드 인증'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '가이드 자격을 인증하기 위해 자격증을 업로드해주세요.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _certificateImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _certificateImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_photo_alternate, size: 50),
                    SizedBox(height: 8),
                    Text('자격증 사진 추가'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitCertification,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Text('인증 신청'),
            ),
          ],
        ),
      ),
    );
  }
}