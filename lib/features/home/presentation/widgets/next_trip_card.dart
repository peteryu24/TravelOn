// lib/features/home/presentation/widgets/next_trip_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';

class NextTripCard extends StatelessWidget {
  const NextTripCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final homeProvider = context.watch<HomeProvider>();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${user?.name ?? '게스트'}님,',
            style: TextStyle(fontSize: 18.sp),
          ),
          if (homeProvider.isLoading)
            const CircularProgressIndicator()
          else if (homeProvider.nextTrip != null)
            Text(
              homeProvider.nextTrip!.isTodayTrip
                  ? '즐거운 ${homeProvider.nextTrip!.packageTitle} 되세요!'
                  : '${homeProvider.nextTrip!.packageTitle}까지\nD-${homeProvider.nextTrip!.dDay} 남았습니다!',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Text(
              '예정된 여행이 없습니다.',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
