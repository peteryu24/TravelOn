import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/package_list.dart';
import '../widgets/region_filter.dart';
import '../providers/travel_provider.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TravelProvider>().loadPackages();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 검색 모드 시작
  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  // 검색 모드 종료
  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      context.read<TravelProvider>().clearSearch();
    });
  }

  // 검색창 위젯
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: '패키지 제목이나 설명으로 검색...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
            context.read<TravelProvider>().clearSearch();
          },
        ),
      ),
      style: TextStyle(color: Colors.black, fontSize: 16.0.sp),
      onChanged: (query) {
        context.read<TravelProvider>().search(query);
      },
      textInputAction: TextInputAction.search,
    );
  }

  // AppBar 타이틀 위젯
  Widget _buildTitle() {
    return _isSearching ? _buildSearchField() : const Text('여행 패키지');
  }

  // AppBar 액션 버튼들
  List<Widget> _buildActions() {
    if (_isSearching) {
      return [];
    }

    return [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
      Consumer<TravelProvider>(
        builder: (context, provider, child) => RegionFilter(
          onRegionChanged: (String region) {
            provider.filterByRegion(region);
          },
        ),
      ),
      SizedBox(width: 8.w),
    ];
  }

  // 검색 결과 카운트 위젯
  Widget _buildSearchInfo() {
    return Consumer<TravelProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SizedBox.shrink();
        }

        if (_isSearching && _searchController.text.isNotEmpty) {
          final matchCount = provider.packages.length;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            color: Colors.grey[100],
            child: Row(
              children: [
                Text(
                  '검색 결과: $matchCount개',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                if (provider.selectedRegion != 'all')
                  Text(
                    '지역: ${_getRegionText(provider.selectedRegion)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          );
        }

        if (provider.selectedRegion != 'all') {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            color: Colors.grey[100],
            child: Text(
              '선택된 지역: ${_getRegionText(provider.selectedRegion)}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // 메인 위젯 빌드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _stopSearch,
              )
            : null,
        title: _buildTitle(),
        actions: _buildActions(),
      ),
      body: Column(
        children: [
          _buildSearchInfo(),
          const Expanded(
            child: PackageList(),
          ),
        ],
      ),
    );
  }
}
