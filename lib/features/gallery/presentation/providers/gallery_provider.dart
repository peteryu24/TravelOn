import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/repositories/gallery_repository.dart';
import '../../domain/entities/gallery_post_entity.dart';

class GalleryProvider extends ChangeNotifier {
  final GalleryRepository _repository;
  List<GalleryPost> _posts = [];
  bool _isLoading = false;
  Stream<List<GalleryPost>>? _postsStream;

  GalleryProvider(this._repository) {
    // 생성자에서 스트림 초기화
    _postsStream = _repository.getGalleryPosts();
    // 스트림 구독
    _postsStream?.listen((posts) {
      _posts = posts;
      notifyListeners();
    });
  }

  List<GalleryPost> get posts => _posts;
  bool get isLoading => _isLoading;

  // 포스트 업로드
  Future<void> uploadPost({
    required String userId,
    required String username,
    String? userProfileUrl,
    required File imageFile,
    required String location,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.uploadPost(
        userId: userId,
        username: username,
        userProfileUrl: userProfileUrl,
        imageFile: imageFile,
        location: location,
        description: description,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 좋아요 토글
  Future<void> toggleLike(String postId, String userId) async {
    await _repository.toggleLike(postId, userId);
  }

  @override
  void dispose() {
    // 메모리 누수 방지를 위해 스트림 구독 취소
    super.dispose();
  }
}
