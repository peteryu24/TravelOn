import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/gallery_provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import '../../../reservation/presentation/providers/reservation_provider.dart';
import '../../../reservation/domain/entities/reservation_entity.dart';

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
  String? _selectedPackageId;
  List<ReservationEntity> _confirmedReservations = [];

  @override
  void initState() {
    super.initState();
    _loadConfirmedReservations();
  }

  Future<void> _loadConfirmedReservations() async {
    final userId = context.read<AuthProvider>().currentUser!.id;
    await context.read<ReservationProvider>().loadReservations(userId);
    setState(() {
      _confirmedReservations = context
          .read<ReservationProvider>()
          .reservations
          .where((r) => r.status == 'approved')
          .toList();
    });
  }

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

      // 선택된 패키지의 정보 가져오기
      String? selectedPackageTitle;
      if (_selectedPackageId != null) {
        final selectedReservation = _confirmedReservations.firstWhere(
          (r) => r.packageId == _selectedPackageId,
          orElse: () => throw Exception('선택한 패키지를 찾을 수 없습니다'),
        );
        selectedPackageTitle = selectedReservation.packageTitle;
      }

      await context.read<GalleryProvider>().uploadPost(
            userId: user.id,
            username: user.name,
            userProfileUrl: user.profileImageUrl,
            imageFile: _image!,
            location: _locationController.text,
            description: _descriptionController.text,
            packageId: _selectedPackageId,
            packageTitle: selectedPackageTitle,
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.r,
              right: 16.r,
              top: 16.r,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.r,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0XFF2196F3)),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 50.r,
                                  ),
                                  SizedBox(height: 8.h),
                                  const Text('이미지 추가'),
                                ],
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: '위치',
                      hintText: '예: 서울 남산타워',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: const BorderSide(
                          color: Color(0XFF2196F3),
                        ),
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? '위치를 입력해주세요' : null,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: '설명',
                      hintText: '여행 경험을 공유해주세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: const BorderSide(
                          color: Color(0XFF2196F3),
                        ),
                      ),
                      prefixIcon: const Icon(Icons.description),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) =>
                        value?.isEmpty ?? true ? '설명을 입력해주세요' : null,
                  ),
                  if (_confirmedReservations.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    DropdownButtonFormField<String>(
                      value: _selectedPackageId,
                      decoration: InputDecoration(
                        labelText: '여행 패키지 태그',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(
                            color: Color(0XFF2196F3),
                          ),
                        ),
                        prefixIcon: const Icon(Icons.local_offer),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                      hint: const Text('관련 패키지 선택 (선택사항)'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('선택 안함'),
                        ),
                        ..._confirmedReservations.map((reservation) {
                          return DropdownMenuItem(
                            value: reservation.packageId,
                            child: Text(
                              reservation.packageTitle,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedPackageId = value;
                        });
                      },
                    ),
                  ],
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
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
