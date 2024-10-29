import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/travel_provider.dart';
import '../../domain/entities/travel_package.dart';

class AddPackageScreen extends StatefulWidget {
  const AddPackageScreen({Key? key}) : super(key: key);

  @override
  State<AddPackageScreen> createState() => _AddPackageScreenState();
}

class _AddPackageScreenState extends State<AddPackageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedRegion = 'seoul';
  File? _mainImage;
  final List<File> _descriptionImages = [];
  final _picker = ImagePicker();

  final List<String> _regions = [
    'seoul',
    'incheon_gyeonggi',
    'gangwon',
    'daejeon_chungnam',
    'chungbuk',
    'gwangju_jeonnam',
    'jeonbuk',
    'busan_gyeongnam',
    'daegu_gyeongbuk',
    'jeju',
  ];

  Future<void> _pickMainImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _mainImage = File(image.path);
      });
    }
  }

  Future<void> _pickDescriptionImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _descriptionImages.add(File(image.path));
      });
    }
  }

  void _removeDescriptionImage(int index) {
    setState(() {
      _descriptionImages.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newPackage = TravelPackage(
        id: DateTime.now().toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        region: _selectedRegion,
        mainImage: _mainImage?.path,  // 실제 구현시에는 서버에 업로드하고 URL을 저장
        descriptionImages: _descriptionImages.map((file) => file.path).toList(),
      );

      context.read<TravelProvider>().addPackage(newPackage);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 패키지 등록'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 메인 이미지 선택
                GestureDetector(
                  onTap: _pickMainImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _mainImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _mainImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_photo_alternate, size: 50),
                        Text('메인 이미지 추가'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 기존 입력 필드들...
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '패키지 제목',
                    hintText: '예: 서울 시티 투어',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '제목을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedRegion,
                  decoration: const InputDecoration(
                    labelText: '지역',
                    border: OutlineInputBorder(),
                  ),
                  items: _regions.map((region) {
                    return DropdownMenuItem(
                      value: region,
                      child: Text(
                          region == 'seoul' ? '서울' :
                          region == 'incheon_gyeonggi' ? '인천/경기' :
                          region == 'gangwon' ? '강원' :
                          region == 'daejeon_chungnam' ? '대전/충남' :
                          region == 'chungbuk' ? '충북' :
                          region == 'gwangju_jeonnam' ? '광주/전남' :
                          region == 'jeonbuk' ? '전북' :
                          region == 'busan_gyeongnam' ? '부산/경남' :
                          region == 'daegu_gyeongbuk' ? '대구/경북' :
                          region == 'jeju' ? '제주도' : '전체'
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRegion = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '가격',
                    hintText: '예: 50000',
                    border: OutlineInputBorder(),
                    prefixText: '₩ ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '가격을 입력해주세요';
                    }
                    if (double.tryParse(value) == null) {
                      return '유효한 숫자를 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: '패키지 설명',
                    hintText: '패키지에 대한 상세 설명을 입력해주세요',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '설명을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 설명 이미지 목록
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '설명 이미지',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._descriptionImages.asMap().entries.map((entry) {
                          return Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    entry.value,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  color: Colors.red,
                                  onPressed: () => _removeDescriptionImage(entry.key),
                                ),
                              ),
                            ],
                          );
                        }),
                        // 이미지 추가 버튼
                        GestureDetector(
                          onTap: _pickDescriptionImage,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate),
                                Text('추가'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '패키지 등록',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
