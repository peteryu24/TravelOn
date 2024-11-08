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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _stopSearch,
        )
            : null,
        title: _isSearching ? _buildSearchField() : const Text(
          '여행 패키지',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
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
        ],
      ),
      body: Column(
        children: [
          _buildSortSelector(),  // 정렬 선택기를 상단에 배치
          _buildSearchInfo(),
          const Expanded(
            child: PackageList(),
          ),
        ],
      ),
    );
  }

  String _getSortText(SortOption option) {
    switch (option) {
      case SortOption.latest:
        return '최신순';
      case SortOption.priceHigh:
        return '가격 높은순';
      case SortOption.priceLow:
        return '가격 낮은순';
      case SortOption.popular:
        return '인기순';
      case SortOption.highRating:
        return '별점 높은순';
      case SortOption.mostReviews:
        return '리뷰 많은순';
      default:
        return '기본순';
    }
  }


  Widget _buildSortSelector() {
    return Consumer<TravelProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    ),
                    builder: (context) {
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text('최신순'),
                              trailing: provider.currentSort == SortOption.latest
                                  ? Icon(Icons.check, color: Colors.blue)
                                  : null,
                              onTap: () {
                                provider.sortPackages(SortOption.latest);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text('인기순'),
                              trailing: provider.currentSort == SortOption.popular
                                  ? Icon(Icons.check, color: Colors.blue)
                                  : null,
                              onTap: () {
                                provider.sortPackages(SortOption.popular);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text('가격 낮은순'),
                              trailing: provider.currentSort == SortOption.priceLow
                                  ? Icon(Icons.check, color: Colors.blue)
                                  : null,
                              onTap: () {
                                provider.sortPackages(SortOption.priceLow);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text('가격 높은순'),
                              trailing: provider.currentSort == SortOption.priceHigh
                                  ? Icon(Icons.check, color: Colors.blue)
                                  : null,
                              onTap: () {
                                provider.sortPackages(SortOption.priceHigh);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text('별점 높은순'),
                              trailing: provider.currentSort == SortOption.highRating
                                  ? Icon(Icons.check, color: Colors.blue)
                                  : null,
                              onTap: () {
                                provider.sortPackages(SortOption.highRating);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: const Text('리뷰 많은순'),
                              trailing: provider.currentSort == SortOption.mostReviews
                                  ? Icon(Icons.check, color: Colors.blue)
                                  : null,
                              onTap: () {
                                provider.sortPackages(SortOption.mostReviews);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getSortText(provider.currentSort),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.arrow_drop_down, color: Colors.black, size: 20.sp),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
