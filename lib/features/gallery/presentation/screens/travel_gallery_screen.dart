import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/gallery_post.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';

class TravelGalleryScreen extends StatelessWidget {
  const TravelGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => context.push('/add-gallery-post'),
            icon: const Icon(CupertinoIcons.camera),
          ),
        ],
      ),
      body: Consumer<GalleryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = provider.posts;
          if (posts.isEmpty) {
            return const Center(child: Text('아직 게시물이 없습니다'));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return GalleryPost(
                postId: post.id,
                imgUrl: post.imageUrl,
                username: post.username,
                location: post.location,
                description: post.description,
                likedBy: post.likedBy,
                likeCount: post.likeCount,
              );
            },
          );
        },
      ),
    );
  }
}
