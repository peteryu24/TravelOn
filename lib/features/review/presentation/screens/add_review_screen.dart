import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/review/presentation/provider/review_provider.dart';

class AddReviewScreen extends StatefulWidget {
  final String packageId;
  final String packageTitle;

  const AddReviewScreen({
    Key? key,
    required this.packageId,
    required this.packageTitle,
  }) : super(key: key);

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _contentController = TextEditingController();
  double _rating = 5.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('리뷰 작성')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.packageTitle,
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 16.h),
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
              decoration: InputDecoration(
                labelText: '리뷰 내용',
                hintText: '패키지 여행에 대한 경험을 공유해주세요',
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
                      SnackBar(content: Text('리뷰 내용을 입력해주세요')),
                    );
                    return;
                  }

                  final user = context.read<AuthProvider>().currentUser!;
                  try {
                    await context.read<ReviewProvider>().addReview(
                      packageId: widget.packageId,
                      userId: user.id,
                      userName: user.name,
                      rating: _rating,
                      content: _contentController.text.trim(),
                      context: context,  // context 전달
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('리뷰가 등록되었습니다')),
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
                child: Text('리뷰 등록', style: TextStyle(fontSize: 16.sp)),
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