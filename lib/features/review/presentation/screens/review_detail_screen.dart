// ReviewDetailScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/review/presentation/provider/review_provider.dart';
import 'package:travel_on_final/features/review/presentation/screens/add_review_screen.dart';
import 'package:travel_on_final/features/review/presentation/widgets/review_list.dart';
import 'package:travel_on_final/features/search/domain/entities/travel_package.dart';

class ReviewDetailScreen extends StatefulWidget {
  final TravelPackage package;

  const ReviewDetailScreen({
    Key? key,
    required this.package,
  }) : super(key: key);

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.package.title),
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, reviewProvider, _) {
          final reviews = reviewProvider.reviews;
          final reviewCount = reviews.length;

          double averageRating = 0.0;
          if (reviewCount > 0) {
            double totalRating = reviews.fold(
                0.0, (sum, review) => sum + review.rating);
            averageRating = totalRating / reviewCount;
          }

          return Column(
            children: [
              // 상단 통계 부분 (고정)
              Container(
                padding: EdgeInsets.all(16.w),
                color: Colors.grey[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 24.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '리뷰 $reviewCount개',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 리뷰 작성 버튼 (고정)
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final user = authProvider.currentUser;
                  if (user == null) return const SizedBox.shrink();

                  return FutureBuilder<bool>(
                    future: reviewProvider.canUserAddReview(
                        user.id, widget.package.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: EdgeInsets.all(16.w),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddReviewScreen(
                                      packageId: widget.package.id,
                                      packageTitle: widget.package.title,
                                    ),
                              ),
                            ).then((_) {
                              reviewProvider.loadReviews(widget.package.id);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 48.h),
                          ),
                          child: Text(
                              '리뷰 작성하기', style: TextStyle(fontSize: 16.sp)),
                        ),
                      );
                    },
                  );
                },
              ),

              // 리뷰 목록 (스크롤 가능)
              Expanded(
                child: reviews.isEmpty
                    ? Center(child: Text('아직 작성된 리뷰가 없습니다'))
                    : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: ReviewList(packageId: widget.package.id),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // initState에서 직접 호출하는 대신 마이크로태스크로 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ReviewProvider>().loadReviews(widget.package.id);
      }
    });
  }
}