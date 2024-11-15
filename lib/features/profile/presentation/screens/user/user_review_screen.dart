import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/review/presentation/provider/review_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class UserReviewScreen extends StatelessWidget {
  final String userId;

  const UserReviewScreen({required this.userId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();

    final userReviews = reviewProvider.reviews
        .where((review) => review.userId == userId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("작성한 리뷰"),
      ),
      body: userReviews.isEmpty
          ? Center(
              child: Text("작성한 리뷰가 없습니다."),
            )
          : ListView.builder(
              itemCount: userReviews.length,
              padding: EdgeInsets.all(16.w),
              itemBuilder: (context, index) {
                final review = userReviews[index];
                final formattedDate = DateFormat('yyyy.MM.dd').format(review.createdAt);

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      review.content,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4.h),
                        Text(
                          "평점: ${review.rating} / 5",
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "작성일: $formattedDate",
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
