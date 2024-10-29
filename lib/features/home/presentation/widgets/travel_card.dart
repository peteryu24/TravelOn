import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TravelCard extends StatelessWidget {
  final String location; // 위치
  final String title; // 제목
  final String imageUrl; // 이미지 URL
  final Color? tagBackgroundColor; // 태그 배경색
  final Color? tagTextColor; // 태그 텍스트 색상

  const TravelCard({
    super.key,
    required this.location,
    required this.title,
    required this.imageUrl,
    this.tagBackgroundColor = Colors.blue,
    this.tagTextColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationTag(),
            SizedBox(height: 8.h),
            _buildTitle(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTag() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: tagBackgroundColor?.withOpacity(0.2) ?? Colors.blue.shade100,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        location,
        style: TextStyle(
          color: tagTextColor ?? Colors.blue,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
