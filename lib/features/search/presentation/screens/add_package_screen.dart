import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
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
  final _maxParticipantsController = TextEditingController();
  int _nights = 1;  // 기본값 1박
  final Set<int> _selectedDepartureDays = {};  // 선택된 출발 요일들

  final List<Map<String, dynamic>> _weekDays = [
    {'value': 1, 'label': '월'},
    {'value': 2, 'label': '화'},
    {'value': 3, 'label': '수'},
    {'value': 4, 'label': '목'},
    {'value': 5, 'label': '금'},
    {'value': 6, 'label': '토'},
    {'value': 7, 'label': '일'},
  ];

  Widget _buildNightsSelection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0XFF2196F3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('박 수:', style: TextStyle(fontSize: 16)),
          DropdownButton<int>(
            value: _nights,
            isDense: true,
            underline: Container(), // 드롭다운 버튼의 기본 밑줄 제거
            items: List.generate(7, (index) => index + 1).map((nights) {
              return DropdownMenuItem(
                value: nights,
                child: Text('$nights박${nights + 1}일'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _nights = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDepartureDaysSelection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0XFF2196F3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('출발 요일', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _weekDays.map((day) {
              final isSelected = _selectedDepartureDays.contains(day['value']);
              return ChoiceChip(
                label: Text(
                  day['label'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                showCheckmark: false,  // 체크마크 비활성화
                selectedColor: Colors.blue,
                backgroundColor: Colors.white,
                side: BorderSide(color: isSelected ? Colors.blue : Colors.grey),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDepartureDays.add(day['value']);
                    } else {
                      _selectedDepartureDays.remove(day['value']);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }


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
    _maxParticipantsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDepartureDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('출발 요일을 선택해주세요')),
        );
        return;
      }

      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser!;

      final newPackage = TravelPackage(
        id: DateTime.now().toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        region: _selectedRegion,
        mainImage: _mainImage?.path,
        descriptionImages: _descriptionImages.map((file) => file.path).toList(),
        guideName: user.name,
        guideId: user.id,
        maxParticipants: int.parse(_maxParticipantsController.text),
        nights: _nights,
        departureDays: _selectedDepartureDays.toList()..sort(),
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
                      border: Border.all(color: const Color(0XFF2196F3)),
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

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '패키지 제목',
                    hintText: '예: 서울 시티 투어',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0XFF2196F3),
                      ),
                    ),
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
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0XFF2196F3),
                      ),
                    ),
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
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0XFF2196F3),
                      ),
                    ),
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

                _buildNightsSelection(),
                const SizedBox(height: 16),

                _buildDepartureDaysSelection(),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _maxParticipantsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '최대 인원',
                    hintText: '예: 10',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0XFF2196F3),
                      ),
                    ),
                    suffixText: '명',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '최대 인원을 입력해주세요';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number <= 0) {
                      return '유효한 인원 수를 입력해주세요';
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
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0XFF2196F3),
                      ),
                    ),
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
