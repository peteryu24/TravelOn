

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/review/domain/entities/review.dart';
import 'package:travel_on_final/features/review/presentation/provider/review_provider.dart';

class EditReviewScreen extends StatefulWidget {
  final Review review;

  const EditReviewScreen({Key? key, required this.review}) : super(key: key);

  @override
  State<EditReviewScreen> createState() => _EditReviewScreenState();
}

class _EditReviewScreenState extends State<EditReviewScreen> {
  final _contentController = TextEditingController();
  double _rating = 5.0;

  @override
  void initState() {
    super.initState();
    _contentController.text = widget.review.content;
    _rating = widget.review.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('리뷰 수정')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 별점 선택 위젯
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('별점', style: TextStyle(fontSize: 16.sp)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: '리뷰 내용',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_contentController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('리뷰 내용을 입력해주세요')),
                    );
                    return;
                  }

                  try {
                    final currentUser = context.read<AuthProvider>().currentUser!;
                    await context.read<ReviewProvider>().updateReview(
                      reviewId: widget.review.id,
                      packageId: widget.review.packageId,
                      userId: currentUser.id,      // 현재 사용자 ID
                      userName: currentUser.name,  // 현재 사용자 이름
                      rating: _rating,
                      content: _contentController.text.trim(),
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('리뷰가 수정되었습니다')),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: Text('수정 완료', style: TextStyle(fontSize: 16.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}