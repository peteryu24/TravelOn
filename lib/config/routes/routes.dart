import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_on_final/features/gallery/presentation/screens/edit_gallery_post_screen.dart';
import 'package:travel_on_final/features/gallery/presentation/screens/add_gallery_post_screen.dart';
import 'package:travel_on_final/features/gallery/presentation/screens/scrapped_posts_screen.dart';
import 'package:travel_on_final/features/gallery/presentation/screens/travel_gallery_screen.dart';
// ... other imports ...

final router = GoRouter(
  routes: [
    // ... other routes ...

    // 갤러리 관련 라우트
    GoRoute(
      path: '/add-gallery-post',
      builder: (context, state) => const AddGalleryPostScreen(),
    ),
    GoRoute(
      path: '/edit-gallery-post',
      builder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        return EditGalleryPostScreen(
          postId: extra['postId'] as String,
          location: extra['location'] as String,
          description: extra['description'] as String,
          imageUrl: extra['imageUrl'] as String,
        );
      },
    ),
    GoRoute(
      path: '/scrapped-posts',
      builder: (context, state) => const ScrappedPostsScreen(),
    ),
    // ... other routes ...
  ],
);
