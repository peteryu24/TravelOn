import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/review/domain/entities/review.dart';
import 'package:travel_on_final/features/review/domain/repositories/review_repository.dart';
import 'package:travel_on_final/features/search/presentation/providers/travel_provider.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository _repository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  int _totalReviewCount = 0;
  int get totalReviewCount => _totalReviewCount;
  double _totalAverageRating = 0.0;
  double get totalAverageRating => _totalAverageRating;

  ReviewProvider(this._repository);

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> getTotalReviewStats(String packageId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('packageId', isEqualTo: packageId)
          .get();

      _totalReviewCount = snapshot.docs.length;

      // 전체 평균 별점 계산
      if (_totalReviewCount > 0) {
        double totalRating = 0;
        for (var doc in snapshot.docs) {
          totalRating += (doc.data()['rating'] as num).toDouble();
        }
        _totalAverageRating = totalRating / _totalReviewCount;
      } else {
        _totalAverageRating = 0.0;
      }

      notifyListeners();
    } catch (e) {
      print('Error getting total review stats: $e');
      rethrow;
    }
  }

  Future<void> getTotalReviewCount(String packageId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('packageId', isEqualTo: packageId)
          .get();

      _totalReviewCount = snapshot.docs.length;
      notifyListeners();
    } catch (e) {
      print('Error getting total review count: $e');
    }
  }

  Future<void> loadInitialReviews(String packageId) async {
    _reviews = [];
    _lastDocument = null;
    _hasMore = true;
    _error = null;
    await loadMoreReviews(packageId);
  }

  Future<void> loadMoreReviews(String packageId) async {
    if (!_hasMore || _isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      // 먼저 전체 리뷰 개수를 가져옴
      final totalSnapshot = await _firestore
          .collection('reviews')
          .where('packageId', isEqualTo: packageId)
          .get();

      final totalCount = totalSnapshot.docs.length;

      // 다음 5개의 리뷰를 가져옴
      Query query = _firestore
          .collection('reviews')
          .where('packageId', isEqualTo: packageId)
          .orderBy('createdAt', descending: true)
          .limit(5);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasMore = false;
      } else {
        final newReviews = snapshot.docs.map((doc) => Review(
          id: doc.id,
          packageId: doc['packageId'],
          userId: doc['userId'],
          userName: doc['userName'],
          rating: (doc['rating'] as num).toDouble(),
          content: doc['content'],
          createdAt: (doc['createdAt'] as Timestamp).toDate(),
          reservationId: doc['reservationId'],
        )).toList();

        _lastDocument = snapshot.docs.last;
        _reviews.addAll(newReviews);

        // 현재 로드된 리뷰 개수가 전체 리뷰 개수보다 작은지 확인
        _hasMore = _reviews.length < totalCount;
      }

      print('Loaded reviews: ${_reviews.length}'); // 디버깅용
      print('Has more: $_hasMore'); // 디버깅용

    } catch (e) {
      _error = e.toString();
      print('Error loading reviews: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReview({
    required String packageId,
    required String userId,
    required String userName,
    required double rating,
    required String content,
    String? reservationId,
  }) async {
    try {
      final review = Review(
        id: DateTime.now().toString(),
        packageId: packageId,
        userId: userId,
        userName: userName,
        rating: rating,
        content: content,
        createdAt: DateTime.now(),
        reservationId: reservationId,
      );

      await _repository.addReview(review);  // ReviewRepositoryImpl의 addReview 호출
      await loadInitialReviews(packageId);  // 리뷰 목록 새로고침

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  Future<bool> canUserAddReview(String userId, String packageId) {
    return _repository.canUserReview(userId, packageId);  // ReviewRepository의 메서드 호출
  }

  Future<void> loadPreviewReviews(String packageId) async {
    try {
      _isLoading = true;
      resetReviewState();
      notifyListeners();

      await getTotalReviewStats(packageId);

      final snapshot = await _firestore
          .collection('reviews')
          .where('packageId', isEqualTo: packageId)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      _reviews = snapshot.docs.map((doc) => Review(
        id: doc.id,
        packageId: doc['packageId'],
        userId: doc['userId'],
        userName: doc['userName'],
        rating: (doc['rating'] as num).toDouble(),
        content: doc['content'],
        createdAt: (doc['createdAt'] as Timestamp).toDate(),
        reservationId: doc['reservationId'],
      )).toList();

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetReviewState() {
    _reviews = [];
    _totalReviewCount = 0;
    _totalAverageRating = 0.0;
    _error = null;
    notifyListeners();
  }
}