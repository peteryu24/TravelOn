import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/map/domain/entities/travel_point.dart';
import 'package:travel_on_final/features/review/presentation/provider/review_provider.dart';
import 'package:travel_on_final/features/review/presentation/screens/add_review_screen.dart';
import 'package:travel_on_final/features/review/presentation/screens/review_detail_screen.dart';
import 'package:travel_on_final/features/review/presentation/widgets/review_list.dart';
import 'package:travel_on_final/features/search/presentation/providers/travel_provider.dart';
import '../../domain/entities/travel_package.dart';
import 'package:travel_on_final/features/chat/domain/usecases/create_chat_id.dart';

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
  bool _showReviews = false;
  int _minParticipants = 0;  // 기본값 설정
  int _maxParticipants = 0;  // 기본값 설정
  String? _currentUserId;


  @override
  void initState() {
    super.initState();
    // initState에서 값 설정
    _minParticipants = widget.package.minParticipants;
    _maxParticipants = widget.package.maxParticipants;
    _loadTodayParticipants();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ReviewProvider>().loadPreviewReviews(widget.package.id);
      }
    });
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
                  _buildReviewSection(), // 여기로 리뷰 섹션 이동

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
                                  if (_currentUserId != widget.package.guideId)
                                    IconButton(
                                      onPressed: () async {
                                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                        final userId = authProvider.currentUser?.id;
                                        if (userId != null) {
                                          final otherUserId = widget.package.guideId;
                                          final chatId = CreateChatId().call(userId, otherUserId);
                                          context.push('/chat/$chatId');
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
                              widget.package.minParticipants != null && widget.package.maxParticipants != null
                                  ? '예약 가능 인원: ${widget.package.minParticipants}명 ~ ${widget.package.maxParticipants}명'
                                  : '예약 가능 인원: 정보 없음',
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

                  SizedBox(height: 24.h),
                  Text(
                    '여행 코스',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (widget.package.routePoints.isNotEmpty)
                    Container(
                      height: 300.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: NaverMap(
                        options: NaverMapViewOptions(
                          initialCameraPosition: NCameraPosition(
                            target: NLatLng(37.5666102, 126.9783881),
                            zoom: 12,
                          ),
                          scrollGesturesEnable: true,
                          tiltGesturesEnable: true,
                          zoomGesturesEnable: true,
                          rotationGesturesEnable: true,
                        ),
                        onMapReady: (controller) {
                          // 마커 추가
                          for (var i = 0; i < widget.package.routePoints.length; i++) {
                            final point = widget.package.routePoints[i];
                            final marker = NMarker(
                              id: point.id,
                              position: point.location,
                            );

                            // 마커 캡션(순서 표시)
                            marker.setCaption(
                              NOverlayCaption(
                                text: '${i + 1}. ${point.name}',
                                textSize: 14,
                                color: Colors.blue,
                                haloColor: Colors.white,
                              ),
                            );

                            controller.addOverlay(marker);
                          }

                          // 경로 그리기
                          for (var i = 0; i < widget.package.routePoints.length - 1; i++) {
                            final start = widget.package.routePoints[i];
                            final end = widget.package.routePoints[i + 1];

                            final pathOverlay = NPathOverlay(
                              id: 'path_$i',
                              coords: [start.location, end.location],
                              color: Colors.blue.withOpacity(0.8),
                              width: 3,
                              outlineColor: Colors.white,
                            );

                            controller.addOverlay(pathOverlay);
                          }

                          // 모든 마커가 보이도록 카메라 위치 조정
                          if (widget.package.routePoints.isNotEmpty) {
                            final bounds = _calculateBounds(widget.package.routePoints);
                            controller.updateCamera(
                              NCameraUpdate.fitBounds(
                                bounds,
                                padding: const EdgeInsets.all(50),
                              ),
                            );
                          }
                        },
                      ),
                    )
                  else
                    Container(
                      height: 100.h,
                      alignment: Alignment.center,
                      child: Text(
                        '등록된 여행 코스가 없습니다',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16.sp,
                        ),
                      ),
                    ),

// 여행 코스 목록 표시
                  if (widget.package.routePoints.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.package.routePoints.length,
                      itemBuilder: (context, index) {
                        final point = widget.package.routePoints[index];
                        return ListTile(
                          leading: Icon(
                            point.type == PointType.hotel ? Icons.hotel :
                            point.type == PointType.restaurant ? Icons.restaurant :
                            Icons.photo_camera,
                            color: Colors.blue,
                          ),
                          title: Text('${index + 1}. ${point.name}'),
                          subtitle: Text(point.address),
                        );
                      },
                    ),
                  ],

                  SizedBox(height: 24.h),
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

  Widget _buildReviewSection() {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, _) {
        final totalReviewCount = reviewProvider.totalReviewCount;
        final totalAverageRating = reviewProvider.totalAverageRating;  // 전체 평균 별점 사용

        return TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReviewDetailScreen(package: widget.package),
              ),
            ).then((_) {
              reviewProvider.loadPreviewReviews(widget.package.id);
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '리뷰($totalReviewCount)',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 20.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                totalAverageRating.toStringAsFixed(1),  // 전체 평균 별점 표시
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        );
      },
    );
  }

  NLatLngBounds _calculateBounds(List<TravelPoint> points) {
    var minLat = points.first.location.latitude;
    var maxLat = points.first.location.latitude;
    var minLng = points.first.location.longitude;
    var maxLng = points.first.location.longitude;

    for (var point in points) {
      if (point.location.latitude < minLat) minLat = point.location.latitude;
      if (point.location.latitude > maxLat) maxLat = point.location.latitude;
      if (point.location.longitude < minLng) minLng = point.location.longitude;
      if (point.location.longitude > maxLng) maxLng = point.location.longitude;
    }

    return NLatLngBounds(
      southWest: NLatLng(minLat, minLng),
      northEast: NLatLng(maxLat, maxLng),
    );
  }
}
