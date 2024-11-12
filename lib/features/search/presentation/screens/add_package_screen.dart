import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/home/presentation/screens/home_screen.dart';
import 'package:travel_on_final/features/map/domain/entities/travel_point.dart';
import 'package:travel_on_final/features/map/presentation/screens/naver_route_map_screen.dart';
import 'package:travel_on_final/features/map/presentation/screens/place_search_screen.dart';
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
  final _minParticipantsController = TextEditingController();
  List<TravelPoint> _routePoints = [];



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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0XFF2196F3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('박 수:', style: TextStyle(fontSize: 16.sp)),
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
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0XFF2196F3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('출발 요일', style: TextStyle(fontSize: 16.sp)),
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

      // 디버깅을 위한 로그 추가
      print('Creating package with min participants: ${int.parse(_minParticipantsController.text)}');

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
        minParticipants: int.parse(_minParticipantsController.text),  // 여기 확인
        maxParticipants: int.parse(_maxParticipantsController.text),
        nights: _nights,
        departureDays: _selectedDepartureDays.toList()..sort(),
        routePoints: _routePoints,  // 추가
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
          padding: EdgeInsets.all(16.0.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 메인 이미지 선택
                GestureDetector(
                  onTap: _pickMainImage,
                  child: Container(
                    height: 200.h,
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
                SizedBox(height: 16.h),

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
                SizedBox(height: 16.h),

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
                SizedBox(height: 16.h),

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
                SizedBox(height: 16.h),

                _buildRouteSelection(),  // 여기에 추가
                SizedBox(height: 16.h),

                _buildNightsSelection(),
                SizedBox(height: 16.h),

                _buildDepartureDaysSelection(),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _minParticipantsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '최소 인원',
                    hintText: '예: 2',
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
                      return '최소 인원을 입력해주세요';
                    }
                    final minNumber = int.tryParse(value);
                    if (minNumber == null || minNumber <= 0) {
                      return '유효한 인원 수를 입력해주세요';
                    }
                    final maxNumber = int.tryParse(_maxParticipantsController.text) ?? 0;
                    if (minNumber > maxNumber) {
                      return '최소 인원이 최대 인원보다 클 수 없습니다';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

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
                SizedBox(height: 16.h),

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
                SizedBox(height: 16.h),

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
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._descriptionImages.asMap().entries.map((entry) {
                          return Stack(
                            children: [
                              Container(
                                width: 100.w,
                                height: 100.h,
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
                            width: 100.w,
                            height: 100.h,
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
                SizedBox(height: 24.h),

                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
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

  Widget _buildRouteSelection() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0XFF2196F3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('여행 코스', style: TextStyle(fontSize: 16.sp)),
          SizedBox(height: 8.h),

          // 선택된 장소들 표시
          if (_routePoints.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _routePoints.length,
              itemBuilder: (context, index) {
                final point = _routePoints[index];
                return ListTile(
                  leading: Icon(
                    point.type == PointType.hotel ? Icons.hotel :
                    point.type == PointType.restaurant ? Icons.restaurant :
                    Icons.photo_camera,
                  ),
                  title: Text(point.name),
                  subtitle: Text(point.address),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _routePoints.removeAt(index);
                            // 순서 재정렬
                            for (var i = 0; i < _routePoints.length; i++) {
                              _routePoints[i] = _routePoints[i].copyWith(order: i);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

          SizedBox(height: 16.h),

          // 장소 추가 버튼
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_location),
              label: const Text('장소 추가'),
              onPressed: () async {
                final result = await Navigator.push<TravelPoint>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaceSearchScreen(
                      selectedPoints: _routePoints,
                    ),
                  ),
                );

                if (result != null) {
                  setState(() {
                    _routePoints.add(result);
                  });
                }
              },
            ),
          ),

          if (_routePoints.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('경로 미리보기'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NaverRouteMapScreen(
                        points: _routePoints,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
