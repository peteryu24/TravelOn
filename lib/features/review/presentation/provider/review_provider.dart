import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/review/domain/entities/review.dart';
import 'package:travel_on_final/features/review/domain/repositories/review_repository.dart';
import 'package:travel_on_final/features/search/presentation/providers/travel_provider.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository _repository;
  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _error;

  ReviewProvider(this._repository);

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReviews(String packageId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _reviews = await _repository.getPackageReviews(packageId);
      _error = null;

    } catch (e) {
      _error = e.toString();
      print('Error in loadReviews: $e'); // 디버깅용
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> canUserAddReview(String userId, String packageId) {
    return _repository.canUserReview(userId, packageId);
  }

  Future<void> addReview({
    required String packageId,
    required String userId,
    required String userName,
    required double rating,
    required String content,
    String? reservationId,
    BuildContext? context,  // BuildContext 추가
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

      await _repository.addReview(review);
      await loadReviews(packageId);  // 리뷰 목록 새로고침

      // 패키지 정보 새로고침
      if (context != null) {
        await context.read<TravelProvider>().loadPackages();
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}