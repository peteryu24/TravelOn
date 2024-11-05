import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/gallery_post_entity.dart';

class GalleryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  GalleryRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // 갤러리 포스트 목록 가져오기
  Stream<List<GalleryPost>> getGalleryPosts() {
    return _firestore
        .collection('gallery_posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GalleryPost.fromJson(doc.data()))
          .toList();
    });
  }

  // 새 포스트 업로드
  Future<void> uploadPost({
    required String userId,
    required String username,
    String? userProfileUrl,
    required File imageFile,
    required String location,
    required String description,
  }) async {
    try {
      // 1. 이미지를 Storage에 업로드
      final String fileName =
          'gallery_images/${DateTime.now().millisecondsSinceEpoch}_$userId.jpg';
      final Reference storageRef = _storage.ref().child(fileName);
      await storageRef.putFile(imageFile);
      final String imageUrl = await storageRef.getDownloadURL();

      // 2. Firestore에 포스트 데이터 저장
      final docRef = _firestore.collection('gallery_posts').doc();
      final post = GalleryPost(
        id: docRef.id,
        userId: userId,
        username: username,
        userProfileUrl: userProfileUrl,
        imageUrl: imageUrl,
        location: location,
        description: description,
        createdAt: DateTime.now(),
        likedBy: [],
        likeCount: 0,
        comments: [],
      );

      await docRef.set(post.toJson());
    } catch (e) {
      throw Exception('포스트 업로드 실패: $e');
    }
  }

  // 좋아요 토글
  Future<void> toggleLike(String postId, String userId) async {
    final docRef = _firestore.collection('gallery_posts').doc(postId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception('포스트를 찾을 수 없습니다');
      }

      final post = GalleryPost.fromJson(snapshot.data()!);
      final likedBy = List<String>.from(post.likedBy);

      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
      } else {
        likedBy.add(userId);
      }

      transaction.update(docRef, {
        'likedBy': likedBy,
        'likeCount': likedBy.length,
      });
    });
  }
}
