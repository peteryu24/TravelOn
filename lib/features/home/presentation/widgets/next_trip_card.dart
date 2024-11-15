import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
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
            'home.next_trip.greeting'.tr(namedArgs: {
              'name': user?.name ?? 'common.guest'.tr()
            }),
            style: TextStyle(fontSize: 18.sp),
          ),
          if (homeProvider.isLoading)
            const CircularProgressIndicator()
          else if (homeProvider.nextTrip != null)
            Text(
              homeProvider.nextTrip!.isTodayTrip
                  ? 'home.next_trip.today'.tr(namedArgs: {
                'title': homeProvider.nextTrip!.packageTitle
              })
                  : 'home.next_trip.countdown'.tr(namedArgs: {
                'title': homeProvider.nextTrip!.packageTitle,
                'days': homeProvider.nextTrip!.dDay.toString()
              }),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Text(
              'home.next_trip.no_trips'.tr(),
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