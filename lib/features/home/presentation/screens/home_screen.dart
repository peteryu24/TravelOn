// lib/features/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/home/presentation/providers/home_provider.dart';
import 'package:travel_on_final/features/home/presentation/widgets/next_trip_card.dart';
import 'package:travel_on_final/features/home/presentation/widgets/travel_card.dart';
import 'package:travel_on_final/features/home/presentation/widgets/weather_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // build가 완료된 후 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNextTrip();
    });
  }

  Future<void> _loadNextTrip() async {
    final authProvider = context.read<AuthProvider>();

    if (authProvider.currentUser != null) {
      await context
          .read<HomeProvider>()
          .loadNextTrip(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // AuthProvider의 상태를 구독
    final user = context.watch<AuthProvider>().currentUser;
    final homeProvider = context.watch<HomeProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'TravelOn',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // D-Day 카운터
              const NextTripCard(),
              const SizedBox(height: 20),

              // 날씨 정보
              const WeatherSlider(),
              SizedBox(height: 30.h),

              // 메뉴 그리드
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 20.w,
                crossAxisSpacing: 20.w,
                children: [
                  _buildMenuItem(Icons.star, '여행꿀팁'),
                  _buildMenuItem(Icons.map_outlined, '코스가이드'),
                  _buildMenuItem(Icons.calendar_today, '일정만들기'),
                  _buildMenuItem(Icons.photo_camera, '여행갤러리'),
                  _buildMenuItem(Icons.wb_sunny, '생생날씨'),
                  _buildMenuItem(Icons.favorite_border, '추천여행지'),
                  _buildMenuItem(Icons.restaurant, '추천맛집'),
                  _buildMenuItem(Icons.location_on, '전국지도'),
                ],
              ),
              SizedBox(height: 30.h),

              // 하단 추천 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '지금 인기있는 여행코스는?',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      children: [
                        const Text(
                          '더보기',
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              // 가로 스크롤 되는 추천 이미지 카드
              SizedBox(
                height: 200.h, // TravelCard의 높이와 동일하게 설정
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: travelItems.length, // 데이터 리스트 길이만큼
                  itemBuilder: (context, index) {
                    final item = travelItems[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: 16.w, // 카드 사이 간격
                        left: index == 0 ? 0 : 0, // 첫 번째 카드는 패딩 없음
                      ),
                      child: SizedBox(
                        width: 300.w, // 카드의 너비 설정
                        child: TravelCard(
                          location: item.location,
                          title: item.title,
                          imageUrl: item.imageUrl,
                          tagBackgroundColor: item.tagBackgroundColor,
                          tagTextColor: item.tagTextColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade800,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// 클래스 상단에 추가
class TravelItem {
  final String location;
  final String title;
  final String imageUrl;
  final Color? tagBackgroundColor;
  final Color? tagTextColor;

  TravelItem({
    required this.location,
    required this.title,
    required this.imageUrl,
    this.tagBackgroundColor,
    this.tagTextColor,
  });
}

// 샘플 데이터 (클래스 내부에 추가)
final List<TravelItem> travelItems = [
  TravelItem(
    location: '부산',
    title: '무봤나? 붓싼 풀코스',
    imageUrl: 'https://picsum.photos/400/200',
  ),
  TravelItem(
    location: '서울',
    title: '서울 야경 투어',
    imageUrl: 'https://picsum.photos/300/200',
    tagBackgroundColor: Colors.green,
    tagTextColor: Colors.green,
  ),
  TravelItem(
    location: '제주',
    title: '제주도 맛집 투어',
    imageUrl: 'https://picsum.photos/200/200',
    tagBackgroundColor: Colors.orange,
    tagTextColor: Colors.orange,
  ),
  TravelItem(
    location: '강원도',
    title: '강원도 힐링 여행',
    imageUrl: 'https://picsum.photos/400/300',
    tagBackgroundColor: Colors.purple,
    tagTextColor: Colors.purple,
  ),
];
