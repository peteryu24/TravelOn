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
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          return Column(
            children: [
              // 별점과 리뷰 개수 표시
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
                              provider.totalAverageRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '리뷰 ${provider.totalReviewCount}개',
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

              // ReviewDetailScreen.dart
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final user = authProvider.currentUser;
                  if (user == null) return const SizedBox.shrink();

                  return FutureBuilder<String?>(
                    future: provider.checkReviewStatus(user.id, widget.package.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final errorMessage = snapshot.data;
                      final canReview = errorMessage == null;

                      return Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          children: [
                            if (!canReview)
                              Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: Text(
                                  errorMessage ?? '',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ElevatedButton(
                              onPressed: canReview ? () async {
                                final reviewProvider = context.read<ReviewProvider>();

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddReviewScreen(
                                      packageId: widget.package.id,
                                      packageTitle: widget.package.title,
                                    ),
                                  ),
                                );

                                if (mounted) {
                                  await reviewProvider.getTotalReviewStats(widget.package.id);
                                  if (mounted) {
                                    await reviewProvider.loadInitialReviews(widget.package.id);
                                  }
                                }
                              } : null,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 48.h),
                              ),
                              child: Text(
                                  canReview ? '리뷰 작성하기' : '리뷰 작성 불가',
                                  style: TextStyle(fontSize: 16.sp)
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              Expanded(
                child: provider.reviews.isEmpty
                    ? const Center(child: Text('아직 작성된 리뷰가 없습니다'))
                    : ListView(
                  children: [
                    ...provider.reviews.map((review) => ReviewCard(review: review)),
                    if (provider.hasMore)
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: ElevatedButton(
                          onPressed: provider.isLoading
                              ? null
                              : () => provider.loadMoreReviews(widget.package.id),
                          child: Text('더보기'),
                        ),
                      ),
                  ],
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final reviewProvider = context.read<ReviewProvider>();
        // 전체 통계와 초기 리뷰를 함께 로드
        reviewProvider.getTotalReviewStats(widget.package.id).then((_) {
          reviewProvider.loadInitialReviews(widget.package.id);
        });
      }
    });
  }
}