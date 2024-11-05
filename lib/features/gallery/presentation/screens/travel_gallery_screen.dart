import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/gallery_post.dart';

class TravelGalleryScreen extends StatelessWidget {
  const TravelGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 임시 데이터 - 실제로는 Firebase나 다른 백엔드에서 가져와야 함
    final List<Map<String, String>> posts = [
      {
        "imageUrl": "https://picsum.photos/500/500",
        "username": "여행러버",
        "location": "제주도",
        "description": "제주도의 아름다운 풍경과 함께한 특별한 하루",
      },
      // 더 많은 포스트 추가 가능
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '여행 갤러리',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // 새 게시물 작성 화면으로 이동
            },
            icon: const Icon(CupertinoIcons.camera),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return GalleryPost(
            imgUrl: post["imageUrl"]!,
            username: post["username"]!,
            location: post["location"]!,
            description: post["description"]!,
          );
        },
      ),
    );
  }
}
