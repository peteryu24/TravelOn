import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GalleryPost extends StatefulWidget {
  final String imgUrl;
  final String username;
  final String location;
  final String description;

  const GalleryPost({
    super.key,
    required this.imgUrl,
    required this.username,
    required this.location,
    required this.description,
  });

  @override
  State<GalleryPost> createState() => _GalleryPostState();
}

class _GalleryPostState extends State<GalleryPost> {
  bool isLiked = false;
  int likeCount = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(10.r),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: NetworkImage(widget.imgUrl),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    widget.location,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Image.network(
          widget.imgUrl,
          height: 400.h,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  isLiked = !isLiked;
                  isLiked ? likeCount++ : likeCount--;
                });
              },
              icon: Icon(
                isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                color: isLiked ? Colors.red : null,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(CupertinoIcons.chat_bubble),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(CupertinoIcons.bookmark),
            ),
          ],
        ),
        if (likeCount > 0)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              '좋아요 $likeCount개',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        Padding(
          padding: EdgeInsets.all(10.r),
          child: Text(widget.description),
        ),
        Divider(height: 20.h),
      ],
    );
  }
}
