import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import '../providers/gallery_provider.dart';

class GalleryPost extends StatefulWidget {
  final String imgUrl;
  final String username;
  final String location;
  final String description;
  final String postId;
  final List<String> likedBy;
  final int likeCount;

  const GalleryPost({
    super.key,
    required this.imgUrl,
    required this.username,
    required this.location,
    required this.description,
    required this.postId,
    required this.likedBy,
    required this.likeCount,
  });

  @override
  State<GalleryPost> createState() => _GalleryPostState();
}

class _GalleryPostState extends State<GalleryPost> {
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    _updateLikeStatus();
  }

  @override
  void didUpdateWidget(GalleryPost oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 위젯이 업데이트될 때마다 좋아요 상태 갱신
    if (oldWidget.likedBy != widget.likedBy ||
        oldWidget.likeCount != widget.likeCount) {
      _updateLikeStatus();
    }
  }

  void _updateLikeStatus() {
    final user = context.read<AuthProvider>().currentUser;
    isLiked = user != null && widget.likedBy.contains(user.id);
    likeCount = widget.likeCount;
  }

  Future<void> _handleLikePress() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      // 즉각적인 UI 업데이트를 위해 상태 먼저 변경
      setState(() {
        isLiked = !isLiked;
        likeCount = isLiked ? likeCount + 1 : likeCount - 1;
      });

      try {
        await context.read<GalleryProvider>().toggleLike(
              widget.postId,
              user.id,
            );
      } catch (e) {
        // 에러 발생 시 상태 롤백
        setState(() {
          isLiked = !isLiked;
          likeCount = isLiked ? likeCount + 1 : likeCount - 1;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('좋아요 처리 중 오류가 발생했습니다')),
          );
        }
      }
    }
  }

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
                backgroundImage:
                    const AssetImage('assets/images/default_profile.png'),
                backgroundColor: Colors.grey[200],
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
              onPressed: _handleLikePress,
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
