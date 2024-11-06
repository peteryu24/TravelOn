import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/repositories/gallery_repository.dart';
import '../../domain/entities/gallery_post_entity.dart';
import '../../domain/entities/comment_entity.dart';

class GalleryProvider extends ChangeNotifier {
  final GalleryRepository _repository;
  List<GalleryPost> _posts = [];
  bool _isLoading = false;
  Stream<List<GalleryPost>>? _postsStream;
  StreamSubscription<List<GalleryPost>>? _subscription;
  final Map<String, List<Comment>> _postComments = {};

  GalleryProvider(this._repository) {
    _initStream();
  }

  void _initStream() {
    _postsStream = _repository.getGalleryPosts();
    _subscription = _postsStream?.listen((posts) {
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

  // 댓글 추가
  Future<void> addComment({
    required String postId,
    required String userId,
    required String username,
    String? userProfileUrl,
    required String content,
  }) async {
    try {
      // 낙관적 업데이트를 위해 현재 상태 유지
      final currentComments = List<Comment>.from(_postComments[postId] ?? []);

      await _repository.addComment(
        postId: postId,
        userId: userId,
        username: username,
        userProfileUrl: userProfileUrl,
        content: content,
      );
    } catch (e) {
      // 에러 발생 시 원래 상태로 복구
      _postComments[postId] = List<Comment>.from(_postComments[postId] ?? []);
      notifyListeners();
      rethrow;
    }
  }

  // 특정 게시글의 댓글 목록 가져오기
  List<Comment> getCommentsForPost(String postId) {
    return _postComments[postId] ?? [];
  }

  // 댓글 스트림 구독
  void subscribeToComments(String postId) {
    _repository.getComments(postId).listen((comments) {
      _postComments[postId] = comments;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // 로그아웃 시 호출할 메서드
  void reset() {
    _subscription?.cancel();
    _posts = [];
    notifyListeners();
  }
}
