import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/search/presentation/providers/travel_provider.dart';
import 'package:travel_on_final/features/search/presentation/widgets/package_list.dart';

class LikedPackagesScreen extends StatelessWidget {
  const LikedPackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('찜한 패키지'),
      ),
      body: Consumer2<AuthProvider, TravelProvider>(
        builder: (context, authProvider, travelProvider, child) {
          final user = authProvider.currentUser;
          if (user == null) {
            return const Center(
              child: Text('로그인이 필요합니다'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await travelProvider.loadPackages();
            },
            child: Builder(
              builder: (context) {
                final likedPackages = travelProvider.getLikedPackages();

                if (likedPackages.isEmpty) {
                  return const Center(
                    child: Text('찜한 패키지가 없습니다'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: likedPackages.length,
                  itemBuilder: (context, index) {
                    // PackageCard를 LikeablePackageCard로 변경
                    return LikeablePackageCard(package: likedPackages[index]);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}