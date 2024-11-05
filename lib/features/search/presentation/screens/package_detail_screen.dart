import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/travel_package.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';

class PackageDetailScreen extends StatefulWidget {
  final TravelPackage package;

  const PackageDetailScreen({
    Key? key,
    required this.package,
  }) : super(key: key);

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  final NumberFormat _priceFormat = NumberFormat('#,###');
  Future<int>? _todayParticipants;
  bool _isAvailable = true;
  late final int _minParticipants;
  late final int _maxParticipants;


  @override
  void initState() {
    super.initState();
    _minParticipants = widget.package.minParticipants;
    _maxParticipants = widget.package.maxParticipants;
    _loadTodayParticipants();
  }

  Future<void> _loadTodayParticipants() async {
    setState(() {
      _todayParticipants = _getParticipantsForDate(DateTime.now());
    });
  }

  Future<int> _getParticipantsForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('packageId', isEqualTo: widget.package.id)
        .where('status', isEqualTo: 'approved')
        .where('reservationDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('reservationDate', isLessThan: Timestamp.fromDate(end))
        .get();

    setState(() {
      _isAvailable = snapshot.docs.length < widget.package.maxParticipants;
    });

    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('패키지 상세'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 메인 이미지
            if (widget.package.mainImage != null && widget.package.mainImage!.isNotEmpty)
              Image.network(
                widget.package.mainImage!,
                height: 200.h,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200.h,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200.h,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.error_outline,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                height: 200.h,
                width: double.infinity,
                color: Colors.blue.shade100,
                child: Center(
                  child: Icon(
                    Icons.landscape,
                    size: 64,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 및 지역
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.package.title,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getRegionText(widget.package.region),
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 8.w),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.black),
                                  SizedBox(width: 8.w),
                                  Text(
                                    '가이드 : ${widget.package.guideName}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                      final userId = authProvider.currentUser?.id;
                                      if (userId != null) {
                                        final otherUserId = widget.package.guideId;
                                        final sortedIds = [userId, otherUserId]..sort((a, b) => b.compareTo(a));
                                        final chatId = '${sortedIds[0]}_${sortedIds[1]}';

                                        context.push('/chat/$chatId');  // GoRouter로 채팅 화면으로 이동
                                      }
                                    },
                                    icon: Icon(Icons.chat),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            SizedBox(width: 8.w),
                            const Icon(Icons.group, color: Colors.black),
                            Text(
                              '예약 가능 인원: $_minParticipants명 ~ $_maxParticipants명',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: _isAvailable ? Colors.black : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            SizedBox(width: 8.h),
                            Text(
                              '1인 ${_priceFormat.format(widget.package.price.toInt())}원',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (!_isAvailable)
                    Container(
                      margin: EdgeInsets.only(top: 8.w),
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.red),
                          SizedBox(width: 8.w),
                          Text(
                            '오늘은 예약이 마감되었습니다',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 24.h),

                  // 설명
                  Text(
                    '상세 설명',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.package.description,
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.5.h,
                    ),
                  ),

                  // 설명 이미지들
                  if (widget.package.descriptionImages.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    Text(
                      '상세 이미지',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.package.descriptionImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.package.descriptionImages[index],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200.h,
                                  width: double.infinity,
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200.h,
                                  width: double.infinity,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(
                                      Icons.error_outline,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isAvailable
              ? () => context.push('/reservation/${widget.package.id}', extra: widget.package)
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            _isAvailable ? '예약하기' : '오늘은 예약 마감',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  String _getRegionText(String region) {
    switch (region) {
      case 'seoul':
        return '서울';
      case 'incheon_gyeonggi':
        return '인천/경기';
      case 'gangwon':
        return '강원';
      case 'daejeon_chungnam':
        return '대전/충남';
      case 'chungbuk':
        return '충북';
      case 'gwangju_jeonnam':
        return '광주/전남';
      case 'jeonbuk':
        return '전북';
      case 'busan_gyeongnam':
        return '부산/경남';
      case 'daegu_gyeongbuk':
        return '대구/경북';
      case 'jeju':
        return '제주도';
      default:
        return '전체';
    }
  }
}
