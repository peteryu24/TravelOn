import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_on_final/features/auth/presentation/screens/login_screen.dart';
import '../providers/travel_provider.dart';
import '../../domain/entities/travel_package.dart';

class PackageList extends StatelessWidget {
  const PackageList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TravelProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        final packages = provider.packages;
        if (packages.isEmpty) {
          return const Center(child: Text('등록된 패키지가 없습니다.'));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final package = packages[index];
            return PackageCard(package: package);
          },
        );
      },
    );
  }
}

class PackageCard extends StatelessWidget {
  final TravelPackage package;
  final NumberFormat _priceFormat = NumberFormat('#,###');

  PackageCard({
    Key? key,
    required this.package,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/package-detail/${package.id}', extra: package);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 메인 이미지 - Image.file을 Image.network로 변경
            if (package.mainImage != null && package.mainImage!.isNotEmpty)
              Image.network(
                package.mainImage!,
                height: 200.h,
                width: double.infinity,
                fit: BoxFit.cover,
                // 로딩 중 표시
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
                // 에러 발생 시 표시
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
                color: Colors.grey[200],
                child: Center(
                  child: Icon(
                    Icons.landscape,
                    size: 50,
                    color: Colors.grey[400],
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    package.description,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '₩${_priceFormat.format(package.price.toInt())}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
