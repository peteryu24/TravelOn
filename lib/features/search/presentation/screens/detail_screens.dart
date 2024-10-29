import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/package_list.dart';
import '../widgets/region_filter.dart';
import '../providers/travel_provider.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // ignore: unused_element
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 패키지'),
        actions: [
          Consumer<TravelProvider>(
            builder: (context, provider, child) => Row(
              children: [
                RegionFilter(
                  onRegionChanged: (String region) {
                    provider.filterByRegion(region);
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
      body: const PackageList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-package');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}