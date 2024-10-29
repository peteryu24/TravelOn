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
          // 지역 선택 드롭다운
          Consumer<TravelProvider>(
            builder: (context, provider, child) => RegionFilter(
              onRegionChanged: (String region) {
                provider.filterByRegion(region);
              },
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
